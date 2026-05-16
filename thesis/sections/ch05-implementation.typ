#import "../assets/diagrams.typ": *
#import "../lib.typ": apa-figure

= Implementation <chap:implementation>


== Implementation Overview


The associated repositories form a coherent implementation with explicit structure, public interfaces, internal modules, algorithms, data flows, and verification surfaces.

The implementation can be grouped into three categories:

- *instruction repositories:* `study-assistant`, `ocr-tool`, `rag-tool`, `tts-tool`;
- *core processing repositories:* `pdfocr`, `chunkvec`, `chunktts`; and
- *shared Nim libraries:* `relay`, `jsonx`, `openai`.

== Agent and Tool Layer

=== `study-assistant`: Agent Definition Repository


The `study-assistant` repository defines the top-level agent behaviour. Its principal artefact is an instruction file that maps user requests onto study-output modes. The key design decision is that the agent operates on prepared source material. It does not prescribe OCR, vector search, or speech generation internally; instead it relies on supporting tools when the source material requires extraction, retrieval, or audio production.

The agent mode table is:

#apa-figure(
  table(
    columns: 3,
    table.header([Mode], [Purpose], [Output discipline]),
    [`transcribe`],
    [preserve source text],
    [structured markdown, no summarisation],
    [`lecture`],
    [explain formally],
    [connected academic prose],
    [`eli5`],
    [simplify],
    [plain language with maintained technical meaning],
    [`flashcard`],
    [revision],
    [two-column markdown table],
    [`mindmap`],
    [concept hierarchy],
    [Mermaid mindmap only],
    [`quiz`],
    [practice],
    [mixed questions with answer key],
    [`essay`],
    [exam preparation],
    [prompts plus sample answers],
    [`study-notes`],
    [revision notes],
    [progressive topic-organised notes],
  ),
  caption: [Agent study modes and output disciplines],
)


The design algorithm is:

+ Receive a user request and source material.
+ Determine whether the source material is already prepared text.
+ If not, delegate extraction or retrieval to a tool.
+ Select exactly one study-output mode.
+ Clean only obvious metadata noise.
+ Generate the target artefact using only available source content.

The major invariant is source grounding: the agent must not introduce unsupported factual claims into study outputs. This is essential for academic reliability.

#ref(<fig:agent-decision-flow>) shows the capability routing implemented by the instruction layer. The diagram is grounded in the mode-selection rules and the tool handoff conditions in the instruction repositories.

#figure(
  capability-routing-diagram(),
  kind: image,
  caption: [Capability routing across input conditions, tool handoffs, study modes, and optional audio output.],
)<fig:agent-decision-flow>


=== `ocr-tool`: OCR Tool Definition Repository


`ocr-tool` defines when and how PDF extraction is performed. It owns the use of `pdfocr` at the instruction layer. Its workflow is:

+ Determine that the input is a PDF requiring text extraction.
+ Check whether OCR output for the same PDF/page selection is available in the session cache.
+ If the cache misses, run `pdfocr` with `--all-pages` or `--pages:"..."`.
+ Store extracted text in the cache.
+ Pass raw extracted text to the downstream study workflow.

This repository also defines a strict responsibility boundary: OCR extraction does not generate summaries, flashcards, or interpretations. It produces source text. The cleanup rule removes only clear metadata such as headers, footers, page numbers, timestamps, and extraneous identifiers.

The cache design is intentionally outside `pdfocr`. The OCR executable stays stateless and composable, while the tool definition can optimise repeated agent sessions.

=== `rag-tool`: RAG Tool Definition Repository


`rag-tool` defines two modes: store and search.

In store mode, the agent prepares chunked text. Chunking is semantic rather than layout-driven. A chunk should represent one concept or tightly related concept cluster, contain enough context to stand alone, and avoid mixing unrelated topics. The tool distinguishes:

- global ingest metadata: `doc`, `kind`, `source`;
- per-chunk metadata: `page`, `label`.

This maps directly to `chunkvec`'s storage schema. The design protects retrieval quality by requiring stable `doc` identifiers and controlled labels. It also prevents a common RAG failure mode: chunks that are too small to be meaningful or too large to be specific.

In search mode, the tool builds one semantic query string and applies filters only when the user clearly requests constrained retrieval. This avoids over-filtering, which can hide relevant material.

=== `tts-tool`: TTS Tool Definition Repository


`tts-tool` defines the transformation from visual text to speech-ready text. The repository treats speech preparation as a separate task from audio synthesis. The agent must rewrite or remove:

- markdown syntax;
- table syntax;
- raw URLs;
- email addresses;
- LaTeX delimiters and common symbols;
- file paths and technical identifiers;
- punctuation-heavy fragments; and
- decorative content with no spoken value.

The output passed to `chunktts` is a text file with `<bk>` markers. These markers represent spoken thought units, not necessarily paragraphs or original document sections. The recommended chunk size is conservative because long TTS chunks are more likely to fail or sound unnatural.

The design separates linguistic preparation from synthesis. `tts-tool` decides what should be spoken; `chunktts` decides how to request, validate, and assemble audio.

== OCR Implementation

=== `pdfocr`: Module Structure


`pdfocr` is a Nim command-line OCR system. The inspected structure contains:

- `src/app.nim`: application entry point, exit-code mapping, relay shutdown policy;
- `src/pdfocr/runtime_config.nim`: CLI parsing, configuration loading, page-count discovery;
- `src/pdfocr/page_selection.nim`: page-selection grammar and sorted uniqueness;
- `src/pdfocr/pdfium_wrap.nim`: ownership-safe PDFium wrappers;
- `src/pdfocr/pdf_render.nim`: page rendering and WebP handoff;
- `src/pdfocr/webp_wrap.nim`: libwebp encoding wrapper;
- `src/pdfocr/ocr_client.nim`: OCR request construction and response parsing;
- `src/pdfocr/pipeline.nim`: bounded-concurrency OCR state machine;
- `src/pdfocr/request_id_codec.nim`: sequence/attempt packing;
- `src/pdfocr/retry_queue.nim`: heap-based retry scheduler;
- `src/pdfocr/retry_and_errors.nim`: retryability and final error mapping;
- `src/pdfocr/types.nim`: runtime types and JSONL result schema; and
- tests for page selection, request ids, retry logic, retry queue, and JSON output.

The repository is structured around a clean separation between native-resource wrappers, configuration, request construction, scheduling, and output schema.

=== `pdfocr`: Core Algorithms


The page-selection algorithm parses a comma-separated grammar with singleton pages and inclusive ranges. Each page is inserted into the result sequence using a lower-bound search. This yields sorted unique page numbers regardless of input order or duplicates.

The request-id codec reserves 16 bits for attempt number and uses the remaining positive signed range for sequence id. Formally:

$ "requestId" = ("seqId" << 16) | "attempt" $

The codec checks both sequence count and maximum attempts before the pipeline starts. This makes completion matching deterministic and avoids ambiguous request ids.

The pipeline state contains:

- `inFlightCount`;
- `activeCount`;
- `staged`;
- `cachedPayloads`;
- `retryQueue`;
- `nextSubmitSeqId`;
- `nextEmitSeqId`;
- `remaining`;
- `submitBatch`;
- `allSucceeded`; and
- random state for retry jitter.

The main loop performs:

+ submit due retries;
+ submit fresh attempts while capacity remains;
+ start a relay batch;
+ flush ordered staged results;
+ drain ready relay results;
+ flush again;
+ wait for progress if no result was drained.

This loop implements both throughput and ordering. It may receive page 10 before page 2, but it cannot emit page 10 until all earlier selected sequence ids are staged.

#ref(<fig:pdfocr-state-machine>) presents the page lifecycle implemented by `pipeline.nim`. It captures the actual states represented by payload preparation, in-flight requests, retry scheduling, final staging, and ordered emission.

#figure(
  ocr-state-machine-diagram(),
  kind: image,
  caption: [Per-page OCR lifecycle with retry scheduling, bounded cached payloads, staging, and ordered emission.],
)<fig:pdfocr-state-machine>


#ref(<fig:request-id-codec>) illustrates the request-id packing scheme shared by the core pipelines. This encoding is the mechanism that lets asynchronous completions be mapped back to both the logical item and the attempt number.

#figure(
  request-id-register-diagram(),
  kind: image,
  caption: [Request-id layout used for deterministic completion matching.],
)<fig:request-id-codec>


=== `pdfocr`: Error and Output Model


`pdfocr` has item-level and fatal failures. Item-level failures become JSONL objects. Fatal failures become exit code `3` and may leave stdout incomplete.

The page result schema has success and error variants:

#apa-figure(
  table(
    columns: 4,
    table.header([Field], [Success], [Error], [Meaning]),
    [`page`],
    [yes],
    [yes],
    [original page number],
    [`status`],
    [yes],
    [yes],
    [`ok` or `error`],
    [`attempts`],
    [yes],
    [yes],
    [number of attempts used],
    [`text`],
    [yes],
    [no],
    [extracted OCR text],
    [`error_kind`],
    [no],
    [yes],
    [structured failure class],
    [`error_message`],
    [no],
    [yes],
    [diagnostic message],
    [`http_status`],
    [no],
    [optional],
    [HTTP status where applicable],
  ),
  caption: [`pdfocr` page result schema],
)


The error kinds are `PdfError`, `EncodeError`, `NetworkError`, `Timeout`, `RateLimit`, `HttpError`, and `ParseError`.

== RAG Implementation

=== `chunkvec`: Module Structure


`chunkvec` implements retrieval storage and query. Its structure contains:

- `src/cvstore.nim`: ingest application entry point;
- `src/cvquery.nim`: search application entry point;
- `src/chunkvec/runtime_config.nim`: shared CLI and runtime configuration;
- `src/chunkvec/input_chunks.nim`: `<chunk ...>` parser;
- `src/chunkvec/chunk_store.nim`: SQLite schema, vector extension, insert and search;
- `src/chunkvec/embeddings_client.nim`: embedding request construction and retrying query embedding;
- `src/chunkvec/pipeline.nim`: bounded concurrent embedding ingest;
- `src/chunkvec/sqlite_vector_paths.nim`: platform-specific extension resolution;
- request-id, retry queue, retry/error, constants, types, and logging modules; and
- tests for parsing, configuration, request ids, embeddings client, and SQLite/vector integration.

The repository exposes two separate commands because storage and search have different operational profiles.

=== `chunkvec`: Chunk Parser


The chunk parser expects every chunk to start at a line with a `<chunk ...>` marker. Supported attributes are:

- `page=N`, where `N` is an integer;
- `label="..."`, where the value is double-quoted.

Unknown attributes are rejected. Empty chunk bodies are rejected. Whitespace before the first marker is ignored, and chunk bodies are trimmed. The parser searches for markers at line starts so that literal occurrences of `<chunk` inside content do not automatically split the document.

This strict input grammar matters because retrieval metadata becomes part of the persistent database. Permissive parsing would make stored retrieval state harder to reason about.

=== `chunkvec`: Database and Vector Search


The SQLite schema stores:

- `source`;
- `text`;
- `embedding` as a BLOB;
- `doc_id`;
- `kind`;
- `page`;
- `label`;
- `created_at`.

There is an index over `(doc_id, kind, page)` to support common filters. The vector extension is loaded explicitly, and `vector_init` initialises the vector column with fixed dimension and distance options. After insertions, `vector_quantize` and `vector_quantize_preload` prepare the quantized vector search path.

The ingest command runs inside a transaction. It also supports resumability by selecting already stored chunks with the same `source`, `doc_id`, `kind`, page, label, and text, then deleting those chunks from the pending ingest list. This makes repeated ingest idempotent for unchanged chunks.

Search has two paths:

- unfiltered search: run a quantized vector scan and order by distance then row id;
- filtered search: join vector scan results with metadata filters, then order and limit.

The label filter is normalised by lowercasing and removing underscores, matching the tool definition's stable-label policy.

#ref(<fig:chunkvec-schema>) shows the persisted retrieval model. The implementation stores vectors in the same logical row as text and metadata, then uses `sqlite-vector` scanning functions over the embedding column.

#figure(
  rag-access-path-diagram(),
  kind: image,
  caption: [`chunkvec` local storage, metadata filtering, vector scan, and remote embedding boundary.],
)<fig:chunkvec-schema>


=== `chunkvec`: Embedding Pipeline


The ingest pipeline uses the same state-machine pattern as OCR, but its terminal action is database insertion rather than JSONL emission. On each successful embedding response, the pipeline verifies:

+ the response parses as an embedding result;
+ the response contains an embedding;
+ the embedding length equals the configured dimension; and
+ the row can be inserted through the prepared statement.

Failures mark the chunk as unsuccessful. Successful rows are committed when the transaction completes. If all chunks are already present, the command exits successfully without sending remote embedding requests.

#ref(<fig:chunkvec-ingest-sequence>) shows the actual ingest sequence implemented by `cvstore.nim`, `chunk_store.nim`, and `pipeline.nim`.

#figure(
  cvstore-ingest-sequence-diagram(),
  kind: image,
  caption: [`cvstore` ingest sequence showing strict parsing, missing-chunk detection, embedding requests, and transaction finalisation.],
)<fig:chunkvec-ingest-sequence>


== TTS Implementation

=== `chunktts`: Module Structure


`chunktts` implements ordered text-to-speech. Its structure contains:

- `src/app.nim`: application entry point;
- `src/chunktts/runtime_config.nim`: CLI and configuration;
- `src/chunktts/chunk_split.nim`: marker-based chunk splitting;
- `src/chunktts/tts_client.nim`: speech request construction;
- `src/chunktts/sndfile_wrap.nim`: memory decoding, audio validation, `.opus` writing;
- `src/chunktts/pipeline.nim`: bounded concurrent TTS pipeline;
- request-id, retry queue, retry/error, constants, types, and logging modules; and
- tests for chunk splitting, speech requests, audio wrapper, retry mapping, request ids, and pipeline integration.

The command interface is intentionally small:

```bash
chunktts INPUT.txt OUTPUT.opus
```


All chunking decisions are encoded in the input file through `<bk>` markers.

=== `chunktts`: Speech and Audio Algorithms


The chunk splitter is simple by design: split on the configured marker, trim whitespace, and discard empty chunks. More complex linguistic chunking belongs to `tts-tool`, not to the executable.

The TTS request builder creates an OpenAI-compatible audio speech request with:

- model;
- input text;
- voice;
- WAV response format; and
- speed.

WAV is requested because the pipeline validates decoded audio before writing the final `.opus` file. `sndfile_wrap` implements virtual I/O over returned bytes, decodes them into float samples, checks sample rate/channel consistency across chunks, and writes the final Ogg Opus file.

The pipeline stores decoded chunks by sequence id. If every chunk succeeds, the output writer concatenates them in input order. If any chunk fails permanently, the final output file is not written.

The integration test uses a local asynchronous HTTP server to verify:

- actual bounded concurrency (`maxActive == 2` in the test);
- retry behaviour for a simulated HTTP 429 response;
- output file existence only after success; and
- final audio properties such as sample rate, channel count, and frame count.

#ref(<fig:chunktts-audio-assembly>) shows the audio publication gate. The key implementation detail is that returned audio is decoded into sample buffers before final `.opus` writing; this is why the tool can validate format consistency across chunks.

#figure(
  tts-publication-gate-diagram(),
  kind: image,
  caption: [`chunktts` publication gate: only complete and format-consistent decoded chunks produce the final `.opus` file.],
)<fig:chunktts-audio-assembly>


== Shared Infrastructure

=== `relay`: HTTP Transport Library


`relay` abstracts libcurl multi behind a Nim API. Its important public types are:

- `RequestSpec`;
- `RequestBatch`;
- `RequestResult`;
- `Response`;
- `TransportError`; and
- `Relay`.

The client has a worker thread. The creating thread submits requests and drains ready results. The worker thread owns the libcurl multi handle, dispatches queued requests into available easy handles, drives `curl_multi_perform` and `curl_multi_poll`, reads completion messages, and pushes completed results into a ready-results queue.

The internal queues are:

- `queue`: pending request wraps;
- `inFlight`: map from easy-handle pointer to request wrap;
- `availableEasy`: reusable easy handles; and
- `readyResults`: completed request results.

The lifecycle has two shutdown modes:

- `close`: finish queued/in-flight work and join the worker;
- `abort`: cancel queued/in-flight work, return cancellation results, and join promptly.

The transport error classifier maps curl errors into timeout, DNS, TLS, cancellation, protocol, network, and internal categories. This abstraction is what lets the core tools implement consistent retry policies. The implementation preserves the concurrency boundary shown in #ref(<fig:relay-interaction>): the caller owns scheduling, ordering, retries, and publication state, while `relay` owns libcurl multiplexing and completion delivery.


=== `jsonx`: JSON Library


`jsonx` provides a JSON lexer/parser, object mapping, streaming writers, and raw JSON support. The library is used in two ways:

- generic typed serialisation/deserialisation for configuration and API schemas;
- custom writers for output schemas whose fields depend on state.

The library supports `RawJson` and `CanonRawJson`. `RawJson` preserves arbitrary JSON fragments; `CanonRawJson` normalises object fields by sorting keys and keeping the final value for duplicate keys. This is useful for schemas and caching scenarios where an application needs to carry provider-defined JSON without modelling every field as a Nim type.

For this project, the most important design property is that JSON output is centralised in type-specific writers. `PageResult`, for example, emits common fields and then emits either `text` or error fields depending on status. This prevents scattered string concatenation and reduces schema drift.

=== `openai`: API Schema Library


The `openai` repository is a thin typed SDK that stays out of the transport layer. It depends on `relay` for HTTP and `jsonx` for JSON. The inspected modules cover:

- chat completions;
- embeddings;
- audio speech;
- request construction helpers;
- retry helpers; and
- schema modules for request and response shapes.

The chat layer provides helpers for:

- text messages;
- multimodal message parts;
- image URLs;
- tool definitions;
- structured response formats; and
- response accessors such as `firstText`.

The embeddings layer creates embedding requests and validates parsed embedding content as float or base64. The audio speech layer creates speech requests with model, input, voice, response format, speed, and optional provider-specific body fields.

The important design choice is transport transparency. `openai` builds `RequestSpec` values or appends them to `RequestBatch`; it does not execute them directly. This lets `pdfocr`, `chunkvec`, and `chunktts` control batching, timeouts, retry timing, and shutdown.

=== Configuration and Secrets


All core tools follow the same configuration pattern:

+ Load built-in defaults.
+ Read optional `config.json` from the executable directory.
+ Resolve the API key from `DEEPINFRA_API_KEY` when present.
+ Normalise values into safe ranges.

Examples of normalisation include positive concurrency limits, positive timeouts, non-negative retry counts, WebP quality constrained to `[0, 100]`, and TTS speed constrained to `[0.25, 4.0]`.

The OCR subsystem uses `allenai/olmOCR-2-7B-1025` through an OpenAI-compatible multimodal endpoint. The RAG subsystem uses an OpenAI-compatible embeddings endpoint, with `Qwen/Qwen3-Embedding-0.6B` documented as the default embedding model in `chunkvec`. The TTS subsystem uses an OpenAI-compatible audio speech endpoint, with `hexgrad/Kokoro-82M` documented as the default speech model in `chunktts`.

The runtime does not inspect arbitrary shell profiles or filesystem locations to discover secrets. The credential boundary is explicit: environment variable or config file.

=== Cross-Repository Data Contracts


The repositories communicate through simple artefacts. This artefact-based design allows the system to be inspected at each stage. It also supports standalone use: every core processing step can be invoked without the agent.

#ref(<fig:artifact-chain>) summarises the executable artefact chain. Unlike the global architecture diagram, this view focuses on concrete files and streams that can be inspected by a user or test.

#figure(
  artifact-lineage-diagram(),
  kind: image,
  caption: [Artefact lineage across OCR, retrieval, study generation, and optional audio publication.],
)<fig:artifact-chain>


== Implementation Outcomes


The implementation shows a consistent system design:

- instruction repositories define safe agent behaviour;
- core tools implement deterministic processing contracts;
- shared libraries factor out HTTP, JSON, and model API handling;
- bounded concurrency is implemented through `relay`;
- result ordering is maintained through sequence ids and staging;
- persistent retrieval is implemented through SQLite plus vector search; and
- speech output is validated before final artefact publication.

The implementation is therefore not merely a collection of scripts. It is a modular study-assistant architecture with explicit contracts at every boundary.

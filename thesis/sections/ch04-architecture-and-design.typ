#import "../assets/diagrams.typ": *
#import "../lib.typ": apa-figure

= System Architecture and Design <chap:architecture>


== Design Overview


The system is designed as a modular agent-driven study platform rather than as a single-purpose OCR program. The main architectural thesis is that study workflows require both flexible orchestration and deterministic processing. The agent layer provides flexibility: it interprets user intent, chooses a study mode, and composes tool workflows. The core tools provide determinism: they expose stable command-line contracts, bounded concurrency, explicit retry behaviour, and auditable artefacts.

The system is therefore organised into four layers:

+ *User interaction layer:* the student request and final study output.
+ *Agent orchestration layer:* the `study-assistant` workflow and mode selection.
+ *Tool definition layer:* `ocr-tool`, `rag-tool`, and `tts-tool` operational instructions.
+ *Core processing layer:* Nim executables and libraries implementing OCR, retrieval, speech synthesis, HTTP, JSON, and model API handling.

This layered design avoids coupling study-output generation to implementation details such as PDFium handles, SQLite vector storage, or libcurl polling. It also keeps tool execution verifiable independently of the agent.

== Global Architecture


#ref(<fig:global-architecture>) shows the principal components and data paths.

#figure(
  canvas({
    cbox((3.2, 4.3), [Student], body: [study request], name: "student")
    cbox((3.2, 3), [study-assistant], body: [mode selection], name: "agent")

    cbox((0, 1.6), [`ocr-tool`], body: [PDF extraction], name: "ocrtool")
    cbox((3.2, 1.6), [`rag-tool`], body: [store / search], name: "ragtool")
    cbox((6.4, 1.6), [`tts-tool`], body: [speech workflow], name: "ttstool")

    cbox((0, .2), [`pdfocr`], body: [OCR pipeline], name: "pdfocr")
    cbox((3.2, .2), [`chunkvec`], body: [cvstore / cvquery], name: "chunkvec")
    cbox((6.4, .2), [`chunktts`], body: [TTS pipeline], name: "chunktts")

    cstore((3.2, -1.1), [SQLite], body: [vector store], name: "storage")
    cstore((0, -1.1), [OpenAI-compatible], body: [model endpoints], name: "models")

    carrow("student", "agent")
    carrow("agent", "ocrtool")
    carrow("agent", "ragtool")
    carrow("agent", "ttstool")
    carrow("ocrtool", "pdfocr")
    carrow("ragtool", "chunkvec")
    carrow("ttstool", "chunktts")
    carrow("chunkvec.south-west", "storage.north-west")
    carrow("storage.north-east", "chunkvec.south-east")
    carrow("pdfocr.south", "models.north")
    carrow("chunkvec.south-west", "models.north-east")
    carrow("chunktts.south-west", "models.north-east")
  }),
  kind: image,
  caption: [Global architecture of the study-assistant system.],
)<fig:global-architecture>


The figure expresses the central separation of concerns. The agent and tool definitions are declarative/operational layers. The Nim components implement execution. The shared libraries provide common infrastructure.

#apa-figure(
  table(
    columns: 4,
    table.header([Repository], [Layer], [Primary responsibility], [Principal artefacts]),
    [`study-assistant`],
    [Agent],
    [Select study mode and generate grounded study outputs],
    [mode rules for transcribe, lecture, ELI5, flashcards, mindmap, quiz, essay, notes],
    [`ocr-tool`],
    [Tool definition],
    [Convert PDFs to raw text using `pdfocr`],
    [OCR command rules, cache workflow, extraction cleanup],
    [`rag-tool`],
    [Tool definition],
    [Store/search study material using `chunkvec`],
    [store/search modes, chunking rules, metadata policy],
    [`tts-tool`],
    [Tool definition],
    [Produce speech audio using `chunktts`],
    [speech rewriting rules, chunk boundary policy],
    [`pdfocr`],
    [Core tool],
    [Render PDF pages and perform model-based OCR],
    [ordered JSONL, page errors, retry state machine],
    [`chunkvec`],
    [Core tool],
    [Embed, store, and retrieve study chunks],
    [SQLite vector store, chunk parser, search output],
    [`chunktts`],
    [Core tool],
    [Generate ordered speech audio],
    [speech chunks, audio validation, final `.opus`],
    [`relay`],
    [Library],
    [Execute bounded concurrent HTTP requests],
    [worker thread, libcurl multi, request/result API],
    [`jsonx`],
    [Library],
    [Parse and write typed JSON],
    [parser, object mapper, streaming writer, raw JSON],
    [`openai`],
    [Library],
    [Build and parse OpenAI-compatible API calls],
    [chat, embeddings, audio speech request helpers],
  ),
  caption: [Component responsibilities],
)<tbl:repo-responsibilities>


#apa-figure(
  table(
    columns: 3,
    table.header([Background concept], [System component], [Design consequence]),
    [PDF rendering and OCR],
    [`ocr-tool`, `pdfocr`],
    [render pages with PDFium, encode WebP, call olmOCR 2, emit ordered JSONL],
    [Document OCR evaluation],
    [`pdfocr` benchmarks],
    [report CER, WER, reading-order F1, math F1, recall-oriented outcomes],
    [Dense retrieval],
    [`rag-tool`, `chunkvec`],
    [embed chunks and queries, store vectors, perform nearest-neighbour search],
    [RAG],
    [`study-assistant`, `rag-tool`],
    [retrieve source passages before grounded study-output generation],
    [Neural TTS],
    [`tts-tool`, `chunktts`],
    [rewrite text for speech, synthesise chunks, validate audio, write `.opus`],
    [Concurrent model APIs],
    [`relay`, `openai`],
    [bounded in-flight requests, retry handling, completion polling],
    [Structured interchange],
    [`jsonx`, JSONL],
    [typed request/response parsing and stable output records],
  ),
  caption: [Mapping of background concepts to implementation components],
)<tbl:foundation-mapping>


== Agent-Level Interaction Model


The `study-assistant` agent defines a mode-selection interface. A user request is mapped to exactly one study-output mode when the output is generated directly from prepared material. The supported modes have distinct contracts:

- *transcribe:* preserve educational text verbatim while removing only clear metadata noise;
- *lecture:* present material as formal connected prose;
- *eli5:* explain the same material in simple language without adding unrelated facts;
- *flashcard:* produce a two-column exam-revision table;
- *mindmap:* produce a Mermaid mind map in a strict hierarchy;
- *quiz:* produce mixed practice questions and an answer key;
- *essay:* produce exam-style prompts and sample answers; and
- *study-notes:* produce progressive exam-focused notes.

This mode design is important because it prevents the agent from conflating extraction, explanation, retrieval, and transformation. A transcription mode should not summarise. A quiz mode should not introduce outside knowledge. A TTS preparation step should optimise for speech while preserving meaning.

== Tool Definition Layer


The three tool-definition repositories encode operational policy.

`ocr-tool` owns PDF extraction. It requires `pdfocr` for PDF text extraction, supports page ranges and full-document mode, and defines a cache procedure so repeated PDF/page selections do not require repeated model calls. The cache is keyed by input PDF identity and page selection. This is a tool-level optimisation: it is outside `pdfocr` so the OCR executable remains a stateless command-line tool.

`rag-tool` owns storage and retrieval. It distinguishes store mode from search mode, requires stable document identifiers, and separates global ingest metadata (`doc`, `kind`, `source`) from per-chunk metadata (`page`, `label`). This distinction maps directly onto the `chunkvec` database schema.

`tts-tool` owns speech preparation. It rewrites markdown, links, mathematical notation, URLs, file paths, and punctuation-heavy text into a speakable form. It also decides where `<bk>` markers should be placed. This is intentionally done before `chunktts` because natural speech preparation is a linguistic transformation, while `chunktts` is an artefact-generation pipeline.

== Operational Contracts


`study-assistant` requires prepared source material, maps each request to a single output form, and removes only clear metadata noise while preserving educational content.

`ocr-tool` delegates PDF extraction to `pdfocr`, supports full-document and page-range extraction, and treats extracted text as raw material for downstream processing.

`rag-tool` requires plain text or markdown input, stable document identifiers, explicit chunk boundaries, and retrieval from a reusable vector store.

`tts-tool` requires manual rewriting for natural speech, conservative chunking with `<bk>` markers, and generation through `chunktts`.

#apa-figure(
  table(
    columns: 4,
    table.header([Repository], [Command surface], [System role], [Core contract]),
    [`pdfocr`],
    [`pdfocr INPUT.pdf --pages:"..."` or `--all-pages`],
    [OCR processing],
    [ordered JSONL page results, bounded concurrency, retry handling],
    [`chunkvec`],
    [`cvstore`, `cvquery`],
    [RAG storage/search],
    [marked chunk ingest, SQLite vector store, local nearest-neighbour search],
    [`chunktts`],
    [`chunktts INPUT.txt OUTPUT.opus`],
    [speech generation],
    [ordered chunk synthesis, audio validation, one final `.opus` artefact],
  ),
  caption: [Core tool command contracts],
)


== Core Processing Pattern


The three core tools share a common processing pattern:

+ Parse CLI arguments and validate required inputs.
+ Load optional configuration from the executable directory.
+ Resolve API credentials with environment-variable precedence.
+ Normalise input into ordered work items.
+ Assign deterministic request identifiers.
+ Submit bounded batches through `relay`.
+ Classify completions into success, retryable failure, or terminal failure.
+ Retry retryable failures according to a time-ordered retry queue.
+ Finalise output in deterministic order or in a transactional database state.
+ Map the outcome to a stable exit code.

The shared pattern is not accidental. It is the mechanism by which the system keeps remote model calls reliable enough for academic study workflows.

== OCR Data Flow


#ref(<fig:ocr-dataflow>) shows the OCR pipeline.

#figure(
  canvas({
    cbox((0, 1.2), [Input PDF], name: "pdf")
    cbox((2.6, 1.2), [Page selection], body: [normalisation], name: "select")
    cbox((5.2, 1.2), [PDFium], body: [render page], name: "render")
    cbox((7.8, 1.2), [WebP], body: [encode], name: "webp")
    cbox((10.4, 1.2), [OpenAI chat], body: [image request], name: "request")
    cbox((13.0, 1.2), [olmOCR 2], body: [endpoint], name: "model")
    cstore((7.8, -.1), [cached payloads], body: [O(K)], name: "cache")
    cstore((10.4, -.1), [retry queue], name: "retry")
    cstore((13.0, -.1), [staged results], body: [O(N)], name: "stage")
    cbox((15.4, -.1), [ordered], body: [JSONL stdout], name: "jsonl")

    carrow("pdf", "select")
    carrow("select", "render")
    carrow("render", "webp")
    carrow("webp", "request")
    carrow("request", "model")
    carrow("model", "stage")
    carrow("stage", "jsonl")
    carrow("webp", "cache")
    carrow("cache.north-east", "request.south-west")
    carrow("model.south-west", "retry.north-east")
    carrow("retry", "request")
  }),
  kind: image,
  caption: [OCR data flow from PDF pages to ordered JSONL records.],
)<fig:ocr-dataflow>


The OCR pipeline uses `N` for selected page count and `K` for maximum active/in-flight work. The staged result array is O(`N`) metadata. WebP payload storage is O(`K`) because only active pages keep cached payload bytes for possible retry. This design supports large documents without keeping all rendered page images in memory.

== RAG Data Flow


#ref(<fig:rag-dataflow>) shows how source material becomes searchable.

#figure(
  canvas({
    cbox((0, 1.2), [Prepared text], name: "text")
    cbox((3.0, 1.2), [\<chunk ...\>], body: [parser], name: "chunks")
    cbox((6.0, 1.2), [Embedding], body: [requests], name: "emb")
    cstore((9.0, 1.2), [SQLite table], body: [text + metadata + vector], name: "sqlite")
    cstore((12.0, 1.2), [sqlite-vector], body: [quantized scan], name: "vector")
    cbox((0, -.4), [User query], name: "query")
    cbox((3.0, -.4), [Query], body: [embedding], name: "qemb")
    cbox((6.0, -.4), [Metadata], body: [filters], name: "filters")
    cbox((9.0, -.4), [Ranked], body: [chunks], name: "results")

    carrow("text", "chunks")
    carrow("chunks", "emb")
    carrow("emb", "sqlite")
    carrow("sqlite", "vector")
    carrow("query", "qemb")
    carrow("qemb", "filters")
    carrow("filters.north-east", "vector.south-west")
    carrow("vector.south-west", "results.north-east")
  }),
  kind: image,
  caption: [RAG storage and retrieval data flow.],
)<fig:rag-dataflow>


The storage path (`cvstore`) and query path (`cvquery`) are deliberately separate. Storage performs remote embedding generation and database mutation. Query performs a single remote query-embedding request, then local vector search. This limits remote dependency during retrieval and keeps the search corpus under local user control.

== TTS Data Flow


#ref(<fig:tts-dataflow>) shows the TTS path.

#figure(
  canvas({
    cbox((0, 1.1), [Speech-ready], body: [text], name: "input")
    cbox((2.6, 1.1), [Split on], body: [\<bk\>], name: "split")
    cbox((5.2, 1.1), [Speech], body: [requests], name: "speech")
    cbox((7.8, 1.1), [Audio speech], body: [endpoint], name: "endpoint")
    cstore((10.4, 1.1), [libsndfile], body: [decode + validate], name: "decode")
    cstore((13.0, 1.1), [ordered audio], body: [chunks], name: "staged")
    cbox((15.4, 1.1), [final .opus], body: [file], name: "opus")
    cstore((5.2, -.2), [retry queue], name: "retry")

    carrow("input", "split")
    carrow("split", "speech")
    carrow("speech", "endpoint")
    carrow("endpoint", "decode")
    carrow("decode", "staged")
    carrow("staged", "opus")
    carrow("endpoint.south-west", "retry.north-east")
    carrow("retry", "speech")
  }),
  kind: image,
  caption: [TTS data flow from speech-prepared text to final `.opus` artefact.],
)<fig:tts-dataflow>


The TTS pipeline differs from OCR in its publication rule. OCR can emit per-page error records because downstream tools can choose how to handle partial page failures. TTS withholds the final audio file unless all chunks succeed, because a partial lecture audio file would be misleading.

== Relay-Based Interaction Model


The core tools use `relay` to avoid embedding libcurl logic in each processing pipeline. #ref(<fig:relay-interaction>) shows the interaction.

#figure(
  canvas({
    cstore((0, 1), [Tool main thread], body: [scheduler state machine], name: "main")
    cbox((3.2, 1), [RequestBatch], body: [work items], name: "batch")
    cstore((6.4, 1), [Relay worker thread], body: [libcurl multi], name: "relay")
    cbox((9.6, 1), [Remote model], body: [API], name: "api")
    cbox((0, -.4), [staging / DB /], body: [decoded chunks], name: "stage")
    cbox((6.4, -.4), [ready results], body: [deque], name: "ready")

    carrow("main", "batch")
    carrow("batch", "relay")
    carrow("relay", "api")
    carrow("api", "relay")
    carrow("relay", "ready")
    carrow("ready", "stage")
    carrow("stage", "main")
  }),
  kind: image,
  caption: [Component interaction between a core tool and the `relay` transport layer.],
)<fig:relay-interaction>


The tool main thread owns ordering, retries, and output state. The relay worker owns transfer execution. This is a narrow concurrency boundary: state that determines correctness remains in the tool, while network multiplexing remains in the transport library.

== Cross-Cutting Invariants


The architecture depends on several invariants:

- *I1: bounded active work.* Each network-dependent pipeline enforces `inFlightCount <= K`; OCR and TTS also bound active cached payloads or decoded chunks according to the work list.
- *I2: deterministic request identity.* Request ids encode sequence id and attempt, allowing out-of-order completions to be classified without shared mutable lookup tables.
- *I3: ordered finalisation.* OCR emits from `staged[nextEmitSeqId]`; TTS writes decoded chunks in sequence order; RAG stores chunks with stable metadata and searches with deterministic ordering by distance and id.
- *I4: explicit retryability.* Transport errors and selected HTTP statuses are classified before retry; permanent failures are not retried indefinitely.
- *I5: clean process channels.* Machine-readable outputs use stdout where relevant; logs use stderr.
- *I6: configuration normalisation.* Invalid numeric values and empty strings are replaced by defaults so runtime state remains within expected bounds.

These invariants are the bridge between the background concepts in Chapter #ref(<chap:background>) and the implementation details in Chapter #ref(<chap:implementation>).

== Design Rationale


The design uses standalone tools rather than a single long-running service for three reasons.

First, command-line tools are easy to compose in student workflows. OCR JSONL can be redirected, stored, inspected with `jq`, or ingested into other systems. Generated audio is a normal `.opus` file. The vector database is local.

Second, independent tools make failures easier to isolate. If OCR fails, the failure is represented as page-level JSON or a fatal exit code. If TTS fails, the final audio file is withheld. If retrieval returns irrelevant chunks, the issue can be examined through chunk boundaries and metadata.

Third, the architecture supports agent use without requiring the agent to implement low-level systems. The agent remains responsible for study logic; the tools remain responsible for processing contracts.

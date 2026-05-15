#import "../assets/diagrams.typ": *
#import "../lib.typ": apa-figure

= System Architecture and Design <chap:architecture>


== Design Overview


The system is designed as a modular agent-driven study platform rather than as a single-purpose OCR program. The main architectural thesis is that study workflows require both flexible orchestration and deterministic processing. The agent layer provides flexibility: it interprets user intent, chooses a study mode, and composes tool workflows. The core tools provide determinism: they expose stable command-line contracts, bounded concurrency, explicit retry behaviour, and auditable artefacts.

The system is therefore organised into five layers:

+ *User interaction layer:* the student request and final study output.
+ *Agent orchestration layer:* the `study-assistant` workflow and mode selection.
+ *Tool definition layer:* `ocr-tool`, `rag-tool`, and `tts-tool` operational instructions.
+ *Core processing layer:* Nim executables implementing OCR, retrieval, and speech synthesis.
+ *Shared infrastructure layer:* local storage, artefact files, HTTP transport, JSON handling, and model API schema support.

This layered design avoids coupling study-output generation to implementation details such as PDFium handles, SQLite vector storage, or libcurl polling. It also keeps tool execution verifiable independently of the agent.

== Global Architecture


#ref(<fig:global-architecture>) shows the architectural layers, local execution boundary, and external provider boundary.

#figure(
  layered-architecture-diagram(),
  kind: image,
  caption: [Layered architecture of the study-assistant system with local execution and remote provider boundaries.],
)<fig:global-architecture>


The figure expresses the central separation of concerns. The agent and tool definitions are declarative and operational layers. The Nim components implement local deterministic execution. The shared libraries provide common infrastructure, while model-hosted OCR, embedding, and speech endpoints remain outside the local process boundary.

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


The background concepts from Chapter #ref(<chap:background>) map to concrete component responsibilities: rendering-first OCR is implemented by `pdfocr`, retrieval by `chunkvec`, speech synthesis by `chunktts`, and concurrent model access by the combination of `relay`, `openai`, and typed JSON handling.


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

#figure(
  core-execution-pattern-diagram(),
  kind: image,
  caption: [Shared bounded-concurrency execution pattern across OCR, retrieval ingest, and speech generation.],
)<fig:core-execution-pattern>


The OCR pipeline uses `N` for selected page count and `K` for maximum active/in-flight work. The staged result array is O(`N`) metadata. WebP payload storage is O(`K`) because only active pages keep cached payload bytes for possible retry. In RAG ingest, the same pattern terminates in transactional database insertion. In TTS, it terminates in all-or-nothing audio publication.

== Retrieval Boundary


The storage path (`cvstore`) and query path (`cvquery`) are deliberately separate. Storage performs remote embedding generation and database mutation. Query performs a single remote query-embedding request, then local vector search. This limits remote dependency during retrieval and keeps the search corpus under local user control.

== Speech Publication Boundary


The TTS pipeline differs from OCR in its publication rule. OCR can emit per-page error records because downstream tools can choose how to handle partial page failures. TTS withholds the final audio file unless all chunks succeed, because a partial lecture audio file would be misleading.

== Relay-Based Interaction Model


The core tools use `relay` to avoid embedding libcurl logic in each processing pipeline. #ref(<fig:relay-interaction>) shows the concurrency boundary.

#figure(
  relay-concurrency-diagram(),
  kind: image,
  caption: [Concurrency boundary between a core tool scheduler and the `relay` transport worker.],
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

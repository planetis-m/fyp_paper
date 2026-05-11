#import "../assets/diagrams.typ": *
#import "../lib.typ": apa-figure

= System Architecture and Design <chap:architecture>


== Design Overview


The system is designed as a modular agent-driven study platform rather than as a single-purpose OCR program. The main architectural thesis is that study workflows require both flexible orchestration and deterministic processing. The agent layer provides flexibility: it interprets user intent, chooses a study mode, and composes tool workflows. The core tools provide determinism: they expose stable command-line contracts, bounded concurrency, explicit retry behaviour, and auditable artefacts.

The system is therefore organised into four layers:

1. *User interaction layer:* the student request and final study output.
2. *Agent orchestration layer:* the `study-assistant` workflow and mode selection.
3. *Tool definition layer:* `ocr-tool`, `rag-tool`, and `tts-tool` operational instructions.
4. *Core processing layer:* Nim executables and libraries implementing OCR, retrieval, speech synthesis, HTTP, JSON, and model API handling.

This layered design avoids coupling study-output generation to implementation details such as PDFium handles, SQLite vector storage, or libcurl polling. It also keeps tool execution verifiable independently of the agent.

== Global Architecture


#ref(<fig:global-architecture>) shows the principal components and data paths.

#figure(
  canvas({
    cbox((0, 3), [Student], name: "student")
    cbox((3.2, 3), [Agent], name: "agent")
    cstore((6.4, 3), [Study output], name: "output")

    cbox((0, 1.6), [`ocr-tool`], name: "ocrtool")
    cbox((3.2, 1.6), [`rag-tool`], name: "ragtool")
    cbox((6.4, 1.6), [`tts-tool`], name: "ttstool")

    cstore((0, .2), [`pdfocr`], name: "pdfocr")
    cstore((3.2, .2), [`chunkvec`], name: "chunkvec")
    cstore((6.4, .2), [`chunktts`], name: "chunktts")
    cstore((3.2, -1.1), [Shared libraries], name: "shared")

    carrow("student", "agent")
    carrow("agent", "output")
    carrow("agent", "ocrtool")
    carrow("agent", "ragtool")
    carrow("agent", "ttstool")
    carrow("ocrtool", "pdfocr")
    carrow("ragtool", "chunkvec")
    carrow("ttstool", "chunktts")
  }),
  kind: image,
  caption: [Global architecture of the study-assistant system.],
)<fig:global-architecture>


The figure expresses the central separation of concerns. The agent and tool definitions are declarative/operational layers. The Nim repositories implement execution. The shared libraries provide common infrastructure.

== Repository Responsibilities


#ref(<tbl:repo-responsibilities>) summarises the repository-level responsibilities.


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
  caption: [Repository responsibilities],
)<tbl:repo-responsibilities>


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

== Core Processing Pattern


The three core tools share a common processing pattern:

1. Parse CLI arguments and validate required inputs.
2. Load optional configuration from the executable directory.
3. Resolve API credentials with environment-variable precedence.
4. Normalise input into ordered work items.
5. Assign deterministic request identifiers.
6. Submit bounded batches through `relay`.
7. Classify completions into success, retryable failure, or terminal failure.
8. Retry retryable failures according to a time-ordered retry queue.
9. Finalise output in deterministic order or in a transactional database state.
10. Map the outcome to a stable exit code.

The shared pattern is not accidental. It is the mechanism by which the system keeps remote model calls reliable enough for academic study workflows.

== OCR Data Flow


#ref(<fig:ocr-dataflow>) shows the OCR pipeline.

#figure(
  canvas({
    cbox((0, 1.2), [Input PDF], name: "pdf")
    cbox((2.6, 1.2), [Page select], name: "select")
    cbox((5.2, 1.2), [Render], name: "render")
    cbox((7.8, 1.2), [OCR request], name: "request")
    cstore((5.2, -.1), [Cache], name: "cache")
    cstore((7.8, -.1), [Staged], name: "stage")
    cstore((10.4, -.1), [JSONL], name: "jsonl")

    carrow("pdf", "select")
    carrow("select", "render")
    carrow("render", "request")
    carrow("render", "cache")
    carrow("cache", "request")
    carrow("request", "stage")
    carrow("stage", "jsonl")
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
    cbox((3.0, 1.2), [Chunk parser], name: "chunks")
    cstore((6.0, 1.2), [Vector DB], name: "store")
    cbox((0, -.4), [User query], name: "query")
    cbox((3.0, -.4), [Query embed], name: "qemb")
    cstore((6.0, -.4), [Ranked chunks], name: "results")

    carrow("text", "chunks")
    carrow("chunks", "store")
    carrow("query", "qemb")
    carrow("qemb", "store")
    carrow("store", "results")
  }),
  kind: image,
  caption: [RAG storage and retrieval data flow.],
)<fig:rag-dataflow>


The storage path (`cvstore`) and query path (`cvquery`) are deliberately separate. Storage performs remote embedding generation and database mutation. Query performs a single remote query-embedding request, then local vector search. This limits remote dependency during retrieval and keeps the search corpus under local user control.

== TTS Data Flow


#ref(<fig:tts-dataflow>) shows the TTS path.

#figure(
  canvas({
    cbox((0, 1.1), [Speech text], name: "text")
    cbox((2.6, 1.1), [Split on `<bk>`], name: "split")
    cbox((5.2, 1.1), [Speech requests], name: "req")
    cbox((7.8, 1.1), [Audio endpoint], name: "api")
    cstore((7.8, -.2), [Validate audio], name: "decode")
    cstore((10.4, -.2), [Final `.opus`], name: "opus")

    carrow("text", "split")
    carrow("split", "req")
    carrow("req", "api")
    carrow("api", "decode")
    carrow("decode", "opus")
  }),
  kind: image,
  caption: [TTS data flow from speech-prepared text to final `.opus` artefact.],
)<fig:tts-dataflow>


The TTS pipeline differs from OCR in its publication rule. OCR can emit per-page error records because downstream tools can choose how to handle partial page failures. TTS withholds the final audio file unless all chunks succeed, because a partial lecture audio file would be misleading.

== Relay-Based Interaction Model


The core tools use `relay` to avoid embedding libcurl logic in each processing pipeline. #ref(<fig:relay-interaction>) shows the interaction.

#figure(
  canvas({
    cbox((0, 1), [Tool thread], name: "main")
    cbox((2.8, 1), [Batch], name: "batch")
    cbox((5.6, 1), [`relay` worker], name: "relay")
    cbox((8.4, 1), [Model API], name: "api")
    cstore((5.6, -.4), [Ready results], name: "ready")

    carrow("main", "batch")
    carrow("batch", "relay")
    carrow("relay", "api")
    carrow("api", "relay")
    carrow("relay", "ready")
    carrow("ready", "main")
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

These invariants are the bridge between the academic concepts in Chapter #ref(<chap:foundations>) and the implementation details in Chapter #ref(<chap:implementation>).

== Design Rationale


The design uses standalone tools rather than a single long-running service for three reasons.

First, command-line tools are easy to compose in student workflows. OCR JSONL can be redirected, stored, inspected with `jq`, or ingested into other systems. Generated audio is a normal `.opus` file. The vector database is local.

Second, independent tools make failures easier to isolate. If OCR fails, the failure is represented as page-level JSON or a fatal exit code. If TTS fails, the final audio file is withheld. If retrieval returns irrelevant chunks, the issue can be examined through chunk boundaries and metadata.

Third, the architecture supports agent use without requiring the agent to implement low-level systems. The agent remains responsible for study logic; the tools remain responsible for processing contracts.

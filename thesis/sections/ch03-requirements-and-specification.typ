#import "../lib.typ": apa-figure

= Requirements and Specification <chap:requirements>


== Requirements Elicitation and Organisation


The requirements were drafted by the author from the project study, exploratory workflow experiments, and analysis of common student revision tasks. The specification states the responsibilities of each subsystem and the guarantees that connect them.

The specification is organised around four levels, moving from user-visible behaviour to implementation constraints:

- user-facing study workflows;
- agent-level orchestration rules;
- tool-level command and artefact contracts; and
- core implementation invariants.

== System Actors and Use Cases


The primary actor is a student or researcher preparing study material. The user may provide a PDF, text file, markdown file, stored document identity, or raw text. The agent selects a workflow and uses the relevant tool when the source material requires processing.

The main use cases are:

- transcribe source material into structured markdown while preserving educational content;
- generate professor-style lecture explanations from prepared material;
- produce plain-English explanations without losing technical accuracy;
- create flashcards, Mermaid mind maps, quizzes, and essay prompts;
- extract raw text from PDFs before downstream processing;
- ingest cleaned text into a vector store for retrieval;
- search stored study material using semantic queries and metadata filters; and
- convert prepared study text into natural `.opus` audio.

== Functional Requirements


The agent-level functional requirements are:

- *FR-A1:* The system shall expose `study-assistant` as the coordinating agent for study workflows.
- *FR-A2:* The agent shall map user intent to a single study mode when producing a direct study artefact.
- *FR-A3:* The agent shall operate only on available source material or material explicitly extracted by the tools.
- *FR-A4:* The agent shall preserve source meaning and avoid inventing content during cleaning, chunking, retrieval preparation, and TTS preparation.
- *FR-A5:* The agent shall invoke specialised tools for OCR, RAG, and TTS rather than embedding these concerns into one monolithic prompt.

The OCR functional requirements are:

- *FR-O1:* `ocr-tool` shall own PDF-to-text extraction workflows at the instruction layer.
- *FR-O2:* `pdfocr` shall accept a local PDF and exactly one page-selection mode: selected pages or all pages.
- *FR-O3:* `pdfocr` shall render pages, submit OCR requests to an OpenAI-compatible multimodal model endpoint, and emit one JSON object per selected page.
- *FR-O4:* Successful page results shall include page number, status, attempt count, and extracted text.
- *FR-O5:* Failed page results shall include page number, status, attempt count, error kind, error message, and HTTP status where applicable.

The RAG functional requirements are:

- *FR-R1:* `rag-tool` shall own storage and retrieval workflows at the instruction layer.
- *FR-R2:* `cvstore` shall ingest one marked-up text file whose chunks begin with `<chunk ...>` markers.
- *FR-R3:* `cvstore` shall apply command-line document identity and content kind metadata to the ingest run.
- *FR-R4:* `cvquery` shall embed one query string and retrieve nearest-neighbour matches from the local vector database.
- *FR-R5:* Search shall support metadata filters for document, kind, page, and label where valid.

The TTS functional requirements are:

- *FR-T1:* `tts-tool` shall own text-to-speech workflows at the instruction layer.
- *FR-T2:* The tool shall rewrite visual or technical text into a natural spoken form without changing the underlying meaning.
- *FR-T3:* `chunktts` shall accept one marked-up text file and one output path.
- *FR-T4:* `chunktts` shall split input on `<bk>` markers, synthesise each chunk, validate audio, and write a single final `.opus` file.
- *FR-T5:* The final audio order shall match the normalised chunk order.

== Non-Functional Requirements


The system non-functional requirements are:

- *NFR-1 Modularity:* Agent definitions, tool definitions, and core implementations shall remain separately understandable and usable.
- *NFR-2 Composability:* Command-line tools shall use stable inputs and outputs suitable for shell workflows.
- *NFR-3 Determinism:* Page and chunk ordering shall be deterministic regardless of network completion order.
- *NFR-4 Bounded concurrency:* Remote model calls shall be limited by a configured in-flight bound.
- *NFR-5 Retry robustness:* Transient network and selected API failures shall be retried according to explicit policy.
- *NFR-6 Observability:* Logs and diagnostics shall not pollute machine-readable outputs.
- *NFR-7 Configuration clarity:* API URLs, models, keys, and concurrency settings shall be resolved through documented defaults, optional `config.json`, and environment overrides where supported.
- *NFR-8 Standalone utility:* OCR, RAG, and TTS tools shall remain useful without the agent.

== Requirements Traceability Matrix


#ref(<tbl:req-traceability>) maps the main requirements to implementation mechanisms.


#apa-figure(
  table(
    columns: 3,
    table.header([Requirement], [Agent/tool layer], [Core implementation mechanism]),
    [FR-A2],
    [`study-assistant` mode selection],
    [prepared source text consumed by the agent],
    [FR-O1--FR-O3],
    [`ocr-tool` workflow],
    [`pdfocr` rendering, WebP encoding, OCR request pipeline],
    [NFR-3],
    [`ocr-tool` expects raw ordered text],
    [`pdfocr` sequence ids and staged JSONL emission],
    [FR-R1--FR-R3],
    [`rag-tool` store mode],
    [`cvstore` chunk parser, embeddings pipeline, SQLite insert],
    [FR-R4--FR-R5],
    [`rag-tool` search mode],
    [`cvquery` query embedding and `sqlite-vector` nearest-neighbour search],
    [FR-T1--FR-T5],
    [`tts-tool` workflow],
    [`chunktts` chunk splitting, speech requests, audio validation],
    [NFR-4, NFR-5],
    [tool execution guidance],
    [`relay` `maxInFlight`, retry queues, request-id codecs],
    [FR-O4--FR-O5, NFR-6],
    [tool configuration and outputs],
    [`jsonx` typed parsing and streaming JSON serialisation],
    [FR-O3, FR-R4, FR-T4],
    [model endpoint configuration],
    [custom `openai` chat, embedding, and speech helpers],
  ),
  caption: [Requirements traceability],
)<tbl:req-traceability>


== Acceptance Criteria


The project is considered complete when the following criteria are met:

- the report explains the agent and tool suite as a single system;
- all seven repositories are represented in the architecture narrative;
- OCR, RAG, and TTS are documented both as standalone tools and as agent components;
- the Nim implementation foundation is clearly described;
- olmOCR 2 results are reported and interpreted in the evaluation section;
- no component is presented as separate from the unified system design.

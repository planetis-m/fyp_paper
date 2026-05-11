#import "../lib.typ": apa-figure

= Requirements and Specification <chap:requirements>


== Requirements Method


The system requirements are derived from the implemented agent definitions, tool definitions, command-line programs, tests, and documented benchmark artefacts. The purpose of this chapter is to state the system contract as a cohesive specification. The chapter therefore focuses on the responsibilities of each subsystem and the guarantees that connect them.

The specification is organised around four levels:

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

- The system shall expose `study-assistant` as the coordinating agent for study workflows.
- The agent shall map user intent to a single study mode when producing a direct study artefact.
- The agent shall operate only on available source material or material explicitly extracted by the tools.
- The agent shall preserve source meaning and avoid inventing content during cleaning, chunking, retrieval preparation, and TTS preparation.
- The agent shall invoke specialised tools for OCR, RAG, and TTS rather than embedding these concerns into one monolithic prompt.

The OCR functional requirements are:

- `ocr-tool` shall own PDF-to-text extraction workflows at the instruction layer.
- `pdfocr` shall accept a local PDF and exactly one page-selection mode: selected pages or all pages.
- `pdfocr` shall render pages, submit OCR requests to an OpenAI-compatible multimodal model endpoint, and emit one JSON object per selected page.
- Successful page results shall include page number, status, attempt count, and extracted text.
- Failed page results shall include page number, status, attempt count, error kind, error message, and HTTP status where applicable.

The RAG functional requirements are:

- `rag-tool` shall own storage and retrieval workflows at the instruction layer.
- `cvstore` shall ingest one marked-up text file whose chunks begin with `<chunk ...>` markers.
- `cvstore` shall apply command-line document identity and content kind metadata to the ingest run.
- `cvquery` shall embed one query string and retrieve nearest-neighbour matches from the local vector database.
- Search shall support metadata filters for document, kind, page, and label where valid.

The TTS functional requirements are:

- `tts-tool` shall own text-to-speech workflows at the instruction layer.
- The tool shall rewrite visual or technical text into a natural spoken form without changing the underlying meaning.
- `chunktts` shall accept one marked-up text file and one output path.
- `chunktts` shall split input on `<bk>` markers, synthesise each chunk, validate audio, and write a single final `.opus` file.
- The final audio order shall match the normalised chunk order.

== Non-Functional Requirements


The system non-functional requirements are:

- *Modularity:* agent definitions, tool definitions, and core implementations shall remain separately understandable and usable.
- *Composability:* command-line tools shall use stable inputs and outputs suitable for shell workflows.
- *Determinism:* page and chunk ordering shall be deterministic regardless of network completion order.
- *Bounded concurrency:* remote model calls shall be limited by a configured in-flight bound.
- *Retry robustness:* transient network and selected API failures shall be retried according to explicit policy.
- *Observability:* logs and diagnostics shall not pollute machine-readable outputs.
- *Configuration clarity:* API URLs, models, keys, and concurrency settings shall be resolved through documented defaults, optional `config.json`, and environment overrides where supported.
- *Standalone utility:* OCR, RAG, and TTS tools shall remain useful without the agent.

== Agent-Level Instruction Contracts


The agent-level repositories define how the system behaves as an assistant rather than only as a set of executables.

`study-assistant` defines the study artefact modes. It requires prepared source material and maps each user request to a single output form. It also defines cleaning behavior: remove clear metadata such as page numbers or headers while preserving educational content.

`ocr-tool` defines the PDF extraction workflow. It delegates extraction exclusively to `pdfocr`, supports full-document and page-range extraction, and treats extracted text as raw material for downstream processing.

`rag-tool` defines storage and search behavior. It requires plain text or markdown input, stable document identifiers, explicit chunk boundaries, and retrieval from a reusable vector store.

`tts-tool` defines the speech workflow. It requires manual rewriting for natural speech, conservative chunking with `<bk>` markers, and generation through `chunktts`.

Together, these instruction contracts form the agent's orchestration layer. They express when a tool should be used, what input preparation is valid, what must not be inferred, and how tool outputs become inputs to study workflows.

== Core Tool Contracts


The core implementation repositories provide concrete execution guarantees:

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


Each core tool uses the same engineering style: explicit runtime configuration, stable exit codes, strict stdout/stderr separation where relevant, and deterministic handling of out-of-order network responses.

== Model and Provider Requirements


The OCR subsystem uses `allenai/olmOCR-2-7B-1025` as the primary model. The model is accessed through an OpenAI-compatible endpoint, which allows the same custom `openai` and `relay` foundation to support multimodal chat requests.

The model design space includes `google/gemma-4-31B-it` because it is a multimodal instruction-tuned model with JSON and function support on the same provider. Its large context window and agentic capabilities make it relevant for broader document-understanding and reasoning evaluation, even though the implemented OCR path uses olmOCR 2.

The RAG subsystem uses an OpenAI-compatible embeddings endpoint. The documented default in `chunkvec` is `Qwen/Qwen3-Embedding-0.6B` with 1024-dimensional embeddings. The TTS subsystem uses an OpenAI-compatible audio speech endpoint; the documented default in `chunktts` is `hexgrad/Kokoro-82M`.

== Requirements Traceability Matrix


#ref(<tbl:req-traceability>) maps the main requirements to implementation mechanisms.


#apa-figure(
  table(
    columns: 3,
    table.header([Requirement], [Agent/tool layer], [Core implementation mechanism]),
    [Select a study output mode],
    [`study-assistant` mode selection],
    [prepared source text consumed by the agent],
    [Extract PDF text],
    [`ocr-tool` workflow],
    [`pdfocr` rendering, WebP encoding, OCR request pipeline],
    [Preserve page order],
    [`ocr-tool` expects raw ordered text],
    [`pdfocr` sequence ids and staged JSONL emission],
    [Store material for retrieval],
    [`rag-tool` store mode],
    [`cvstore` chunk parser, embeddings pipeline, SQLite insert],
    [Search stored material],
    [`rag-tool` search mode],
    [`cvquery` query embedding and `sqlite-vector` nearest-neighbour search],
    [Produce speech audio],
    [`tts-tool` workflow],
    [`chunktts` chunk splitting, speech requests, audio validation],
    [Bound remote work],
    [tool execution guidance],
    [`relay` `maxInFlight`, retry queues, request-id codecs],
    [Parse and emit JSON safely],
    [tool configuration and outputs],
    [`jsonx` typed parsing and streaming JSON serialisation],
    [Use OpenAI-compatible APIs],
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
- model design-space discussion includes `allenai/olmOCR-2-7B-1025` and `google/gemma-4-31B-it`; and
- no component is presented as separate from the unified system design.

#import "../lib.typ": apa-figure

#let apa-table-align(x, y) = if y == 0 {
  center
} else if x == 0 {
  left
} else {
  center
}

= Verification, Testing, and Evaluation <chap:testing>


== Evaluation Methodology


The evaluation strategy reflects the system's mixed nature. Some properties are deterministic software properties and can be verified with unit or integration tests. Other properties depend on live remote models and are evaluated through recorded empirical runs. The methodology therefore separates:

- *contract verification:* CLI, parsing, schema, ordering, retry, database, and audio invariants;
- *pipeline verification:* bounded concurrency and successful artefact production under controlled or recorded conditions;
- *model evaluation:* OCR quality and cost on a fixed benchmark; and
- *operational evaluation:* throughput, memory, exit codes, and failure semantics.

This separation prevents model variability from obscuring local implementation correctness.

== Verification Matrix


#ref(<tbl:verification-matrix>) maps repositories to verification surfaces.


#apa-figure(
  table(
    columns: (1.25in, 3.25in, 1.5in),
    align: apa-table-align,
    table.header([Repository], [Verification surface], [Evidence type]),
    [`study-assistant`],
    [mode contracts and grounding rules],
    [instruction inspection],
    [`ocr-tool`],
    [OCR routing, cache procedure, extraction-only responsibility],
    [instruction and script inspection],
    [`rag-tool`],
    [store/search separation, chunking and metadata policy],
    [instruction inspection],
    [`tts-tool`],
    [speech rewriting and `<bk>` preparation],
    [instruction inspection],
    [`pdfocr`],
    [page selection, request ids, retry queue, error mapping, JSON schema],
    [deterministic unit tests],
    [`chunkvec`],
    [chunk parser, runtime config, embeddings client, SQLite/vector integration],
    [deterministic and integration tests],
    [`chunktts`],
    [chunk splitting, request ids, retry mapping, audio validation, pipeline integration],
    [deterministic and local-server tests],
    [`relay`],
    [lifecycle, ordering, request bodies, headers, batch helpers],
    [transport unit tests],
    [`jsonx`],
    [parser compliance, number parsing, object mapping],
    [parser/unit tests],
    [`openai`],
    [chat, embeddings, audio speech, retry helpers],
    [schema/unit tests],
  ),
  caption: [Repository verification matrix],
)<tbl:verification-matrix>


The instruction repositories do not have conventional unit tests because their primary artefacts are operational rules. They are validated by checking whether the rules map cleanly onto the executable contracts and whether they preserve source-grounding constraints.

== OCR Contract Verification


The OCR contract has the following properties:

- input is one PDF and exactly one page selector mode;
- page selection is sorted and duplicate-free after normalisation;
- stdout contains JSONL page records only;
- stderr contains logs and diagnostics;
- each selected page produces one page result on non-fatal completion;
- page-result order matches the normalised selection order;
- each result contains attempt count and status;
- error records have structured error kinds; and
- fatal startup/runtime failures produce exit code `3`.

The deterministic tests cover page selection, request-id packing, retry queue behaviour, retry/error mapping, and JSON result writing. Ordering is primarily enforced by construction: the pipeline emits only from `staged[nextEmitSeqId]` and increments that pointer monotonically.

== RAG Contract Verification


The RAG contract has storage and search components.

For storage:

- every chunk begins with a valid `<chunk ...>` marker;
- unknown marker attributes are rejected;
- empty chunk bodies are rejected;
- `doc` and `kind` are command-level metadata, not marker attributes;
- embeddings must match the configured dimension;
- database inserts occur inside a transaction; and
- already-stored chunks can be skipped.

For search:

- the query is embedded once;
- the vector extension is loaded explicitly;
- the vector column is initialised with a fixed dimension;
- filters are applied through SQL parameters;
- results are ordered by vector distance and row id; and
- rendered output includes enough metadata for inspection.

The SQLite/vector integration tests are especially important because they verify that the database schema, vector extension, insertion, and search path work together.

== TTS Contract Verification


The TTS contract is artefact-oriented:

- input is one text file and one output path;
- chunks are produced by splitting on `<bk>`;
- empty chunks are dropped;
- speech requests are bounded by `max_inflight`;
- transient failures are retried within the attempt bound;
- returned audio bytes are decoded and validated;
- sample rate and channel count must match across chunks; and
- the final `.opus` file is written only if all chunks succeed.

The local integration test uses a controlled HTTP server that simulates concurrency and retry pressure. It verifies that the pipeline reaches the expected maximum active request count, retries a chunk after an HTTP 429 response, and writes a valid output file with expected sample rate, channel count, and frame count.

== Shared Library Verification


`relay` is verified through tests for lifecycle contracts, request-body round trips, header parsing, single-request helpers, batch helpers, and ordering behaviour. This matters because all remote-model pipelines depend on relay's guarantee that request ids and result bodies are returned intact.

`jsonx` is verified through parser and compliance tests. The project relies on `jsonx` for configuration, API payloads, and output records, so JSON parser correctness is a cross-cutting reliability requirement.

`openai` is verified through tests for chat, embeddings, audio speech, and retry helpers. These tests validate request/response schema compatibility independent of the higher-level pipelines.

== OCR Throughput Evaluation


The main throughput benchmark uses a fixed 72-page slide PDF. #ref(<tbl:throughput>) reports the recorded results.


#apa-figure(
  table(
    columns: (1.8in, 1fr, 1fr, 1fr, 1fr),
    align: apa-table-align,
    table.header([Configuration], [Runtime], [Throughput], [Page results], [Exit status]),
    [Sequential baseline (`K=1`)],
    [316.66 s],
    [0.23 pages/s],
    [72/72 ok],
    [0],
    [Bounded concurrency (`K=32`)],
    [19.93 s],
    [3.61 pages/s],
    [72/72 ok],
    [0],
  ),
  caption: [OCR throughput benchmark],
)<tbl:throughput>


The speedup is:

$ S = frac(316.66, 19.93) = 15.89 $

The absolute reduction is:

$ 316.66 - 19.93 = 296.73 "s" $

The relative reduction is:

$ frac(296.73, 316.66) times 100 = 93.71 percent $

The result is consistent with the design. OCR requests are network-bound, so bounded concurrency overlaps provider latency while the main thread preserves ordering.

== OCR Model Evaluation


The 68-page scientific OCR benchmark uses locked human gold labels. The benchmark includes pages from 34 source PDFs and covers equations, tables, diagrams, and multi-column layouts. All evaluated models completed 68/68 pages.

#ref(<tbl:scientific-ocr-benchmark-accuracy>) and #ref(<tbl:scientific-ocr-benchmark-cost>) report the benchmark results. Short model names are used in the tables for layout; they correspond to `PaddlePaddle/PaddleOCR-VL-0.9B`, `allenai/olmOCR-2-7B-1025`, and `deepseek-ai/DeepSeek-OCR`.


#apa-figure(
  table(
    columns: (1.45in, 1fr, 1fr, 1.25in, 1fr),
    align: apa-table-align,
    table.header([Model], [CER], [WER], [ReadingOrderF1], [MathF1]),
    [PaddleOCR-VL],
    [0.4634],
    [0.4732],
    [0.3751],
    [0.7248],
    [olmOCR 2],
    [0.4682],
    [0.4893],
    [0.3252],
    [0.6743],
    [DeepSeek-OCR],
    [0.5862],
    [0.6512],
    [0.1452],
    [0.4684],
  ),
  caption: [Scientific OCR benchmark — accuracy],
)<tbl:scientific-ocr-benchmark-accuracy>



#apa-figure(
  table(
    columns: (1.45in, 1.5in, 1.5in),
    align: apa-table-align,
    table.header([Model], [Total cost (USD)], [Cost/page (USD)]),
    [PaddleOCR-VL],
    [0.0420],
    [0.0006180],
    [olmOCR 2],
    [0.0214],
    [0.0003142],
    [DeepSeek-OCR],
    [0.0041],
    [0.0000597],
  ),
  caption: [Scientific OCR benchmark — cost],
)<tbl:scientific-ocr-benchmark-cost>


The recorded interpretation is:

- `PaddlePaddle/PaddleOCR-VL-0.9B` gives the strongest strict-accuracy aggregate in this run.
- `allenai/olmOCR-2-7B-1025` gives the strongest recall-oriented aggregate.
- `deepseek-ai/DeepSeek-OCR` gives the lowest cost and strongest cost-efficiency-weighted score.

The selected OCR model, `allenai/olmOCR-2-7B-1025`, is appropriate for the study-assistant setting because recall-oriented behaviour is valuable when downstream workflows depend on complete educational content. A missing theorem, definition, or equation can produce a defective study artefact even when the remaining transcription has acceptable CER or WER.

== Model Design-Space Validation


The OCR model and broader multimodal design space were checked against provider documentation. DeepInfra lists `allenai/olmOCR-2-7B-1025` as a public FP8 multimodal model with JSON support, a 16,384-token context window, and per-token pricing. @ref-19 DeepInfra lists `google/gemma-4-31B-it` as a public FP8 multimodal model with JSON and function support, a 262,144-token context window, and multimodal capabilities. @ref-26

The system uses olmOCR 2 for OCR because the OCR subsystem is specialised for PDF page transcription and the benchmark data is OCR-specific. Gemma is included as a design-space model for multimodal instruction following and long-context agentic workflows, not as the primary OCR engine.

== RAG Evaluation Criteria


The RAG subsystem is not evaluated by question-answering accuracy in this report because its core implementation responsibility is retrieval infrastructure. The relevant evaluation criteria are:

- correctness of chunk parsing;
- preservation of source text in chunk bodies;
- metadata stability;
- embedding dimensionality validation;
- database persistence;
- search filter correctness;
- deterministic result ordering; and
- local search after ingest.

These criteria align with the system's role: `chunkvec` is a retrieval substrate, while `study-assistant` is the component that uses retrieved passages for generation.

== TTS Evaluation Criteria


The TTS subsystem is evaluated as an artefact pipeline. The main criteria are:

- successful transformation from marked text to ordered audio chunks;
- retry robustness for transient API failures;
- audio decodability;
- consistent audio format across chunks;
- correct `.opus` publication; and
- absence of partial final artefacts on failure.

Subjective naturalness is not evaluated directly because the project does not train or compare TTS models. The implementation assumes the provider model is responsible for acoustic quality and focuses on reliable preparation and assembly.

== Reliability Evaluation


The three model-calling tools share reliability mechanisms:

- bounded in-flight request limits;
- maximum attempt counts;
- retry queues ordered by due time;
- exponential backoff and jitter through shared retry helpers;
- transport and HTTP classification;
- abortive shutdown on fatal errors; and
- stable exit codes.

#ref(<tbl:failure-semantics>) summarises failure semantics.


#apa-figure(
  table(
    columns: (0.9in, 1.05in, 2.25in, 2.1in),
    align: apa-table-align,
    table.header([Tool], [Recoverable unit], [Permanent unit failure], [Fatal failure]),
    [`pdfocr`],
    [page],
    [emit error JSONL page record, exit `2` if any page failed],
    [exit `3`, stdout may be incomplete],
    [`cvstore`],
    [chunk],
    [commit successful rows, exit `2` if any chunk failed],
    [rollback transaction where possible, exit `3`],
    [`chunktts`],
    [chunk],
    [do not publish final audio, exit `2`],
    [exit `3`],
    [`cvquery`],
    [whole query],
    [not applicable as partial query output is not meaningful],
    [exit `3`],
  ),
  caption: [Failure semantics by tool],
)<tbl:failure-semantics>


These semantics are tailored to artefact type. Partial OCR can still be useful and auditable. Partial final speech audio is not published because it would appear complete while silently omitting content.

== Performance and Memory Interpretation


The benchmark evidence supports the claim that bounded concurrency improves throughput for OCR. It does not establish a universal speed guarantee. Performance depends on:

- provider latency;
- rate limits;
- local PDF rendering speed;
- WebP encoding speed;
- input page complexity;
- network conditions; and
- model response length.

Memory interpretation also requires care. Peak RSS is the appropriate process-level metric for comparing memory in recorded runs. Allocator-internal counters are useful diagnostics but are not equivalent to process peak memory.

== Threats to Validity


The main threats to validity are:

- *Provider variability:* remote model latency and behaviour can vary by time and deployment.
- *Dataset specificity:* the recorded OCR benchmark may not represent all study documents.
- *Single-run measurements:* recorded throughput runs do not report statistical variance.
- *Model drift:* hosted models and pricing can change.
- *No subjective TTS evaluation:* the project verifies artefact correctness, not listener preference.
- *No end-to-end learning-outcome study:* the report evaluates system behaviour, not educational outcomes with human participants.

These limitations do not invalidate the implementation results, but they define the scope of claims that can be made rigorously.

== Evaluation Findings


The verification evidence supports the system architecture. Local deterministic tests cover the core invariants. The TTS integration test demonstrates concurrency, retry, and audio finalisation under controlled conditions. The OCR throughput benchmark demonstrates the practical benefit of bounded concurrency. The scientific OCR benchmark provides model-level evidence for olmOCR 2 and situates it among measured alternatives.

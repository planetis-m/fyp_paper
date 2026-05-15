#import "../lib.typ": apa-figure
#import "../assets/diagrams.typ": *

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

== Verification Evidence Topology


#ref(<fig:verification-evidence>) maps repositories and evidence types to the evaluation claims they support.


#figure(
  verification-evidence-diagram(),
  kind: image,
  caption: [Verification evidence topology separating deterministic implementation evidence from empirical model and performance evidence.],
)<fig:verification-evidence>


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


The main throughput benchmark uses a fixed 72-page slide PDF. #ref(<fig:throughput>) reports the recorded result visually; exact values are repeated in Appendix #ref(<app:benchmarks-testcases>).


#figure(
  throughput-speedup-diagram(),
  kind: image,
  caption: [OCR throughput benchmark showing runtime reduction and throughput increase under bounded concurrency.],
)<fig:throughput>


The speedup is:

$ S = frac(316.66, 19.93) = 15.89 $

The absolute reduction is:

$ 316.66 - 19.93 = 296.73 "s" $

The relative reduction is:

$ frac(296.73, 316.66) times 100 = 93.71 percent $

The result is consistent with the design. OCR requests are network-bound, so bounded concurrency overlaps provider latency while the main thread preserves ordering.

== OCR Model Evaluation


The 68-page scientific OCR benchmark uses locked human gold labels. The benchmark includes pages from 34 source PDFs and covers equations, tables, diagrams, and multi-column layouts. All evaluated models completed 68/68 pages.

#ref(<fig:ocr-model-tradeoff>) summarises the model-selection trade-off. Exact CER, WER, reading-order, math, and cost values are reported in Appendix #ref(<app:benchmarks-testcases>). Short model names correspond to `PaddlePaddle/PaddleOCR-VL-0.9B`, `allenai/olmOCR-2-7B-1025`, and `deepseek-ai/DeepSeek-OCR`.


#figure(
  ocr-model-tradeoff-diagram(),
  kind: image,
  caption: [OCR model cost/quality trade-off used to justify the selected OCR model.],
)<fig:ocr-model-tradeoff>


The recorded interpretation is:

- `PaddlePaddle/PaddleOCR-VL-0.9B` gives the strongest strict-accuracy aggregate in this run.
- `allenai/olmOCR-2-7B-1025` gives the strongest recall-oriented aggregate.
- `deepseek-ai/DeepSeek-OCR` gives the lowest cost and strongest cost-efficiency-weighted score.

The selected OCR model, `allenai/olmOCR-2-7B-1025`, is justified by this trade-off. PaddleOCR-VL gives slightly stronger strict accuracy, but at a higher recorded cost; DeepSeek-OCR is cheapest, but its accuracy and structure metrics are substantially weaker. olmOCR 2 is therefore the most suitable choice for this project because it provides the strongest recall-oriented result while keeping cost below the strict-accuracy winner. In a study-assistant workflow, recall is especially important: a missing theorem, definition, or equation can produce a defective study artefact even when the remaining transcription has acceptable CER or WER.

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

#ref(<fig:failure-semantics>) summarises failure semantics.


#figure(
  failure-semantics-diagram(),
  kind: image,
  caption: [Failure semantics as branching publication behaviour across recoverable, permanent, and fatal failures.],
)<fig:failure-semantics>


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

== Technical Evaluation Findings


The technical verification evidence supports the system architecture. Local deterministic tests cover the core invariants. The TTS integration test demonstrates concurrency, retry, and audio finalisation under controlled conditions. The OCR throughput benchmark demonstrates the practical benefit of bounded concurrency. The scientific OCR benchmark provides model-level evidence for olmOCR 2 and situates it among measured alternatives. The following end-to-end workflow evaluation examines how these technical properties appear in student-facing use.

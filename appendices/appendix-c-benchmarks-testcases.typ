= Benchmarks and Test Cases <app:benchmarks-testcases>


This appendix consolidates benchmark and test artefacts supporting Chapter #ref(<chap:testing>).

== OCR Throughput Benchmark


The throughput benchmark uses a fixed 72-page slide deck PDF included in the OCR repository test assets.

Recorded results:

- Bounded concurrency (`max_inflight=32`): 19.93 seconds total runtime; 3.61 pages/s; 72/72 pages succeeded; exit status `0`.
- Sequential baseline (`K=1`): 316.66 seconds total runtime; 0.23 pages/s; 72/72 pages succeeded; exit status `0`.

Derived metrics:

#figure(
  table(
    columns: 2,
    align: horizon,
    inset: 5pt,
    table.header([Metric], [Value]),
    table.hline(),
    [Speedup],
    [15.89x],
    [Absolute time reduction],
    [296.73 s],
    [Relative time reduction],
    [93.71%],
  ),
  caption: [Derived OCR throughput metrics],
)


== Recorded OCR Implementation Comparison


A side-by-side recorded comparison uses the same 72-page test PDF and `--all-pages` selection mode.

#figure(
  table(
    columns: 3,
    align: horizon,
    inset: 5pt,
    table.header([Metric], [External reported run], [This project recorded run]),
    table.hline(),
    [Wall time],
    [17.04 s],
    [28.23 s],
    [Throughput],
    [~4.23 pages/s],
    [~2.55 pages/s],
    [Peak RSS],
    [71.51 MiB],
    [86.29 MiB],
    [Exit status],
    [0],
    [0],
    [Output validation],
    [full ordered JSONL],
    [72/72 ok, 0 retries, strict page order],
  ),
  caption: [Recorded OCR implementation comparison],
)


These observations are run-specific because OCR requests depend on live network and provider conditions. Peak RSS is the appropriate memory metric for process-level comparison; allocator-state snapshots are not equivalent to process peak memory.

== Scientific OCR Benchmark


The model-comparison benchmark uses a fixed 68-page academic dataset with locked human gold labels. The benchmark input is a consolidated PDF assembled from 34 source PDFs, two pages per source. The selected pages include equations, multi-column layouts, diagrams, and tables. @ref-25

All measured models completed 68/68 pages.

#figure(
  table(
    columns: 5,
    align: horizon,
    inset: 5pt,
    table.header([Model], [CER], [WER], [ReadingOrderF1], [MathF1]),
    table.hline(),
    [`PaddlePaddle/PaddleOCR-VL-0.9B`],
    [0.4634],
    [0.4732],
    [0.3751],
    [0.7248],
    [`allenai/olmOCR-2-7B-1025`],
    [0.4682],
    [0.4893],
    [0.3252],
    [0.6743],
    [`deepseek-ai/DeepSeek-OCR`],
    [0.5862],
    [0.6512],
    [0.1452],
    [0.4684],
  ),
  caption: [Scientific OCR benchmark accuracy results],
)


#figure(
  table(
    columns: 3,
    align: horizon,
    inset: 5pt,
    table.header([Model], [Total cost (USD)], [Cost/page (USD)]),
    table.hline(),
    [`PaddlePaddle/PaddleOCR-VL-0.9B`],
    [0.0420],
    [0.0006180],
    [`allenai/olmOCR-2-7B-1025`],
    [0.0214],
    [0.0003142],
    [`deepseek-ai/DeepSeek-OCR`],
    [0.0041],
    [0.0000597],
  ),
  caption: [Scientific OCR benchmark cost results],
)


Recorded conclusions:

- strict-accuracy winner: `PaddlePaddle/PaddleOCR-VL-0.9B`;
- recall-oriented winner: `allenai/olmOCR-2-7B-1025`;
- cost-first and balanced-score winner: `deepseek-ai/DeepSeek-OCR`.

== DeepInfra Model Context


DeepInfra lists `allenai/olmOCR-2-7B-1025` as a public FP8 multimodal model with JSON support, a 16,384-token context window, and per-token pricing. @ref-19

DeepInfra lists `google/gemma-4-31B-it` as a public FP8 multimodal model with JSON and function support, a 262,144-token context window, and per-token pricing. @ref-26

These model pages provide provider-side context for the OCR model and the broader multimodal design space.

== Repository Test Groups


The deterministic test groups are:

- `pdfocr`: page selection, request-id codec, retry queue, retry/error mapping, JSON result schema;
- `chunkvec`: chunk parsing, runtime configuration, request-id codec, embeddings client, SQLite/vector integration;
- `chunktts`: chunk splitting, request-id codec, retry/error mapping, speech client, audio wrapper, pipeline integration;
- `relay`: lifecycle contracts, ordering contract, headers, request-body round trip, batch helpers;
- `jsonx`: parsing, compliance, number handling, object mapping;
- `openai`: chat, embeddings, audio speech, retry helpers.

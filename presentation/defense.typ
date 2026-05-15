// Final Year Project defense deck
// Compile with:
//   typst compile defense.typ defense.pdf

#import "deck/theme.typ": *
#import "deck/components.typ": *

#set document(title: title-text, author: author)
#set page(
  width: slide-size.width,
  height: slide-size.height,
  margin: page-margin,
  fill: paper,
  footer: context [
    #set text(size: 5.1pt, fill: faint)
    #grid(
      columns: (1fr, auto),
      align: (left, right),
      [Final Year Project Defense],
      [#counter(page).display()],
    )
  ],
)
#set text(font: font-sans, size: text-size, fill: ink)
#set par(leading: body-leading, spacing: body-spacing, justify: false)
#set list(indent: 0.54em, body-indent: 0.42em, spacing: 0.34em)
#set enum(indent: 0.54em, body-indent: 0.42em, spacing: 0.34em)
#set table(stroke: 0.35pt + line-color, inset: table-inset)
#show raw.where(block: false): set text(font: font-mono, size: 7.8pt)
#show table: set text(size: 6.95pt)

// 1
#block[
  #v(0.18cm)
  #grid(columns: (1fr, auto), align: (left, right))[
    #text(size: 7.2pt, weight: "bold", fill: muted)[FINAL YEAR PROJECT DEFENSE]
  ][
    #text(size: 7.2pt, fill: muted)[#date]
  ]
  #v(0.54cm)
  #block(width: 12.4cm)[
    #text(size: 22.3pt, weight: "bold", fill: ink)[
      An Agent-Based Study Assistant System
    ]
    #v(0.20cm)
    #text(size: 12.3pt, weight: "semibold", fill: accent-dark)[
      with OCR, Retrieval-Augmented Generation, and Text-to-Speech Tools
    ]
  ]
  #v(0.64cm)
  #line(length: 4.7cm, stroke: 0.55pt + accent)
  #v(0.52cm)
  #grid(columns: (1fr, 1fr), gutter: 0.56cm)[
    #block[
      #text(size: 6.5pt, weight: "bold", fill: muted)[CANDIDATE]
      #v(0.08cm)
      #text(size: 9pt, weight: "semibold")[#author]
      #v(0.22cm)
      #text(size: 6.5pt, weight: "bold", fill: muted)[PROJECT ADVISOR]
      #v(0.08cm)
      #text(size: 8.2pt)[#advisor]
    ]
  ][
    #block[
      #text(size: 6.5pt, weight: "bold", fill: muted)[DEGREE PROGRAM]
      #v(0.08cm)
      #text(size: 8pt)[#degree]
      #v(0.18cm)
      #text(size: 7.3pt, fill: muted)[#department]
      #v(0.04cm)
      #text(size: 7.3pt, fill: muted)[#school]
      #v(0.04cm)
      #text(size: 7.3pt, fill: muted)[#university]
    ]
  ]
]

#pagebreak()

// 2
#slide("Problem Context")[
  #v(0.10cm)
  #text(size: 10.6pt, weight: "bold", fill: accent)[Study material is fragmented across formats and revision tasks]
  #v(0.30cm)
  #flow(("PDF / notes", "OCR", "RAG store", "Study modes", "Audio"))
  #v(0.34cm)
  #grid(columns: (1.06fr, 0.94fr), gutter: 0.5cm)[
    #spacious-list(size: 7.5pt)[
      - Converts difficult source material into usable text
      - Stores prepared content for semantic search
      - Generates study artefacts: notes, flashcards, quizzes, essays
      - Produces listenable `.opus` revision audio
      - Keeps OCR, retrieval, generation, and speech as distinct responsibilities
    ]
  ][
    #card("Core thesis", [
      AI study support is most useful when it is source-grounded, modular, and inspectable rather than a single unstructured prompt.
    ], fill: soft, height: 2.15cm)
  ]
]

#pagebreak()

// 3
#slide("Problem Statement")[
  #v(0.14cm)
  #grid(columns: (1fr, 1fr, 1fr), gutter: 0.28cm)[
    #card("Input readiness", [
      Scanned slides, textbook pages, and PDFs are often visually readable but not directly searchable or usable by language tools.
    ], fill: warm, height: 2.45cm)
  ][
    #card("Grounded access", [
      Long or fragmented notes exceed convenient prompt use and need retrieval from the student's own sources.
    ], height: 2.45cm)
  ][
    #card("Output form", [
      Effective revision needs several forms: explanations, active recall, essay practice, and audio.
    ], fill: warm, height: 2.45cm)
  ]
  #v(0.5cm)
  #align(center)[
    #text(size: 12pt, weight: "bold", fill: accent)[Design challenge]
    #v(0.12cm)
    Build a study assistant that moves from raw course material to reliable, reusable study artefacts without losing source grounding.
  ]
]

#pagebreak()

// 4
#slide("Objectives")[
  #v(content-nudge)
  #grid(columns: (1fr, 1fr), gutter: wide-col-gutter)[
    #subhead[Functional objectives]
    #spacious-list[
      - Support transcription, notes, lecture explanation, ELI5, flashcards, mind maps, quizzes, and essays
      - Use OCR when source material is PDF-based or scanned
      - Store and retrieve semantic chunks from prepared material
      - Convert selected material into natural spoken audio
    ]
  ][
    #subhead[Engineering objectives]
    #spacious-list[
      - Preserve deterministic ordering despite asynchronous model calls
      - Bound concurrency and retry transient failures
      - Keep stdout artefacts separate from diagnostics
      - Make OCR, RAG, and TTS usable both inside and outside the agent
    ]
  ]
]

#pagebreak()

// 5
#slide("Research Questions and Scope")[
  #v(content-nudge)
  #grid(columns: (1.15fr, 0.85fr), gutter: wide-col-gutter)[
    #subhead[Research questions]
    #spacious-list[
      - How can an agent coordinate OCR, retrieval, generation, and speech without hiding the processing steps?
      - Which software contracts are needed to make model-based study workflows auditable?
      - What operational evidence shows that the system is practical for realistic revision material?
    ]
  ][
    #card("Scope", [
      The project evaluates system design, reliability, throughput, and recorded study workflows.
    ], fill: soft)
    #v(related-stack-gap)
    #card("Boundary", [
      It does not claim measured grade improvement or replace student judgement over generated artefacts.
    ], fill: warm)
  ]
]

#pagebreak()

#section-slide("Foundation", "Background, requirements, and the study-workflow framing")

#pagebreak()

#slide("Background and Related Work")[
  #v(0.12cm)
  #grid(columns: (1fr, 1fr, 1fr), gutter: card-grid-gutter)[
    #card("OCR", [
      Converts visual document pages into machine-readable text. Evaluation must consider not only CER/WER but also reading order, tables, equations, and recall.
    ], fill: warm, height: 2.55cm)
  ][
    #card("RAG", [
      Combines language generation with retrieved passages from an external corpus, allowing answers and artefacts to remain tied to source material.
    ], height: 2.55cm)
  ][
    #card("TTS", [
      Turns prepared text into audio, but requires speech-oriented rewriting so markdown, formulae, and technical notation remain understandable.
    ], fill: warm, height: 2.55cm)
  ]
  #v(0.36cm)
  #card("Positioning", [
    Existing AI study tools often focus on summarisation. This project treats study assistance as a coordinated lifecycle: prepare, retrieve, transform, practise, and listen.
  ])
]

#pagebreak()

// 8
#slide("Requirements and Specification")[
  #v(content-nudge)
  #grid(columns: (1fr, 1fr), gutter: two-col-gutter)[
    #subhead[User-facing requirements]
    #spacious-list[
      - Work from PDFs, text, Markdown, stored document IDs, or raw source text
      - Produce concise, mode-specific study artefacts
      - Avoid unsupported external content during transformations
      - Make intermediate artefacts auditable
    ]
  ][
    #subhead[Tool contracts]
    #table(
      columns: (1fr, 1.2fr),
      table.header([*Tool*], [*Contract*]),
      [`pdfocr`], [Ordered JSONL page results],
      [`chunkvec`], [Marked chunks -> SQLite vector store],
      [`chunktts`], [Ordered chunks -> complete `.opus` file],
    )
  ]
]

#pagebreak()

#section-slide("Method and System Design", "Evaluation method, architecture, and auditable artefact contracts")

#pagebreak()

// 9
#slide("Methodology")[
  #v(content-nudge)
  #grid(columns: (1fr, 1fr), gutter: wide-col-gutter)[
    #subhead[Common model-calling pattern]
    #spacious-list[
      1. Parse and normalise CLI/configuration
      2. Convert input into ordered work items
      3. Assign deterministic request IDs
      4. Submit bounded batches through `relay`
      5. Classify success, retryable failure, or terminal failure
      6. Finalise in source order or database transaction
    ]
  ][
    #subhead[Correctness invariants]
    #spacious-list[
      - `inFlightCount <= K`
      - request ID encodes sequence and attempt
      - retry queues are ordered by due time
      - stdout remains machine-readable
      - API schemas are built through typed helpers
      - configuration values are normalised into safe ranges
    ]
  ]
]

#pagebreak()

// 10
#slide("System Architecture")[
  #surface[
    #grid(columns: (0.92fr, auto, 1.12fr, auto, 0.92fr), gutter: 0.16cm, align: horizon)[
      #lane("input", [Student request + material], fill: warm)
    ][#text(size: 9pt, fill: accent)[→]][
      #lane("orchestration", [study-assistant selects the mode], fill: soft)
    ][#text(size: 9pt, fill: accent)[→]][
      #lane("output", [Study artefact or audio], fill: warm)
    ]
    #v(0.26cm)
    #line(length: 100%, stroke: 0.32pt + line-color)
    #v(0.22cm)
    #grid(columns: (1fr, 1fr, 1fr), gutter: 0.24cm)[
      #lane("OCR path", [ocr-tool → pdfocr → ordered JSONL], fill: white)
    ][
      #lane("RAG path", [rag-tool → chunkvec → SQLite vectors], fill: white)
    ][
      #lane("TTS path", [tts-tool → chunktts → final .opus], fill: white)
    ]
    #v(0.2cm)
    #text(size: 6.9pt, fill: muted)[Shared libraries provide bounded HTTP execution, typed JSON handling, and provider request schemas.]
  ]
  #v(0.2cm)
  #text(size: 7pt, fill: muted)[The visual split is deliberate: the agent owns study intent; the tools own deterministic processing contracts.]
]

#pagebreak()

// 11
#slide("Design Decisions")[
  #v(0.06cm)
  #grid(columns: (1fr, 1fr), gutter: two-col-gutter)[
    #card("1. Agent orchestration, deterministic tools", [
      The agent handles study intent. Core tools handle stable execution contracts, retries, schemas, and artefact publication.
    ], fill: soft, height: 1.9cm)
    #v(card-stack-gap)
    #card("2. Standalone command-line tools", [
      Each processing stage can be inspected, tested, redirected, cached, or reused without the full assistant.
    ], fill: warm, height: 1.9cm)
  ][
    #card("3. Ordered output over raw speed", [
      Results may complete out of order, but OCR pages and audio chunks are published in source order.
    ], fill: warm, height: 1.9cm)
    #v(card-stack-gap)
    #card("4. Explicit failure semantics", [
      Partial OCR is auditable; partial final audio is withheld because it would look complete while omitting content.
    ], fill: soft, height: 1.9cm)
  ]
]

#pagebreak()

// 12
#slide("Implementation Highlights")[
  #v(0.08cm)
  #grid(columns: (1fr, 1fr, 1fr), gutter: 0.24cm)[
    #card("pdfocr", [
      PDFium rendering, WebP encoding, multimodal OCR requests, page-level JSONL, retry/error classification.
    ], fill: warm, height: 2.28cm)
  ][
    #card("chunkvec", [
      Strict `<chunk ...>` parser, embeddings pipeline, SQLite storage, metadata filters, vector search.
    ], height: 2.28cm)
  ][
    #card("chunktts", [
      `<bk>` chunk splitting, speech API requests, WAV decoding, audio validation, final Opus assembly.
    ], fill: warm, height: 2.28cm)
  ]
  #v(0.3cm)
  #grid(columns: (1fr, 1fr, 1fr), gutter: 0.24cm)[
    #card("relay", [Worker thread over libcurl multi; bounded concurrent request execution.], height: 1.9cm)
  ][
    #card("jsonx", [Centralised typed JSON parsing and streaming writers.], fill: soft, height: 1.9cm)
  ][
    #card("openai", [Transport-transparent request schemas for chat, embeddings, and speech.], height: 1.9cm)
  ]
]

#pagebreak()

// 13
#slide("User Workflow")[
  #eyebrow[A realistic revision path]
  #v(0.16cm)
  #flow(("Lecture PDF", "OCR extract", "Clean text", "Generate notes", "Prepare speech", "Audio file"))
  #v(flow-gap)
  #grid(columns: (1.05fr, 0.95fr), gutter: two-col-gutter)[
    #note-box([
      #text(weight: "bold", fill: accent-dark)[Supported modes]
      #v(0.16cm)
      #grid(columns: (1fr, 1fr), gutter: 0.18cm)[
        #set par(leading: 0.86em)
        #set list(spacing: 0.28em)
        #text(size: 6.45pt)[
          - transcribe: preserve source text
          - lecture: formal explanation
          - eli5: simpler explanation
          - flashcard: active recall
        ]
      ][
        #set par(leading: 0.86em)
        #set list(spacing: 0.28em)
        #text(size: 6.45pt)[
          - mindmap: concept hierarchy
          - quiz: practice questions
          - essay: exam prompts
          - study-notes: revision notes
        ]
      ]
    ], height: 2.55cm)
  ][
    #note-box([
      #text(weight: "bold", fill: accent-dark)[Demo scenario]
      #v(0.16cm)
      #spacious-list(size: 7pt)[
        - Use OCR on lecture slides
        - Generate study notes
        - Rewrite notation and headings for speech
        - Synthesize 24 ordered chunks
        - Publish one `.opus` revision artefact
      ]
    ], fill: warm, height: 2.55cm)
  ]
]

#pagebreak()

// 14
#slide("Recorded Workflow Protocol")[
  #v(0.08cm)
  #grid(columns: (0.95fr, 1.05fr), gutter: two-col-gutter)[
    #eyebrow[Demonstration protocol]
    #v(0.16cm)
    #surface[
      #spacious-list[
        1. Select a lecture PDF
        2. Run OCR or use cached extraction
        3. Ask for a specific mode, e.g. flashcards
        4. Show output grounded in extracted content
        5. Store a textbook section in RAG
        6. Search for a targeted concept
        7. Convert generated notes into audio
      ]
    ]
  ][
    #card("Interpretation focus", [
      The evidence is not one generated answer. Each step creates an inspectable artefact, and later stages reuse the student's own material.
    ], fill: soft)
    #v(related-stack-gap)
    #card("Recorded evidence", [
      Workflows were recorded for essay practice, RAG exam revision, flashcards, and study-notes-to-audio.
    ], fill: warm)
  ]
]

#pagebreak()

#section-slide("Evaluation", "Contract tests, operational benchmarks, and recorded study workflows")

#pagebreak()

#slide("Testing Strategy")[
  #v(content-nudge)
  #grid(columns: (1fr, 1fr), gutter: two-col-gutter)[
    #subhead[Verified software contracts]
    #spacious-list[
      - `pdfocr`: page selection, request IDs, retry queue, JSON schema
      - `chunkvec`: chunk parser, config, embeddings, SQLite/vector integration
      - `chunktts`: splitting, retries, audio wrapper, local-server pipeline test
      - `relay`: lifecycle, ordering, request bodies, headers
      - `jsonx` and `openai`: parser and schema tests
    ]
  ][
    #subhead[Why this matters]
    #spacious-list[
      - Separates implementation correctness from provider/model variability
      - Tests deterministic invariants locally
      - Treats live model benchmarks as empirical operational evidence
      - Makes failure modes visible through stable exit codes and artefacts
    ]
  ]
]

#pagebreak()

// 17
#slide("Evaluation: OCR Throughput")[
  #grid(columns: (0.92fr, 1.08fr), gutter: wide-col-gutter)[
    #eyebrow[72-page slide PDF benchmark]
    #v(0.12cm)
    #big-statement[Bounded concurrency turns OCR from a waiting problem into an ordered batch process.]
    #v(0.22cm)
    #metric("15.89x", "speedup", note: "bounded concurrency vs sequential", fill: soft)
    #v(0.18cm)
    #metric("93.71%", "relative time reduction", note: "296.73 seconds saved", fill: warm)
  ][
    #surface[
      #eyebrow[Runtime comparison]
      #v(0.2cm)
      #bar("Sequential K=1", 316.66, 316.66, color: danger)
      #v(0.2cm)
      #bar("Concurrent K=32", 19.93, 316.66, color: accent)
      #v(0.32cm)
      #table(
        columns: (1.2fr, 1fr, 1fr),
        table.header([*Config*], [*Runtime*], [*Result*]),
        [K=1], [316.66 s], [72/72 ok],
        [K=32], [19.93 s], [72/72 ok],
      )
      #v(0.16cm)
      #text(size: 6.8pt, fill: muted)[All pages succeeded in both runs; the improvement comes from overlapping network-bound OCR requests.]
    ]
  ]
]

#pagebreak()

// 18
#slide("Evaluation: OCR Model Benchmark")[
  #grid(columns: (1.18fr, 0.82fr), gutter: two-col-gutter)[
    #surface[
      #eyebrow[Accuracy-oriented comparison]
      #v(0.16cm)
      #table(
        columns: (1.25fr, .72fr, .72fr, .9fr, .72fr),
        table.header([*Model*], [*CER*], [*WER*], [*Order F1*], [*Math F1*]),
        [PaddleOCR-VL], [0.4634], [0.4732], [0.3751], [0.7248],
        [olmOCR 2], [0.4682], [0.4893], [0.3252], [0.6743],
        [DeepSeek-OCR], [0.5862], [0.6512], [0.1452], [0.4684],
      )
      #v(0.22cm)
      #eyebrow[Cost comparison]
      #v(0.16cm)
      #table(
        columns: (1.3fr, .9fr, .9fr),
        table.header([*Model*], [*Total cost*], [*Cost/page*]),
        [PaddleOCR-VL], [\$0.0420], [\$0.0006180],
        [olmOCR 2], [\$0.0214], [\$0.0003142],
        [DeepSeek-OCR], [\$0.0041], [\$0.0000597],
      )
    ]
  ][
    #card("Dataset", [
      68 pages from 34 academic PDFs with locked human gold labels; includes equations, tables, diagrams, and multi-column layouts.
    ], fill: soft)
    #v(card-stack-gap)
    #card("Interpretation", [
      PaddleOCR-VL wins strict accuracy. olmOCR 2 is selected for recall-oriented study workflows. DeepSeek-OCR is strongest on cost.
    ], fill: warm)
  ]
]

#pagebreak()

// 19
#slide("Workflow Evaluation Results")[
  #v(0.06cm)
  #grid(columns: (1fr, 1fr), gutter: 0.38cm)[
    #card("Essay practice", [
      Association Analysis slides produced 4 exam-style essay questions with sample answers covering Apriori, support, confidence, lift, and interestingness.
    ], fill: warm, height: 1.95cm)
    #v(content-nudge)
    #card("RAG exam revision", [
      Textbook pages 358-402 were OCR-processed and stored as 26 semantic chunks; search retrieved zero-probability handling for Naive Bayes.
    ], fill: panel, height: 1.95cm)
  ][
    #card("Flashcards", [
      Anomaly Detection slides produced 25 front/back flashcards covering definitions, settings, measures, limitations, and applications.
    ], fill: panel, height: 1.95cm)
    #v(content-nudge)
    #card("Study notes to audio", [
      Clustering notes became a 7.3 KB Markdown artefact, a 7.2 KB TTS input, and a 2.1 MB `.opus` file from 24 speech chunks.
    ], fill: warm, height: 1.95cm)
  ]
]

#pagebreak()

// 20
#slide("Discussion and Limitations")[
  #v(content-nudge)
  #grid(columns: (1fr, 1fr), gutter: two-col-gutter)[
    #subhead[Interpretation]
    #spacious-list[
      - Modularity makes AI study workflows easier to inspect and test
      - Artefact boundaries are a practical reliability mechanism
      - Bounded concurrency is valuable for network-bound OCR
      - Retrieval quality depends on disciplined chunking and metadata
    ]
  ][
    #subhead[Limitations]
    #spacious-list[
      - No controlled study of learning outcomes or retention
      - OCR and generation quality still depend on external models
      - RAG evaluation focuses on retrieval infrastructure, not answer grading
      - Recorded workflows demonstrate feasibility rather than broad deployment
    ]
  ]
]

#pagebreak()

// 21
#slide("Contributions")[
  #v(0.06cm)
  #grid(columns: (1fr, 1fr), gutter: two-col-gutter)[
    #card("Conceptual", [
      Frames study assistance as a source-grounded workflow from raw material to revision artefacts.
    ], fill: soft, height: 1.7cm)
    #v(card-stack-gap)
    #card("Architectural", [
      Separates agent orchestration, tool definitions, core Nim executables, and shared libraries.
    ], fill: warm, height: 1.7cm)
  ][
    #card("Technical", [
      Implements OCR, semantic retrieval, and speech pipelines with deterministic ordering, retries, schemas, and exit contracts.
    ], fill: warm, height: 1.7cm)
    #v(card-stack-gap)
    #card("Evaluation", [
      Provides contract tests, throughput evidence, scientific OCR model comparison, and recorded student workflow artefacts.
    ], fill: soft, height: 1.7cm)
  ]
]

#pagebreak()

// 22
#slide("Future Work")[
  #v(content-nudge)
  #grid(columns: (1fr, 1fr), gutter: two-col-gutter)[
    #subhead[Engineering extensions]
    #spacious-list[
      - Deterministic mocked transport tests across all model-calling tools
      - Broader OCR benchmark corpora and repeated measurements
      - Richer retrieval evaluation with labelled queries
      - Provider/model selection policies per cost, latency, and privacy
    ]
  ][
    #subhead[Educational extensions]
    #spacious-list[
      - Human evaluation of study artefact usefulness
      - Learning-outcome studies for retention and exam preparation
      - Local/private model backends for sensitive course material
      - Additional modes for accessibility and instructor-authored rubrics
    ]
  ]
]

#pagebreak()

// 23
#slide("Conclusion")[
  #grid(columns: (1.05fr, 0.95fr), gutter: wide-col-gutter)[
    #text(size: 11pt, weight: "bold", fill: accent)[Main conclusion]
    #v(0.18cm)
    #big-statement[`study-assistant` demonstrates that OCR, RAG, and TTS can be integrated into a practical, inspectable study workflow when the system is built around source grounding and explicit processing contracts.]

    #v(0.28cm)
    #spacious-list[
      - The architecture is modular and reusable
      - The implementation is testable through artefact contracts
      - Bounded concurrency gives a measured OCR throughput gain
      - Recorded workflows show useful student-facing transformations
    ]
  ][
    #metric("72/72", "OCR pages succeeded", note: "throughput benchmark", fill: warm)
    #v(content-nudge)
    #metric("26", "semantic RAG chunks", note: "textbook revision workflow")
    #v(content-nudge)
    #metric("24", "speech chunks", note: "notes-to-audio workflow", fill: warm)
  ]
]

#pagebreak()

// 24
#block[
  #v(1.02cm)
  #line(length: 1.45cm, stroke: 0.65pt + accent)
  #v(0.36cm)
  #text(size: 25pt, weight: "bold", fill: ink)[Questions]
  #v(0.42cm)
  #block(width: 11.4cm)[
    #text(size: 9.8pt, weight: "semibold")[#title-text]
    #v(0.24cm)
    #text(size: 7.8pt, fill: muted)[#author]
    #v(0.08cm)
    #text(size: 7.3pt, fill: muted)[#institution]
  ]
]

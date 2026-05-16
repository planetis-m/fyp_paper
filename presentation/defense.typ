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
      Mnemon: An Agent-Based Study Assistant
    ]
    #v(0.20cm)
    #text(size: 12.3pt, weight: "semibold", fill: accent-dark)[
      with OCR, Retrieval, and Speech
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
  #v(0.08cm)
  #big-statement[Study is repeated transformation of fragmented course material.]
  #v(0.28cm)
  #flow(("PDFs / scans", "Prepared text", "Searchable sources", "Study artefacts", "Audio revision"))
  #v(0.34cm)
  #grid(columns: (1.04fr, 0.96fr), gutter: wide-col-gutter)[
    #spacious-list(size: 7.45pt)[
      - Students revise from lecture slides, scans, textbook extracts, notes, and copied fragments
      - The same source must become notes, explanations, flashcards, quizzes, essay practice, or audio
      - General chat alone hides provenance and makes long material hard to control
      - Useful AI study support must remain source-grounded, modular, and inspectable
    ]
  ][
    #card("Core thesis", [
      AI assistance is most useful when it coordinates the study workflow around the student's own material, rather than treating generation as a single unstructured prompt.
    ], fill: soft, height: 2.45cm)
  ]
]

#pagebreak()

// 3
#slide("Problem Statement")[
  #v(0.08cm)
  #grid(columns: (1fr, 1fr, 1fr), gutter: 0.28cm)[
    #card("1. Input readiness", [
      Scanned slides and PDFs may be readable to a student but unusable by language tools until OCR produces text.
    ], fill: warm, height: 2.35cm)
  ][
    #card("2. Grounded access", [
      Long or fragmented notes require retrieval from prepared sources instead of uncontrolled prompting.
    ], height: 2.35cm)
  ][
    #card("3. Output form", [
      Revision requires different artefacts: explanation, active recall, essay practice, and listening.
    ], fill: warm, height: 2.35cm)
  ]
  #v(0.44cm)
  #align(center)[
    #text(size: 12pt, weight: "bold", fill: accent)[Design challenge]
    #v(0.12cm)
    #block(width: 11.2cm)[
      Build a study assistant that moves from raw course material to source-grounded, reusable study artefacts.
    ]
  ]
]

#pagebreak()

// 4
#slide("Aim, Objectives, and Scope")[
  #v(content-nudge)
  #grid(columns: (1.06fr, 0.94fr), gutter: wide-col-gutter)[
    #subhead[Aim and objectives]
    #spacious-list[
      - Coordinate OCR, retrieval, generation, and speech around realistic revision workflows
      - Preserve source grounding across transformations
      - Expose OCR, RAG, and TTS as standalone, inspectable tools
      - Evaluate reliability, throughput, model suitability, and workflow feasibility
    ]
  ][
    #subhead[Claim boundary]
    #spacious-list[
      - System-design and engineering thesis
      - No claim of measured grade improvement
      - No replacement for instructor feedback or student judgement
      - Remote model quality, latency, cost, and privacy remain practical constraints
    ]
  ]
]

#pagebreak()

// 5
#slide("Study Workflow Requirements")[
  #v(0.12cm)
  #grid(columns: (1fr, 1fr, 1fr), gutter: card-grid-gutter)[
    #card("OCR", [
      Converts visual material into text. For study, quality includes order, equations, tables, and omissions.
    ], fill: warm, height: 2.25cm)
  ][
    #card("RAG", [
      Stores and retrieves the student's prepared material so answers remain tied to course-specific sources.
    ], height: 2.25cm)
  ][
    #card("TTS", [
      Turns prepared text into speech, after rewriting visual notation into a natural listening form.
    ], fill: warm, height: 2.25cm)
  ]
  #v(0.34cm)
  #surface[
    #grid(columns: (1fr, 1fr, 1fr), gutter: 0.22cm)[
      #lane("pdfocr", [ordered JSONL page records], fill: white)
    ][
      #lane("chunkvec", [marked chunks in SQLite vector store], fill: white)
    ][
      #lane("chunktts", [complete ordered `.opus` artefact], fill: white)
    ]
    #v(0.16cm)
    #text(size: 6.9pt, fill: muted)[Each capability leaves an inspectable artefact rather than disappearing into a chat transcript.]
  ]
]

#pagebreak()

// 6
#slide("Architecture: Flexible Agent, Deterministic Tools")[
  #surface[
    #grid(columns: (0.92fr, auto, 1.12fr, auto, 0.92fr), gutter: 0.16cm, align: horizon)[
      #lane("input", [Student request + material], fill: warm)
    ][#text(size: 9pt, fill: accent)[->]][
      #lane("orchestration", [study-assistant selects one mode], fill: soft)
    ][#text(size: 9pt, fill: accent)[->]][
      #lane("output", [Study artefact or audio], fill: warm)
    ]
    #v(0.25cm)
    #line(length: 100%, stroke: 0.32pt + line-color)
    #v(0.22cm)
    #grid(columns: (1fr, 1fr, 1fr), gutter: 0.24cm)[
      #lane("input readiness", [ocr-tool -> pdfocr -> ordered JSONL], fill: white)
    ][
      #lane("grounded access", [rag-tool -> chunkvec -> SQLite vectors], fill: white)
    ][
      #lane("output modality", [tts-tool -> chunktts -> final audio], fill: white)
    ]
  ]
  #v(0.24cm)
  #grid(columns: (1fr, 1fr), gutter: two-col-gutter)[
    #card("Agent role", [
      Interpret study intent and select a mode such as transcription, notes, flashcards, quiz, essay, or audio.
    ], fill: soft, height: 1.45cm)
  ][
    #card("Tool role", [
      Enforce schemas, ordering, retries, exit codes, and artefact publication.
    ], fill: warm, height: 1.45cm)
  ]
]

#pagebreak()

// 7
#slide("Engineering Decisions")[
  #v(0.04cm)
  #grid(columns: (1fr, 1fr), gutter: two-col-gutter)[
    #card("Agent orchestration, deterministic tools", [
      The agent owns study intent; tools own processing contracts, retries, schemas, and publication.
    ], fill: soft, height: 1.76cm)
    #v(card-stack-gap)
    #card("Standalone command-line stages", [
      OCR, retrieval, and speech can be run, inspected, cached, redirected, or tested independently.
    ], fill: warm, height: 1.76cm)
    #v(card-stack-gap)
    #card("Shared infrastructure", [
      Nim tools share `relay`, `jsonx`, and `openai` for HTTP execution, JSON handling, and provider schemas.
    ], fill: panel, height: 1.76cm)
  ][
    #card("Ordered output over maximum raw speed", [
      Concurrent requests may complete out of order, but published pages and chunks preserve source order.
    ], fill: warm, height: 1.76cm)
    #v(card-stack-gap)
    #card("Artefact-specific failure semantics", [
      Partial OCR can be auditable; partial final audio is withheld because it may appear complete while omitting content.
    ], fill: soft, height: 1.76cm)
    #v(card-stack-gap)
    #card("Evaluation consequence", [
      Behaviour can be checked through process channels, schemas, exit codes, stored artefacts, and ordered outputs.
    ], fill: panel, height: 1.76cm)
  ]
]

#pagebreak()

// 8
#slide("Workflow Evaluation Method")[
  #v(0.08cm)
  #flow(("PDF", "OCR text", "Study mode output", "RAG search", "Speech artefact"))
  #v(0.34cm)
  #grid(columns: (0.98fr, 1.02fr), gutter: wide-col-gutter)[
    #subhead[Evaluation criteria]
    #spacious-list[
      - Source grounding against prepared material
      - Appropriateness to the selected study mode
      - Inspectable intermediate artefacts
      - Operational reproducibility of the run
      - Visible limitations rather than hidden failures
    ]
  ][
    #subhead[Recorded workflows]
    #grid(columns: (1fr, 1fr), gutter: 0.22cm)[
      #card("Essay practice", [Association Analysis slides -> exam prompts and sample answers], fill: warm, height: 1.78cm)
    ][
      #card("RAG revision", [Textbook section -> stored chunks -> targeted Naive Bayes search], height: 1.78cm)
    ]
    #v(0.2cm)
    #grid(columns: (1fr, 1fr), gutter: 0.22cm)[
      #card("Flashcards", [Anomaly Detection slides -> active-recall cards], height: 1.78cm)
    ][
      #card("Notes to audio", [Clustering notes -> speech-ready text -> final audio], fill: warm, height: 1.78cm)
    ]
  ]
]

#pagebreak()

// 9
#slide("Testing Strategy and Evaluation Credibility")[
  #v(content-nudge)
  #grid(columns: (1fr, 1fr), gutter: two-col-gutter)[
    #subhead[Deterministic evidence]
    #spacious-list[
      - `pdfocr`: page selection, request IDs, retry queue, JSON result schema
      - `chunkvec`: chunk parser, embeddings configuration, SQLite/vector integration
      - `chunktts`: chunk splitting, retry pressure, audio validation, finalisation
      - `relay`, `jsonx`, `openai`: transport, parsing, and provider-schema helpers
    ]
  ][
    #subhead[Evaluation principle]
    #spacious-list[
      - Separate local implementation correctness from live provider variability
      - Use live model runs as empirical operational evidence
      - Verify that local tools still preserve ordering, failure semantics, and artefact boundaries
      - Treat limitations as part of the evidence, not as an afterthought
    ]
  ]
]

#pagebreak()

// 10
#slide("Evaluation: OCR Throughput")[
  #grid(columns: (0.92fr, 1.08fr), gutter: wide-col-gutter)[
    #eyebrow[72-page slide PDF benchmark]
    #v(0.12cm)
    #big-statement[Bounded concurrency made recorded OCR throughput practical while preserving ordered output.]
    #v(0.22cm)
    #metric("15.89x", "speedup", note: "K=32 vs sequential K=1", fill: soft)
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
      #v(0.14cm)
      #text(size: 6.55pt, fill: muted)[Operational measurement; depends on provider latency, rate limits, network conditions, and document complexity.]
    ]
  ]
]

#pagebreak()

// 11
#slide("Evaluation: OCR Model Benchmark")[
  #grid(columns: (1.15fr, 0.85fr), gutter: two-col-gutter)[
    #surface[
      #eyebrow[68 academic pages from 34 PDFs]
      #v(0.15cm)
      #table(
        columns: (1.25fr, .72fr, .72fr, .9fr, .72fr),
        table.header([*Model*], [*CER*], [*WER*], [*Order F1*], [*Math F1*]),
        [PaddleOCR-VL], [0.4634], [0.4732], [0.3751], [0.7248],
        [olmOCR 2], [0.4682], [0.4893], [0.3252], [0.6743],
        [DeepSeek-OCR], [0.5862], [0.6512], [0.1452], [0.4684],
      )
      #v(0.22cm)
      #table(
        columns: (1.3fr, .9fr, .9fr),
        table.header([*Model*], [*Total cost*], [*Cost/page*]),
        [PaddleOCR-VL], [\$0.0420], [\$0.0006180],
        [olmOCR 2], [\$0.0214], [\$0.0003142],
        [DeepSeek-OCR], [\$0.0041], [\$0.0000597],
      )
    ]
  ][
    #card("Benchmark character", [
      Human gold labels; equations, tables, diagrams, and multi-column academic layouts.
    ], fill: soft)
    #v(card-stack-gap)
    #card("Selection tradeoff", [
      PaddleOCR-VL leads strict accuracy. DeepSeek-OCR is cheapest. olmOCR 2 is selected for recall-oriented suitability at lower cost than the strict-accuracy winner.
    ], fill: warm)
  ]
]

#pagebreak()

// 12
#slide("Workflow Evaluation Results")[
  #v(0.04cm)
  #grid(columns: (1fr, 1fr), gutter: 0.36cm)[
    #card("Essay practice", [
      Strong mode fit: source material became exam-style reasoning, but OCR imperfections mean exact provenance still needs preservation.
    ], fill: warm, height: 2.15cm)
    #v(0.28cm)
    #card("RAG exam revision", [
      Best evidence for usefulness: the answer matched course-specific material, but retrieval evidence should be shown beside synthesis.
    ], fill: panel, height: 2.15cm)
  ][
    #card("Flashcards", [
      Good active-recall transformation: concise and examinable, but future validation should check coverage, duplication, and formula clarity.
    ], fill: panel, height: 2.15cm)
    #v(0.28cm)
    #card("Study notes to audio", [
      Strong modality shift: visual notes became listenable revision, but audio necessarily compresses diagrams and worked visual examples.
    ], fill: warm, height: 2.15cm)
  ]
]

#pagebreak()

// 13
#slide("Critical Interpretation and Threats to Validity")[
  #v(content-nudge)
  #grid(columns: (1fr, 1fr), gutter: two-col-gutter)[
    #subhead[Interpretation]
    #spacious-list[
      - Modularity makes AI study workflows easier to inspect and test
      - Artefact boundaries create practical reliability checkpoints
      - Bounded concurrency improves network-bound OCR in the recorded benchmark
      - Retrieval quality depends on disciplined chunking, metadata, and evidence capture
    ]
  ][
    #subhead[Threats and limitations]
    #spacious-list[
      - No controlled learning-outcome or retention study
      - RAG evaluation does not yet use labelled query sets
      - TTS evaluation verifies artefact correctness, not subjective naturalness
      - OCR and throughput results are dataset- and provider-dependent
      - Model behaviour, pricing, latency, and availability can drift
    ]
  ]
]

#pagebreak()

// 14
#slide("Contributions")[
  #v(0.06cm)
  #grid(columns: (1fr, 1fr), gutter: two-col-gutter)[
    #card("Conceptual", [
      Frames study assistance as a source-grounded workflow from raw material to revision artefacts.
    ], fill: soft, height: 1.7cm)
    #v(card-stack-gap)
    #card("Architectural", [
      Separates agent orchestration, tool definitions, Nim executables, and shared libraries.
    ], fill: warm, height: 1.7cm)
  ][
    #card("Technical", [
      Implements OCR, semantic retrieval, and speech pipelines with ordering, retries, schemas, and exit contracts.
    ], fill: warm, height: 1.7cm)
    #v(card-stack-gap)
    #card("Evaluation", [
      Combines contract tests, throughput evidence, OCR model comparison, and recorded workflow critique.
    ], fill: soft, height: 1.7cm)
  ]
]

#pagebreak()

// 15
#slide("Future Work")[
  #v(content-nudge)
  #grid(columns: (1fr, 1fr), gutter: two-col-gutter)[
    #subhead[Near-term engineering]
    #spacious-list[
      - Run manifests linking source PDFs, OCR cache entries, retrieved chunks, generated text, TTS input, and final audio
      - Labelled retrieval evaluation and stored retrieved evidence
      - Broader OCR corpora and repeated measurements
      - Validation passes for formulae, diagrams, duplicate cards, and coverage gaps
    ]
  ][
    #subhead[Broader validation]
    #spacious-list[
      - Provider/model selection policies for cost, latency, quality, and privacy
      - Local or private backends for sensitive course material
      - Human evaluation of artefact usefulness
      - Learning-outcome studies for retention and exam preparation
    ]
  ]
]

#pagebreak()

// 16
#slide("Conclusion")[
  #grid(columns: (1.03fr, 0.97fr), gutter: wide-col-gutter)[
    #text(size: 11pt, weight: "bold", fill: accent)[Main conclusion]
    #v(0.18cm)
    #big-statement[`study-assistant` shows that AI study support can be practical and academically inspectable when flexible generation is constrained by source grounding, modular tools, and explicit artefact contracts.]

    #v(0.26cm)
    #spacious-list[
      - OCR improves input readiness
      - RAG supports source-grounded access
      - Study modes and TTS support different revision forms
      - The architecture makes processing visible and testable
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

// 17
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

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
#set list(
  marker: ([•], [–]),
  indent: 1.2em,
  body-indent: 0.72em,
  spacing: list-spacing,
  tight: false,
)
#set enum(
  indent: 1.25em,
  body-indent: 0.72em,
  spacing: list-spacing,
  tight: false,
)
#set table(stroke: 0.35pt + line-color, inset: table-inset)
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
  #v(0.34cm)
  #surface[
    #grid(columns: (0.92fr, 1.16fr, 0.92fr), gutter: 0.38cm)[
      #eyebrow[Starting point]
      #v(0.08cm)
      #text(size: 8.2pt)[Slides, scans, and notes]
    ][
      #eyebrow[What changes]
      #v(0.08cm)
      #text(size: 8.2pt)[Prepare, search, and transform the material]
    ][
      #eyebrow[Revision formats]
      #v(0.08cm)
      #text(size: 8.2pt)[Notes, practice, and audio]
    ]
  ]
  #v(0.38cm)
  #grid(columns: (1.04fr, 0.96fr), gutter: wide-col-gutter)[
    #spacious-list(size: 7.45pt)[
      - Students revise from lecture slides, scans, textbook pages, and personal notes
      - The same source must become notes, explanations, flashcards, quizzes, essay practice, or audio
      - A plain LLM chat makes fragmented course material harder to manage and answers harder to trace
      - The workflow must remain source-grounded, modular, and inspectable
    ]
  ][
    #card("Core thesis", [
      Coordinate the workflow around the student's material. Do not treat revision as one unstructured prompt.
    ], fill: soft, height: 2.45cm)
  ]
]

#pagebreak()

// 3
#slide("Problem Statement")[
  #v(0.08cm)
  #grid(columns: (1fr, 1fr, 1fr), gutter: 0.28cm)[
    #card("1. Input readiness", [
      OCR converts scanned documents into text that can be searched and reused.
    ], fill: warm, height: 2.58cm)
  ][
    #card("2. Source retrieval", [
      Index course material, then retrieve relevant passages for each student query.
    ], height: 2.58cm)
  ][
    #card("3. Output form", [
      Revision requires different outputs: explanation, active recall, essay practice, and listening.
    ], fill: warm, height: 2.58cm)
  ]
]

#pagebreak()

// 4
#slide("Aim, Objectives, and Scope")[
  #v(content-nudge)
  #grid(columns: (1.06fr, 0.94fr), gutter: wide-col-gutter)[
    #subhead[Aim and objectives]
    #spacious-list[
      - Use OCR, retrieval, generation, and speech for common revision tasks
      - Keep OCR, RAG, and TTS as separate tools that can be run independently
      - Evaluate tool reliability, OCR performance, and recorded workflows
    ]
  ][
    #subhead[Scope and limitations]
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
  #surface[
    #grid(columns: (1fr, 1fr, 1fr), gutter: 0.34cm)[
      #subhead[OCR]
      #text(size: 7.35pt)[
      Converts visual material into text. OCR errors can affect every later output.
      ]
      #v(0.28cm)
      #eyebrow[Inspectable artifact]
      #v(0.10cm)
      #text(size: 7pt)[OCR page records]
    ][
      #subhead[RAG]
      #text(size: 7.35pt)[
      Retrieves relevant passages from the student's material so answers stay grounded in the source.
      ]
      #v(0.28cm)
      #eyebrow[Inspectable artifacts]
      #v(0.10cm)
      #text(size: 7pt)[retrieved passages]
    ][
      #subhead[TTS]
      #text(size: 7.35pt)[
      Rewrite diagrams, tables, and formulas for listening, then turn the text into speech.
      ]
      #v(0.28cm)
      #eyebrow[Inspectable artifact]
      #v(0.10cm)
      #text(size: 7pt)[text prepared for speech]
    ]
  ]
  #v(0.28cm)
  #text(size: 7.2pt, fill: muted)[Intermediate artifacts keep each stage visible.]
]

#pagebreak()

// 6
#slide("Architecture: Flexible Agent, Deterministic Tools")[
  #big-statement[The agent chooses the workflow. The tools perform the processing.]
  #v(0.38cm)
  #grid(columns: (1fr, 1fr), gutter: wide-col-gutter)[
    #card("study-assistant", [
      Selects one mode: transcription, notes, flashcards, quiz, essay practice, or audio.
    ], fill: soft, height: 1.92cm)
  ][
    #card("Tool responsibilities", [
      Handle caching, chunking, retries, output order, and clear failures.
    ], fill: warm, height: 1.92cm)
  ]
  #v(0.42cm)
  #surface[
    #eyebrow[Processing tools]
    #v(0.14cm)
    #grid(columns: (1fr, 1fr, 1fr), gutter: 0.34cm)[
      #text(size: 7.45pt, weight: "bold")[pdfocr]
      #v(0.06cm)
      #text(size: 7.25pt)[Extract text from PDFs]
    ][
      #text(size: 7.45pt, weight: "bold")[chunkvec]
      #v(0.06cm)
      #text(size: 7.25pt)[Store and search material]
    ][
      #text(size: 7.45pt, weight: "bold")[chunktts]
      #v(0.06cm)
      #text(size: 7.25pt)[Create the final audio file]
    ]
  ]
]

#pagebreak()

// 7
#slide("Engineering Decisions")[
  #grid(columns: (1fr, 1fr), gutter: two-col-gutter)[
    #card("Standalone command-line tools", [
      OCR, retrieval, and speech can be run, inspected, cached, or tested independently.
    ], fill: warm, height: 2.28cm)
    #v(0.38cm)
    #card("Shared libraries", [
      The tools share common code for HTTP requests and JSON handling.
    ], fill: panel, height: 2.28cm)
  ][
    #card("Preserve source order", [
      Concurrent requests may complete out of order, but published pages and chunks preserve source order.
    ], fill: soft, height: 2.28cm)
    #v(0.38cm)
    #card("Handle partial outputs", [
      OCR keeps successful pages when some requests fail. Partial final audio is withheld because it may sound complete while omitting content.
    ], fill: warm, height: 2.28cm)
  ]
]

#pagebreak()

// 8
#slide("Workflow Evaluation Method")[
  #v(0.08cm)
  #big-statement[Evaluate the saved evidence, not only the final response.]
  #v(0.38cm)
  #grid(columns: (0.98fr, 1.02fr), gutter: wide-col-gutter)[
    #subhead[Evaluation criteria]
    #spacious-list[
      - Source grounding against prepared material
      - Fit for the requested study mode
      - Inspectable intermediate outputs
      - Reproducible runs
      - Visible limitations rather than hidden failures
    ]
  ][
    #subhead[Recorded workflows]
    #spacious-list[
      - *Essay practice:* Association Analysis slides
      - *RAG revision:* Naive Bayes textbook section
      - *Flashcards:* Anomaly Detection slides
      - *Notes to audio:* Clustering notes
    ]
  ]
]

#pagebreak()

// 9
#slide("Testing and Recorded Runs")[
  #v(content-nudge)
  #grid(columns: (1fr, 1fr), gutter: two-col-gutter)[
    #subhead[What the code controls]
    #spacious-list[
      - pdfocr: page selection, request IDs, retry queue, JSONL output
      - chunkvec: chunk parser, embeddings configuration, SQLite/vector integration
      - chunktts: chunk splitting, retry handling, audio validation, final file creation
      - relay, jsonx, openai: transport and parsing helpers
    ]
  ][
    #subhead[What remote models affect]
    #spacious-list[
      - Use tests for behaviour controlled by the code
      - Use recorded runs for behaviour that depends on remote models
      - Check ordering, failures, and tool boundaries
      - Record limitations alongside the results
    ]
  ]
]

#pagebreak()

// 10
#slide("Evaluation: OCR Throughput")[
  #eyebrow[72-page slide PDF benchmark]
  #v(0.12cm)
  #big-statement[Running OCR requests concurrently made OCR practical while preserving page order.]
  #v(0.36cm)
  #grid(columns: (0.78fr, 1.22fr), gutter: wide-col-gutter)[
    #metric("15.89x", "speedup", note: "up to 32 concurrent requests", fill: soft)
    #v(0.28cm)
    #metric("72/72", "pages completed", note: "in both runs", fill: warm)
  ][
    #surface[
      #eyebrow[Runtime comparison]
      #v(0.28cm)
      #bar("One request at a time", 316.66, 316.66, color: danger)
      #v(0.30cm)
      #bar("Up to 32 concurrent requests", 19.93, 316.66, color: accent)
      #v(0.48cm)
      #text(size: 6.55pt, fill: muted)[Recorded runtime; varies with provider latency, rate limits, network conditions, and document complexity.]
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
        [PaddleOCR-VL], [0.463], [0.473], [0.375], [0.725],
        [olmOCR 2], [0.468], [0.489], [0.325], [0.674],
        [DeepSeek-OCR], [0.586], [0.651], [0.145], [0.468],
      )
      #v(0.22cm)
      #table(
        columns: (1.3fr, .9fr),
        table.header([*Model*], [*Total cost*]),
        [PaddleOCR-VL], [\$0.0420],
        [olmOCR 2], [\$0.0214],
        [DeepSeek-OCR], [\$0.0041],
      )
    ]
  ][
    #card("Benchmark pages", [
      Hand-labelled academic pages with equations, tables, diagrams, and multi-column layouts.
    ], fill: soft)
    #v(card-stack-gap)
    #card("Selection tradeoff", [
      olmOCR 2 had the strongest recall-oriented result and cost less than PaddleOCR-VL.
    ], fill: warm)
  ]
]

#pagebreak()

// 12
#slide("Workflow Evaluation Results")[
  #v(0.04cm)
  #grid(columns: (1fr, 1fr), gutter: 0.36cm)[
    #card("Essay practice", [
      Produced useful exam-style questions, but OCR errors make source tracing important.
    ], fill: warm, height: 2.34cm)
    #v(0.38cm)
    #card("RAG exam revision", [
      Strongest result: the answer matched the course material, but the retrieved passages should be shown beside it.
    ], fill: panel, height: 2.34cm)
  ][
    #card("Flashcards", [
      Worked well for active recall: concise and examinable, but future checks should cover gaps, duplication, and formula clarity.
    ], fill: panel, height: 2.34cm)
    #v(0.38cm)
    #card("Study notes to audio", [
      Produced listenable revision material, but audio cannot fully represent figures, tables, or equations.
    ], fill: warm, height: 2.34cm)
  ]
]

#pagebreak()

// 13
#slide("Results and Limitations")[
  #v(content-nudge)
  #grid(columns: (1fr, 1fr), gutter: two-col-gutter)[
    #subhead[Interpretation]
    #spacious-list[
      - Separate tools make the workflow easier to inspect and test
      - Concurrent requests reduced OCR runtime in the recorded benchmark
      - Retrieval quality depends on how material is split, labelled, and retrieved
    ]
  ][
    #subhead[Threats and limitations]
    #spacious-list[
      - No controlled study of learning outcomes or retention
      - Retrieval has not yet been tested with fixed questions and expected passages
      - TTS evaluation checks the output file, not whether the audio sounds natural
      - OCR results depend on the documents and provider
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
      Organises course material into grounded revision formats.
    ], fill: soft, height: 2.24cm)
    #v(card-stack-gap)
    #card("Architectural", [
      Separates the agent from OCR, retrieval, and speech tools.
    ], fill: warm, height: 2.24cm)
  ][
    #card("Technical", [
      Adds ordering, retries, clear failures, and saved intermediate artifacts.
    ], fill: warm, height: 2.24cm)
    #v(card-stack-gap)
    #card("Evaluation", [
      Tests the tools, measures OCR performance, compares OCR models, and evaluates recorded workflows.
    ], fill: soft, height: 2.24cm)
  ]
]

#pagebreak()

// 15
#slide("Future Work")[
  #v(content-nudge)
  #grid(columns: (1fr, 1fr), gutter: two-col-gutter)[
    #subhead[Next engineering steps]
    #spacious-list[
      - Record each run from source PDF to final output
      - Test retrieval with fixed questions and expected passages
      - Test OCR on more documents and repeat the measurements
      - Add checks for formulae, diagrams, duplicate cards, and coverage gaps
    ]
  ][
    #subhead[Further evaluation]
    #spacious-list[
      - Compare providers and models for cost, latency, quality, and privacy
      - Evaluate local or private model inference for sensitive course material
      - Ask students to evaluate whether the outputs are useful
      - Study effects on retention and exam preparation
    ]
  ]
]

#pagebreak()

// 16
#slide("Conclusion")[
  #grid(columns: (1.03fr, 0.97fr), gutter: wide-col-gutter)[
    #text(size: 11pt, weight: "bold", fill: accent)[Main conclusion]
    #v(0.18cm)
    #big-statement[study-assistant turns course material into practical revision formats through separate, testable tools.]

  ][
    #metric("15.89x", "OCR speedup", note: "recorded OCR benchmark", fill: warm, inset: metric-snug-inset)
    #v(0.12cm)
    #metric("RAG", "strongest workflow result", note: "course-specific answer; retrieved passages should be shown", inset: metric-snug-inset)
    #v(0.12cm)
    #metric("TTS", "revision material in audio form", note: "text is prepared before speech generation", fill: warm, inset: metric-snug-inset)
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

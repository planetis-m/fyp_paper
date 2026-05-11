= Scientific Foundations <chap:foundations>


This chapter establishes the scientific foundations of the study-assistant system. The implementation combines three established areas of computer science and machine learning: optical character recognition (OCR), retrieval-augmented generation (RAG), and text-to-speech (TTS). The system engineering decisions in the design and implementation chapters are grounded in these fields rather than in ad hoc automation.

The chapter also explains how these concepts map onto the implemented system. OCR motivates `pdfocr`; dense retrieval and RAG motivate `chunkvec`; neural speech synthesis motivates `chunktts`; and agent orchestration motivates the separation between the study assistant and its specialised tools.

== Optical Character Recognition


Optical character recognition is the task of converting visual representations of text into machine-readable symbolic text. Classical OCR systems usually combine image preprocessing, layout analysis, text-line or character segmentation, feature extraction, classification, and post-processing. Smith's overview of the Tesseract OCR engine describes a practical open-source OCR architecture built around connected component analysis, adaptive classification, linguistic processing, and page segmentation. @ref-7

Modern document OCR is broader than isolated character recognition. Real documents contain tables, equations, multi-column layouts, headers, footers, marginalia, images, and scanned artefacts. Surveys of deep-learning OCR and document understanding describe a shift from hand-engineered recognition pipelines toward learned models that combine computer vision and natural language processing for document-level understanding. @ref-4 Scene text and document text recognition surveys similarly identify layout, perspective, noise, and reading-order ambiguity as persistent sources of difficulty. @ref-5 @ref-6

For PDF documents, OCR must also account for the distinction between the logical PDF object model and the rendered page. The PDF 2.0 specification defines a page-description format containing text objects, vector graphics, images, fonts, transformations, and rendering instructions. @ref-1 A page can therefore be visually readable while still lacking reliable extractable text. This is the reason the implemented OCR subsystem adopts a render-first design: `pdfocr` renders each selected page to pixels before model inference.

The olmOCR line of work is especially relevant to this project because it treats PDF extraction as a vision-language problem. The olmOCR paper presents PDF processing as the conversion of visually complex pages into clean, linearised text in natural reading order while preserving structures such as sections, tables, lists, and equations. @ref-15 The olmOCR 2 work further frames OCR evaluation through targeted unit-test rewards for document OCR, reflecting the need to test not only raw character accuracy but also structure-sensitive behaviour. @ref-16

In this project, OCR is not a final goal by itself. It is a grounding stage for study workflows. If extracted text omits definitions, equations, table content, or reading-order structure, downstream study notes and quizzes become unreliable. This makes recall, structure preservation, and stable page ordering central evaluation criteria.

== OCR Evaluation Concepts


OCR quality is commonly evaluated through edit-distance based measures such as character error rate (CER) and word error rate (WER). These metrics compare a recognised string with a reference transcription. In formula form:

$ "CER" = frac(S_c + D_c + I_c, N_c) $

where $S_c$, $D_c$, and $I_c$ are character substitutions, deletions, and insertions, and $N_c$ is the number of reference characters. WER uses the same structure over word tokens. These metrics are valuable because they quantify literal transcription accuracy, but they do not fully capture reading order, table structure, equation fidelity, or semantic completeness. For this reason, the OCR benchmark also reports metrics such as reading-order F1, math-symbol F1, and recall-oriented aggregates.

The design implication is that the OCR subsystem should produce auditable page records. `pdfocr` emits one JSON object per page, including attempts and structured errors, so that evaluation can relate failures to individual pages rather than treating a document as a single opaque output.

== Retrieval-Augmented Generation


Retrieval-augmented generation is a class of methods that combines a parametric language model with an external non-parametric memory. Lewis et al. introduced RAG for knowledge-intensive NLP tasks, combining a pre-trained sequence-to-sequence generator with a dense vector index of retrieved passages. @ref-37 The motivation is that a language model's parameters alone are an imperfect store of factual knowledge: retrieval can provide more specific evidence, support provenance, and allow knowledge updates without retraining the generator.

In the canonical RAG formulation, a query $x$ is used to retrieve candidate passages $z$ from a corpus. A generator then produces output $y$ conditioned on both the query and retrieved passages. A simplified RAG-sequence objective can be written as:

$ p(y | x) approx sum_(z in "top_k"(x)) R(z | x) G(y | x, z) $

where $R$ is the retriever distribution and $G$ is the generator distribution. The implemented system does not train a joint RAG model; instead it implements the engineering substrate for retrieval-grounded study workflows: documents are chunked, embedded, stored, retrieved, and then used by the agent as source-grounding material.

Dense passage retrieval provides the retrieval model underlying many RAG systems. Karpukhin et al. show that dual-encoder dense representations can retrieve candidate passages for open-domain question answering and can outperform strong sparse baselines on several datasets. @ref-38 This supports the design of `chunkvec`: source chunks and queries are both embedded as numeric vectors, and nearest-neighbour search returns semantically related passages.

== Embeddings and Vector Search


An embedding model maps text into a vector space:

$ f: text arrow.r bb(R)^d $

The retrieval task is to find stored chunks whose vectors are close to a query vector. A common similarity measure is cosine similarity:

$ cos(q, v) = frac(q dot v, norm(q) norm(v)) $

The implementation uses an OpenAI-compatible embeddings endpoint to produce float vectors and stores them in SQLite. `sqlite-vector` provides vector search functions over vectors stored as BLOBs in ordinary SQLite tables. Its API requires fixed vector dimensions for an initialized vector column and a quantization step before quantized scanning. @ref-39

The study-assistant use case places special importance on chunking. A chunk should be large enough to preserve context, but small enough to retrieve a focused passage. This aligns with the information retrieval principle that retrieval units determine what evidence can be returned. In this project, the `rag-tool` instruction layer enforces semantic chunk boundaries and stable metadata so that retrieved chunks remain useful as study evidence.

== Text-to-Speech


Text-to-speech converts written text into speech audio. Traditional TTS systems are often described in terms of front-end linguistic processing, acoustic modelling, and waveform generation. Modern neural TTS systems learn much of this mapping using sequence-to-sequence and neural vocoder architectures.

WaveNet introduced an autoregressive neural model for raw audio generation and showed its applicability to TTS. @ref-40 Tacotron 2 combines a sequence-to-sequence model that predicts mel spectrograms from character input with a WaveNet vocoder that synthesises the waveform, achieving speech quality close to professional recordings under the reported mean opinion score evaluation. @ref-41 These systems establish the modern framing used by model-hosted TTS APIs: input text is converted by a neural model into audio samples or encoded audio.

The implementation in this project does not train a TTS model. It uses an OpenAI-compatible audio speech endpoint and focuses on the engineering problems around reliable generation:

- rewriting visual text into speech-friendly prose;
- splitting long text into bounded spoken units;
- issuing bounded concurrent speech requests;
- validating returned audio bytes;
- preserving chunk order; and
- writing one final `.opus` artefact only when generation succeeds.

This is a practical application of neural TTS as a service. The technical contribution lies in preparation, orchestration, validation, and artefact construction.

== Agentic Tool Use


The study assistant is an agentic system in the practical software-engineering sense: it selects among tools based on user intent and intermediate artefact state. The agent does not subsume OCR, retrieval, and speech synthesis into one prompt. Instead, it composes specialised subsystems with explicit contracts. This design is consistent with the broader principle of modular AI systems: use specialised mechanisms for perception, retrieval, generation, and output transformation, and keep their boundaries auditable.

The agent layer is therefore responsible for:

- choosing a study mode;
- deciding whether extraction, retrieval, or speech generation is required;
- preserving source-grounding constraints;
- preparing content for the target workflow; and
- presenting final study artefacts in the appropriate format.

The core tools are responsible for deterministic processing. This separation makes the system easier to test than a monolithic agent because many correctness properties are reduced to command-line contracts, schemas, database invariants, and pipeline state machines.

== Related AI Study Systems


The project is situated within a current class of AI-assisted study and research systems that transform user-provided sources into study artefacts. The comparison here is functional and architectural rather than evaluative; it identifies similarities and distinctions that clarify the position of the proposed system.

Thea.study is an AI study platform that allows students to upload materials and generate study aids such as practice questions, flashcards, study guides, summaries, and adaptive study activities. Its public descriptions emphasise file upload, active recall, spaced repetition, practice variation, games, and multilingual access. @ref-47 Functionally, it overlaps with this project in its student-facing emphasis on transforming course material into revision artefacts.

Google NotebookLM is an AI-powered research and note assistant that allows users to upload sources, chat with notebooks, receive source-grounded responses, and transform sources into formats such as study guides, briefings, audio overviews, and mind maps. Google's documentation emphasises grounding in uploaded sources and inline citations, while its Audio Overview feature generates source-based audio discussions in multiple formats. @ref-48 @ref-49

The present project shares the general objective of helping students or researchers work with their own material. Its distinction is architectural. It is an open, modular toolchain with explicit standalone OCR, retrieval, and speech components, coordinated by an agent-level workflow layer. Thea.study and NotebookLM are hosted products with integrated user-facing environments; this system is a transparent academic implementation intended to expose the boundaries between orchestration, processing tools, and reusable infrastructure. The comparison does not imply superiority over those systems in product maturity, user experience, or model capability.

== Streaming, Concurrency, and Structured Data


The system relies on streaming and structured data for composability. JSON Lines is a line-delimited format where each line is a valid JSON value and can be processed independently. @ref-9 This matches the OCR use case: each page produces one record, and downstream processes can consume records incrementally.

The remote model calls are network-bound and therefore benefit from concurrency. The implementation uses libcurl's multi interface through `relay`; the libcurl documentation describes the multi interface as a way for applications to manage multiple simultaneous transfers and drive network progress explicitly. @ref-10 This supports the bounded-concurrency design used by `pdfocr`, `chunkvec`, and `chunktts`.

Structured JSON handling is also central. The OpenAI-compatible APIs require request and response bodies with predictable schemas, and the tools need stable result objects. The custom `jsonx` library provides typed JSON mapping and streaming output, which reduces the risk of schema drift compared with ad hoc string construction.

== Mapping Foundations to the System


#ref(<tbl:foundation-mapping>) maps the scientific foundations to project components.


#figure(
  table(
    columns: 3,
    align: horizon,
    inset: 5pt,
    table.header([Foundation], [System component], [Implementation consequence]),
    table.hline(),
    [PDF rendering and OCR],
    [`ocr-tool`, `pdfocr`],
    [render pages with PDFium, encode WebP, call olmOCR 2, emit ordered JSONL],
    [Document OCR evaluation],
    [`pdfocr` benchmarks],
    [report CER, WER, reading-order F1, math F1, recall-oriented outcomes],
    [Dense retrieval],
    [`rag-tool`, `chunkvec`],
    [embed chunks and queries, store vectors, perform nearest-neighbour search],
    [RAG],
    [`study-assistant`, `rag-tool`],
    [retrieve source passages before grounded study-output generation],
    [Neural TTS],
    [`tts-tool`, `chunktts`],
    [rewrite text for speech, synthesize chunks, validate audio, write `.opus`],
    [Concurrent model APIs],
    [`relay`, `openai`],
    [bounded in-flight requests, retry handling, completion polling],
    [Structured interchange],
    [`jsonx`, JSONL],
    [typed request/response parsing and stable output records],
  ),
  caption: [Mapping of foundations to implementation components],
)<tbl:foundation-mapping>

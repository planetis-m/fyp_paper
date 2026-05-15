# Speaker Notes

Target length: 14:15-14:30 spoken time, leaving a small buffer inside a strict 15-minute defence.

Use these as delivery prompts, not a script. The presentation should form one continuous argument: problem, architecture, evidence, limits, contribution.

---

## Slide 1: Title

Target: 20 seconds.

This project presents an agent-based study assistant for academic revision. The core idea is to help students move from fragmented course material into grounded study artefacts: searchable text, explanations, practice questions, flashcards, and audio.

Transition: I will start with the study problem the system is designed around.

---

## Slide 2: Problem Context

Target: 50 seconds.

Students rarely revise from one clean source. They work across lecture PDFs, scanned pages, textbook extracts, notes, and copied fragments. The important issue is not only file format or document length. Study requires repeated transformation of the same material: into readable notes, searchable passages, active-recall prompts, essay practice, and sometimes audio.

The project starts from that practical workflow. AI study support is useful only if it remains grounded in the student's actual material and if the processing steps are visible enough to inspect.

Transition: That leads to three specific barriers the system has to solve.

---

## Slide 3: Problem Statement

Target: 55 seconds.

The first barrier is input readiness. Scanned or PDF-based material may be visually readable but not usable by a language-based assistant until OCR produces text.

The second barrier is grounded access. Long or fragmented course material cannot be treated as one uncontrolled prompt. The student needs to retrieve relevant passages from their own prepared sources.

The third barrier is output form. Study is not one output type. A student may need transcription, explanation, flashcards, quizzes, essay prompts, or spoken revision.

The design challenge is to move from raw course material to reusable study artefacts without losing source grounding.

Transition: The aim and scope are deliberately shaped around that challenge.

---

## Slide 4: Aim, Objectives, and Scope

Target: 55 seconds.

The aim is to design and evaluate an agent-based study assistant that coordinates OCR, retrieval-augmented assistance, and text-to-speech for realistic revision workflows.

The objectives combine student-facing behaviour with engineering controls: support multiple study modes, preserve source grounding, keep OCR, RAG, and TTS usable as standalone tools, and evaluate reliability, throughput, model suitability, and workflow feasibility.

The scope is important. This is a system-design and engineering thesis. It does not claim measured grade improvement, and it does not replace student judgement or instructor feedback. Those are future educational studies.

Transition: The requirements follow directly from the workflow barriers.

---

## Slide 5: Study Workflow Requirements

Target: 55 seconds.

OCR addresses input readiness, but academic documents require more than character extraction. Reading order, equations, tables, and omitted definitions matter because downstream study artefacts depend on them.

RAG addresses grounded access by storing and retrieving the student's prepared material rather than relying only on model memory.

TTS addresses output modality, but visual notes need rewriting before they are useful as speech.

The software requirement is that each capability leaves an artefact: ordered JSONL for OCR, marked chunks in a local vector store for retrieval, and a complete audio file for speech.

Transition: The architecture separates flexible study intent from deterministic processing.

---

## Slide 6: Architecture: Flexible Agent, Deterministic Tools

Target: 70 seconds.

At the top level, the student provides a request and source material. The `study-assistant` interprets the intent and selects a study mode. The output is a study artefact or audio file.

Below that are three specialised paths. `ocr-tool` and `pdfocr` prepare scanned or PDF material. `rag-tool` and `chunkvec` store and retrieve semantic chunks. `tts-tool` and `chunktts` prepare and assemble speech output.

The key architectural decision is separation of concerns. The agent owns study intent. The tools own execution contracts. This makes the system easier to test because many behaviours can be checked through schemas, exit codes, ordered outputs, and stored artefacts rather than through a conversational transcript alone.

Transition: Those boundaries are supported by specific engineering decisions.

---

## Slide 7: Engineering Decisions

Target: 65 seconds.

There are four important decisions.

First, agent orchestration is separated from deterministic tools, so the system is not one opaque prompt.

Second, the core processing stages are standalone command-line tools. They can be run, inspected, cached, redirected, or tested independently.

Third, the system prefers ordered final output over maximum raw completion speed. Pages or chunks may finish out of order internally, but the published artefact follows the source order.

Fourth, failure semantics depend on artefact risk. Partial OCR can be useful if page errors are explicit. Partial final audio is withheld because it could sound complete while silently omitting content.

The shared Nim libraries support consistency across the tools rather than duplicating request, JSON, and provider code.

Transition: The evaluation then asks whether these decisions work in realistic study workflows.

---

## Slide 8: Workflow Evaluation Method

Target: 60 seconds.

The workflow evaluation is not judged by whether one generated answer sounds fluent. It asks whether the system can move through realistic revision tasks while producing inspectable artefacts.

The recorded workflows cover essay practice, RAG-based exam revision, flashcards, and study-notes-to-audio. The criteria are source grounding, mode appropriateness, operational reproducibility, useful intermediate artefacts, and visible limitations.

This matters because a study assistant can appear successful while hiding provenance problems. The evaluation therefore treats traceability and artefact boundaries as part of the evidence.

Transition: Before the live workflow evidence, the implementation contracts are tested separately.

---

## Slide 9: Testing Strategy and Evaluation Credibility

Target: 55 seconds.

The evaluation separates local correctness from provider variability. Deterministic tests cover contracts such as page selection, request identifiers, retry queues, JSON schema, chunk parsing, SQLite/vector integration, audio validation, and transport behaviour.

Live model results are treated as empirical operational evidence, not as deterministic tests. This separation is important because remote models can vary, but local software should still preserve ordering, classify failures, and publish artefacts predictably.

Transition: The first quantitative result is the OCR throughput benchmark.

---

## Slide 10: Evaluation: OCR Throughput

Target: 70 seconds.

The throughput benchmark used a fixed 72-page slide PDF. The sequential baseline with `K=1` took 316.66 seconds and completed 72 out of 72 pages. With bounded concurrency at `K=32`, the same workload completed in 19.93 seconds, again with 72 out of 72 pages successful.

That is a 15.89 times speedup and a 93.71 percent relative time reduction. The improvement comes from overlapping network-bound OCR requests while preserving ordered output.

This is not a universal speed guarantee. It depends on provider latency, rate limits, document complexity, and network conditions. It supports the narrower claim that bounded concurrency made this recorded OCR workflow practical.

Transition: Throughput is only one part of OCR suitability; model choice also matters.

---

## Slide 11: Evaluation: OCR Model Benchmark

Target: 70 seconds.

The OCR benchmark used 68 pages from 34 academic PDFs with human gold labels. The pages include equations, tables, diagrams, and multi-column layouts, so this is a difficult academic-document setting.

The result is a tradeoff, not a single absolute winner. PaddleOCR-VL gives the strongest strict accuracy aggregate in this run. DeepSeek-OCR is the cheapest. `olmOCR 2` is selected because it gives the strongest recall-oriented fit for the study workflow while costing less than the strict-accuracy winner.

That matters because in study material, omissions are especially harmful. A missing theorem, definition, equation, or table row can damage downstream notes, quizzes, and explanations.

Transition: The recorded workflows show how these technical choices appear at the user-facing level.

---

## Slide 12: Workflow Evaluation Results

Target: 80 seconds.

The recorded workflows demonstrate several useful transformations.

In essay practice, Association Analysis slides produced four exam-style prompts with sample answers covering Apriori, support, confidence, lift, and interestingness.

In RAG exam revision, textbook pages 358 to 402 were OCR-processed and stored as 26 semantic chunks. A targeted search retrieved the Naive Bayes zero-probability issue and smoothing methods from the stored source material.

In flashcard mode, Anomaly Detection slides produced 25 active-recall cards covering definitions, settings, methods, limitations, and applications.

In the notes-to-audio workflow, clustering material became study notes, then speech-ready text, then a final audio artefact from 24 ordered speech chunks.

The critical interpretation is balanced: the workflows are useful and mode-appropriate, but traceability should be stronger. Future runs should preserve retrieved chunks alongside generated synthesis, flag formula and diagram uncertainty, and record run manifests linking source files to final artefacts.

Transition: Those observations define the limitations rather than weakening the contribution.

---

## Slide 13: Critical Interpretation and Threats to Validity

Target: 75 seconds.

The system is practically useful because it coordinates OCR, retrieval, generation, and speech around actual revision tasks. The architecture makes errors easier to locate because each stage has a separate responsibility and artefact.

The limitations are also clear. There is no controlled learning-outcome study. RAG evaluation focuses on infrastructure and recorded workflow usefulness, not labelled retrieval accuracy. TTS evaluation verifies artefact correctness, not subjective listening quality. OCR benchmarks are dataset-specific, and throughput measurements are recorded runs rather than statistical guarantees.

There is also provider variability: remote model quality, pricing, latency, and availability can change. These limitations define the claim boundary. The project demonstrates practical, inspectable system behaviour; it does not claim universal model performance or proven educational impact.

Transition: Within that boundary, the contributions are still substantial.

---

## Slide 14: Contributions

Target: 55 seconds.

The conceptual contribution is framing study assistance as a source-grounded workflow, not just summarisation.

The architectural contribution is the separation between agent orchestration, tool definitions, core Nim executables, and shared libraries.

The technical contribution is a modular OCR, retrieval, and speech tool ecosystem with ordering, retries, schemas, exit contracts, and reusable infrastructure.

The evaluation contribution is the combination of deterministic contract tests, OCR throughput evidence, OCR model comparison, and recorded workflow analysis.

Transition: The future work follows directly from the evaluation gaps.

---

## Slide 15: Future Work

Target: 55 seconds.

The most immediate future work is stronger auditability: run manifests should connect source PDFs, OCR cache entries, retrieved chunks, generated artefacts, TTS input, and final audio.

The RAG subsystem needs labelled retrieval evaluation and recorded retrieved evidence alongside final answers. OCR evaluation should use broader corpora and repeated measurements. Generated flashcards and notes should be checked for coverage, duplication, formula ambiguity, and diagram uncertainty.

Longer term, provider and model policies should account for cost, latency, privacy, and local backends. Educational validation with students would be needed to measure usefulness and learning outcomes.

Transition: I will close by returning to the central claim.

---

## Slide 16: Conclusion

Target: 55 seconds.

The project addresses the three barriers from the beginning. OCR improves input readiness. RAG supports source-grounded access. Study modes and TTS support different revision forms.

The main conclusion is that these capabilities become more academically credible when they are coordinated through a modular architecture with explicit contracts. The agent handles study intent, while the tools enforce ordered output, bounded concurrency, retry behaviour, schema control, and artefact publication.

`study-assistant` shows that AI study support can be practical and inspectable when flexible generation is constrained by source grounding and clear processing boundaries.

Transition: Thank the committee and invite questions.

---

## Slide 17: Questions

Target: final hold.

Thank you. I am happy to take questions.

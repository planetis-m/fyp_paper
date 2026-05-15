# Speaker Notes

Target length: about 20 minutes.

Use these as delivery prompts, not a script.

Each slide is self-contained.
Transitions close the current slide only.

---

## Slide 1: Title

Target: 35-40 seconds.

Core message:
this is an agent-based study assistant
that coordinates OCR, retrieval, and speech tools.

VISUAL ANCHOR:
large title,
subtitle line with OCR, RAG, TTS,
candidate and advisor blocks.

Open calmly.

Say the title once.

Then compress the framing:

This project is about study material
that starts in difficult forms:
PDFs,
scanned pages,
lecture notes,
long readings.

The system helps turn that material
into usable revision artefacts.

Point to subtitle.

OCR handles text extraction.
RAG handles source-grounded access.
TTS handles listening-based revision.

Stress **agent**.

The agent is the coordinator.
The tools do the specialised work.

Close:
the project is about connecting these capabilities
with clear software boundaries.

Transition:
finish the title frame,
then advance.

---

## Slide 2: Problem Context

Target: 55 seconds.

Core message:
student study material is fragmented,
and revision requires repeated transformation.

VISUAL ANCHOR:
left headline and bullets,
right flow strip,
Core thesis card.

Start with the headline.

Study material rarely arrives as one clean source.

A student may have:
lecture PDFs,
scanned handouts,
textbook extracts,
Markdown notes,
and copied fragments.

The issue is not only file format.

The real issue is that study requires reuse.

The same source may need to become:
searchable text,
notes,
flashcards,
quiz questions,
essay prompts,
or audio.

Move to the flow strip.

PDF or notes enter the pipeline.
OCR prepares text when needed.
The RAG store keeps material searchable.
Study modes create targeted outputs.
Audio supports revision away from the screen.

Point to Core thesis.

Stress **inspectable**.

A single unstructured prompt can produce an answer.
But this system keeps the stages visible.

Close:
the context is fragmented input,
multiple revision outputs,
and the need for source grounding.

Transition:
hold on the Core thesis card,
then advance.

---

## Slide 3: Problem Statement

Target: 65 seconds.

Core message:
the system must solve three connected barriers
without losing source grounding.

VISUAL ANCHOR:
three cards across the top,
Design challenge statement below.

Move left to right.

Input readiness.

Some documents are visually readable
but not machine-readable.

A scanned page can be understood by a student,
but a language tool cannot use it reliably
until OCR creates structured text.

Grounded access.

Long or fragmented notes do not fit well
as one giant prompt.

The student needs to ask:
what does my material say about this concept?

That requires retrieval from prepared sources.

Output form.

Effective study is not one output.

Sometimes the student needs an explanation.
Sometimes active recall.
Sometimes essay practice.
Sometimes audio.

Pause on Design challenge.

Stress **grounding**.

The hard part is not calling a model.
The hard part is moving from raw course material
to reusable artefacts
while keeping the source relationship clear.

Close:
these three barriers define the design problem.

Transition:
finish on Design challenge,
then advance.

---

## Slide 4: Objectives

Target: 65 seconds.

Core message:
the objectives combine student-facing study modes
with engineering controls.

VISUAL ANCHOR:
Functional objectives column,
Engineering objectives column.

Start on the left.

The functional side is about what a student can do.

The system supports transcription
when preservation matters.

It supports notes and lecture explanation
when understanding matters.

It supports ELI5
when intuition matters.

It supports flashcards, quizzes, and essays
when practice matters.

It supports TTS
when revision needs an audio form.

Move right.

The engineering side is what prevents this
from becoming a fragile demo.

Asynchronous model calls must not scramble pages.

Concurrency must be bounded.

Transient failures need retries.

stdout must remain machine-readable
so artefacts can be redirected and tested.

Each tool must work inside the agent
and as a standalone command.

Stress **ordering**.

If a 72-page OCR run finishes out of order internally,
the final output still needs to match the source order.

Close:
the project is both a study assistant
and a set of reliable processing contracts.

Transition:
finish on the engineering column,
then advance.

---

## Slide 5: Research Questions and Scope

Target: 55 seconds.

Core message:
the research focus is coordination,
auditability,
and practical operational evidence.

VISUAL ANCHOR:
research questions on the left,
Scope and Boundary cards on the right.

Use the three questions as the frame.

First:
how can an agent coordinate OCR,
retrieval,
generation,
and speech
without hiding the processing steps?

Second:
what contracts are needed
so model-based workflows remain auditable?

Third:
what evidence shows practical suitability
for realistic revision material?

Now point to Scope.

The evaluation covers design,
reliability,
throughput,
and recorded workflows.

Point to Boundary.

Stress **bounded**.

The project does not claim
that students achieve higher grades.

It also does not replace student judgement.

The claim is narrower:
this architecture can prepare,
retrieve,
transform,
and publish study artefacts
in a controlled way.

Close:
the scope keeps the claims technical and testable.

Transition:
close on the Boundary card,
then advance.

---

## Slide 6: Foundation

Target: 10-15 seconds.

Core message:
the next part grounds the system design.

VISUAL ANCHOR:
Foundation title,
accent line,
subtitle.

Short reset.

This section gives the technical basis:
OCR,
RAG,
TTS,
and the study-workflow framing.

Stress **foundation**.

Transition:
advance after the reset.

---

## Slide 7: Background and Related Work

Target: 65 seconds.

Core message:
OCR, RAG, and TTS each solve a different bottleneck
in the study workflow.

VISUAL ANCHOR:
three cards,
Positioning card at bottom.

Start with OCR.

OCR converts visual pages
into machine-readable text.

For study material,
basic character accuracy is not enough.

Reading order matters.
Tables matter.
Equations matter.
Definitions matter.

If OCR drops a definition,
the downstream quiz or flashcard may be wrong.

Move to RAG.

RAG adds an external memory:
the student's own material.

Instead of asking the model from memory alone,
the system retrieves relevant chunks
and uses those as context.

That is how answers stay tied
to course-specific sources.

Move to TTS.

TTS is not just pressing play on Markdown.

Technical notation,
headings,
lists,
and formulas need to be rewritten
so they make sense when heard.

Point to Positioning.

Stress **lifecycle**.

The project treats study assistance
as prepare,
retrieve,
transform,
practise,
and listen.

Close:
the background motivates the system boundaries.

Transition:
finish on the Positioning card,
then advance.

---

## Slide 8: Requirements and Specification

Target: 60 seconds.

Core message:
the requirements are expressed through user-facing behavior
and explicit tool contracts.

VISUAL ANCHOR:
left requirement list,
right contract table.

Start with user-facing requirements.

The system must accept the kinds of material
students actually have:
PDFs,
plain text,
Markdown,
stored document IDs,
or raw pasted source text.

It must produce mode-specific artefacts.

That means a quiz should sound like a quiz,
not like a summary.

Flashcards should support active recall,
not just restate paragraphs.

It must avoid unsupported external content.

The student is studying their material,
not receiving a generic answer.

Now move to the contract table.

`pdfocr` emits ordered JSONL page results.

`chunkvec` ingests marked chunks
into a SQLite vector store.

`chunktts` takes ordered chunks
and produces a complete Opus file.

Stress **contract**.

These contracts define what can be tested,
cached,
redirected,
or inspected.

Close:
requirements become concrete artefact boundaries.

Transition:
finish on the contract table,
then advance.

---

## Slide 9: Method and System Design

Target: 10-15 seconds.

Core message:
the system design is about auditable artefacts.

VISUAL ANCHOR:
Method and System Design title,
subtitle.

Reset the audience.

This section moves from requirements
to the mechanism that implements them.

Stress **artefacts**.

Transition:
advance after the section title.

---

## Slide 10: Methodology

Target: 65 seconds.

Core message:
the model-calling tools share a common reliability pattern.

VISUAL ANCHOR:
left numbered pattern,
right correctness invariants.

Start with the left side.

Every tool begins by parsing and normalising configuration.

Then input is converted into ordered work items:
pages for OCR,
chunks for speech,
or records for retrieval.

Each request receives a deterministic ID.

That ID encodes sequence and attempt,
so the tool can explain what happened
even when retries occur.

Work is submitted in bounded batches through `relay`.

Results are classified:
success,
retryable failure,
or terminal failure.

Finalisation happens in source order
or inside a database transaction.

Now the right side.

The invariants are the safety rails.

`inFlightCount <= K`.

Retry queues are ordered by due time.

stdout remains machine-readable.

JSON schemas are built through typed helpers.

Configuration values are normalised into safe ranges.

Stress **invariant**.

The model provider may be variable.
The local execution contract should remain predictable.

Close:
this methodology is reused across the tools.

Transition:
finish on the invariant list,
then advance.

---

## Slide 11: System Architecture

Target: 75 seconds.

Core message:
the agent owns study intent,
while specialised tools own deterministic processing.

VISUAL ANCHOR:
top row input to orchestration to output,
lower row OCR path, RAG path, TTS path.

Start at the top row.

The input is a student request plus material.

That request is not just data.
It contains intent:
summarise this,
make flashcards,
explain this concept,
prepare audio.

The assistant selects the mode.

The output is a study artefact or audio file,
not just a chat response.

Drop to the lower row.

OCR path.

`ocr-tool` calls `pdfocr`.
`pdfocr` renders pages
and emits ordered JSONL.

That path solves input readiness.

RAG path.

`rag-tool` calls `chunkvec`.
`chunkvec` stores chunks
with metadata and vectors in SQLite.

That path solves grounded access.

TTS path.

`tts-tool` calls `chunktts`.
`chunktts` validates speech chunks
and assembles final audio.

That path solves alternate output form.

Point to bottom line.

Shared libraries provide bounded HTTP execution,
typed JSON handling,
and provider request schemas.

Stress **separation**.

The agent can be flexible
because the tool contracts are stable.

Close:
the architecture separates intention from execution.

Transition:
finish on the visual split,
then advance.

---

## Slide 12: Design Decisions

Target: 65 seconds.

Core message:
the design prioritises inspectability,
reuse,
ordering,
and explicit failure behavior.

VISUAL ANCHOR:
four decision cards.

Decision one:
agent orchestration,
deterministic tools.

The agent interprets study intent.
The tools perform stable processing steps.

That prevents the whole system
from becoming one opaque conversation.

Decision two:
standalone command-line tools.

Each stage can be run,
tested,
redirected,
or cached independently.

That matters for debugging
and for reproducible evaluation.

Decision three:
ordered output over raw speed.

Concurrent requests can finish in any order.

But pages and chunks must be published
in source order.

Decision four:
explicit failure semantics.

Partial OCR can still be useful
because page-level errors are visible.

Partial audio is different.

If final audio is missing a section,
it may sound complete
while silently omitting content.

Stress **failure**.

The system treats different artefacts
according to their risk.

Close:
these decisions make model-based processing inspectable.

Transition:
finish on the failure semantics card,
then advance.

---

## Slide 13: Implementation Highlights

Target: 65 seconds.

Core message:
the implementation consists of three main tools
supported by shared infrastructure.

VISUAL ANCHOR:
top row tool cards,
bottom row relay, jsonx, openai.

Start top left.

`pdfocr` handles PDF rendering with PDFium.

It encodes page images,
sends multimodal OCR requests,
and writes page-level JSONL.

It also classifies retryable and terminal errors.

Move to `chunkvec`.

This tool parses strict `<chunk ...>` markup.

It creates embeddings,
stores chunks in SQLite,
and supports metadata filters
and vector search.

Move to `chunktts`.

This tool splits `<bk>` speech chunks,
requests speech audio,
decodes WAV,
validates audio,
and assembles final Opus.

Bottom row.

`relay` handles bounded concurrent HTTP execution.

`jsonx` centralises typed JSON parsing
and streaming writers.

`openai` provides request schemas
for chat,
embeddings,
and speech.

Stress **shared**.

The common libraries keep the tools consistent
instead of duplicating fragile request code.

Close:
the implementation mirrors the architecture.

Transition:
finish on the shared-library row,
then advance.

---

## Slide 14: User Workflow

Target: 65 seconds.

Core message:
from the user's perspective,
the system turns a lecture PDF into multiple revision forms.

VISUAL ANCHOR:
horizontal workflow,
Supported modes box,
Demo scenario box.

Start with the horizontal workflow.

A lecture PDF enters the system.

OCR extracts text.

The extracted text can be cleaned.

Study notes can be generated.

Those notes can be rewritten for speech.

The final output can be an audio file.

Now use the Supported modes box.

Each mode has a different learning purpose.

`transcribe` preserves source text.

`lecture` gives a formal explanation.

`eli5` builds intuition.

`flashcard` supports recall.

`mindmap` shows concept hierarchy.

`quiz` creates practice questions.

`essay` supports exam preparation.

`study-notes` creates revision notes.

Move to Demo scenario.

The recorded scenario uses OCR,
generates notes,
rewrites notation for speech,
synthesizes 24 ordered chunks,
and publishes one Opus artefact.

Stress **mode**.

The mode tells the assistant
what kind of learning artefact to produce.

Close:
the workflow is practical because each step has an artefact.

Transition:
finish on the demo scenario box,
then advance.

---

## Slide 15: Recorded Workflow Protocol

Target: 65 seconds.

Core message:
the workflow evaluation follows inspectable artefacts
through multiple study tasks.

VISUAL ANCHOR:
numbered protocol surface,
Interpretation focus card,
Recorded evidence card.

Walk the protocol.

First,
select a lecture PDF.

Second,
run OCR or use cached extraction.

Third,
ask for a specific mode,
such as flashcards.

Fourth,
show output grounded in the extracted content.

Fifth,
store a textbook section in RAG.

Sixth,
search for a targeted concept.

Seventh,
convert generated notes into audio.

Point to Interpretation focus.

Stress **chain**.

The evidence is the chain of artefacts,
not only one generated answer.

Each step can be inspected.
Later steps reuse the student's own material.

Point to Recorded evidence.

The recorded workflows cover:
essay practice,
RAG exam revision,
flashcards,
and study-notes-to-audio.

Close:
the protocol tests whether the system supports real revision movement.

Transition:
finish on the recorded evidence card,
then advance.

---

## Slide 16: Evaluation

Target: 10-15 seconds.

Core message:
evaluation combines contracts,
benchmarks,
and recorded workflows.

VISUAL ANCHOR:
Evaluation section title,
subtitle.

Short reset.

The evaluation is layered:
software tests,
operational benchmarks,
and workflow evidence.

Stress **layered**.

Transition:
advance after the reset.

---

## Slide 17: Testing Strategy

Target: 65 seconds.

Core message:
local tests verify deterministic behavior
around model-dependent components.

VISUAL ANCHOR:
Verified software contracts column,
Why this matters column.

Start left.

`pdfocr` tests page selection,
request IDs,
retry queues,
and JSON schema.

These are the things that protect page-level OCR output.

`chunkvec` tests chunk parsing,
configuration,
embeddings,
SQLite,
and vector integration.

These protect the retrieval store.

`chunktts` tests splitting,
retries,
audio wrapping,
and a local-server pipeline.

These protect final audio generation.

`relay` tests lifecycle,
ordering,
request bodies,
and headers.

`jsonx` and `openai` test parsing
and request schema construction.

Move right.

The point is separation.

A live model benchmark tells us operational behavior.

Local tests tell us whether our own contracts hold.

Stress **deterministic**.

When provider output varies,
the tool should still expose stable failure modes,
exit codes,
and artefacts.

Close:
testing focuses on the parts the system can control.

Transition:
finish on stable exit codes and artefacts,
then advance.

---

## Slide 18: Evaluation: OCR Throughput

Target: 75 seconds.

Core message:
bounded concurrency greatly improves OCR throughput
while preserving successful ordered output.

VISUAL ANCHOR:
15.89x metric,
93.71% time reduction,
runtime bars,
table.

Start with the benchmark:
72-page slide PDF.

Sequential baseline:
K equals 1.

Runtime:
316.66 seconds.

Result:
72 out of 72 pages succeeded.

Concurrent run:
K equals 32.

Runtime:
19.93 seconds.

Result:
again,
72 out of 72 pages succeeded.

Point to 15.89x.

Stress **throughput**.

The speedup is 15.89 times.

Point to 93.71%.

That is a relative time reduction of 93.71 percent,
or 296.73 seconds saved.

Move to the bars.

The red bar is the waiting problem.
The teal bar is the bounded batch process.

Important detail:
the improvement comes from overlapping network-bound OCR requests.

It is not dropping pages.
It is not relaxing output order.

The contract still holds:
all pages succeeded,
and results are published in source order.

Close:
bounded concurrency turns OCR from a slow serial wait
into a controlled batch process.

Transition:
finish on the runtime comparison,
then advance.

---

## Slide 19: Evaluation: OCR Model Benchmark

Target: 75 seconds.

Core message:
OCR model choice is a trade-off between strict accuracy,
recall-oriented behavior,
and cost.

VISUAL ANCHOR:
accuracy table,
cost table,
Dataset card,
Interpretation card.

Start with Dataset card.

The benchmark uses 68 pages
from 34 academic PDFs.

The labels are locked human gold labels.

The pages include equations,
tables,
diagrams,
and multi-column layouts.

That matters because academic PDFs are structurally difficult.

Move to the accuracy table.

PaddleOCR-VL gives the strongest strict accuracy
in this run.

Its CER and WER are slightly better.

olmOCR 2 is close on strict metrics
and stronger for recall-oriented study behavior
in the broader evaluation.

DeepSeek-OCR is weaker on these accuracy metrics.

Move to the cost table.

DeepSeek-OCR is the cheapest.

olmOCR 2 is in the middle.

PaddleOCR-VL is the most expensive of the three.

Point to Interpretation card.

Stress **recall**.

For study assistance,
missing important material is dangerous.

A missing theorem,
definition,
equation,
or table row
can damage downstream notes and quizzes.

So the selected model is not simply the cheapest.
It is chosen for suitability to the study workflow.

Close:
the benchmark justifies model selection as a practical trade-off.

Transition:
finish on the Interpretation card,
then advance.

---

## Slide 20: Workflow Evaluation Results

Target: 70 seconds.

Core message:
the recorded workflows demonstrate concrete student-facing artefacts.

VISUAL ANCHOR:
four result cards.

Start top left.

Essay practice.

Association Analysis slides produced
four exam-style essay questions
with sample answers.

The content covered Apriori,
support,
confidence,
lift,
and rule interestingness.

This shows the system can turn lecture material
into exam preparation.

Move bottom left.

RAG exam revision.

Textbook pages 358 to 402
were OCR-processed
and stored as 26 semantic chunks.

The targeted search retrieved
zero-probability handling for Naive Bayes.

This shows source-grounded retrieval
over prepared course material.

Move top right.

Flashcards.

Anomaly Detection slides produced
25 front-back cards.

They covered definitions,
settings,
measures,
limitations,
and applications.

This supports active recall.

Move bottom right.

Study notes to audio.

Clustering notes became:
a 7.3 KB Markdown artefact,
a 7.2 KB TTS input,
and a 2.1 MB Opus file
from 24 speech chunks.

Stress **artefacts**.

The important point is not that one answer looks fluent.

The important point is that each workflow produces
usable intermediate and final outputs.

Close:
the system supports multiple realistic revision paths.

Transition:
finish on the four artefact categories,
then advance.

---

## Slide 21: Discussion and Limitations

Target: 70 seconds.

Core message:
the system is practically useful,
but the claims are deliberately limited.

VISUAL ANCHOR:
Interpretation column,
Limitations column.

Start with Interpretation.

First:
modularity makes AI study workflows easier to inspect.

When OCR,
retrieval,
generation,
and speech are separated,
errors are easier to locate.

Second:
artefact boundaries are a reliability mechanism.

JSONL pages,
marked chunks,
database records,
and audio files create checkpoints.

Third:
bounded concurrency matters for network-bound OCR.

The benchmark shows this clearly.

Fourth:
retrieval quality depends on chunking and metadata.

RAG is not magic.
The store must be built carefully.

Move to Limitations.

There is no controlled study of learning outcomes.

OCR and generation still depend on external models.

RAG evaluation focuses on infrastructure,
not full answer grading.

Recorded workflows show feasibility,
not broad deployment.

Stress **honest**.

The project claims a working,
inspectable architecture.

It does not claim complete educational validation.

Close:
the contribution is technical feasibility with clear limits.

Transition:
finish on the limitations column,
then advance.

---

## Slide 22: Contributions

Target: 60 seconds.

Core message:
the project contributes a source-grounded workflow,
a modular architecture,
implemented tools,
and evaluation evidence.

VISUAL ANCHOR:
four contribution cards.

Conceptual contribution.

The project frames study assistance
as a workflow from raw material
to revision artefacts.

That is broader than summarisation.

Architectural contribution.

The system separates:
agent orchestration,
tool definitions,
Nim executables,
and shared libraries.

That keeps responsibilities clear.

Technical contribution.

The implementation provides OCR,
semantic retrieval,
and speech pipelines.

These include deterministic ordering,
retries,
schemas,
and exit contracts.

Evaluation contribution.

The project provides:
contract tests,
throughput evidence,
OCR model comparison,
and recorded study workflows.

Stress **cohesive**.

The main contribution is not any single component alone.

It is the coordinated system
with explicit contracts between stages.

Close:
the contributions connect concept,
architecture,
implementation,
and evidence.

Transition:
finish on the four-card summary,
then advance.

---

## Slide 23: Future Work

Target: 55 seconds.

Core message:
future work should deepen both engineering validation
and educational validation.

VISUAL ANCHOR:
Engineering extensions column,
Educational extensions column.

Start with engineering extensions.

Mocked transport tests would make model-calling tools
more reproducible in CI.

Broader OCR benchmark corpora
would test more document types.

Labelled retrieval queries
would measure whether RAG returns the right chunks.

Provider and model policies
would allow choices based on cost,
latency,
privacy,
and accuracy.

Move to educational extensions.

Human evaluation can measure
whether artefacts are actually useful to students.

Learning-outcome studies can test retention
and exam preparation.

Local or private model backends
can support sensitive course material.

Instructor-authored rubrics
can make outputs better aligned with assessment.

Stress **validation**.

The next step is to move from technical feasibility
to stronger evidence with users and labelled tasks.

Close:
future work expands confidence in both the system and its learning value.

Transition:
finish on the two-column split,
then advance.

---

## Slide 24: Conclusion

Target: 65 seconds.

Core message:
`study-assistant` demonstrates that OCR, RAG, and TTS
can form a practical inspectable study workflow.

VISUAL ANCHOR:
Main conclusion block,
three metric cards.

Start with the conclusion block.

The system addresses the three barriers
from the beginning of the presentation.

Input readiness:
OCR turns scanned or PDF material
into usable text.

Grounded access:
RAG stores and retrieves the student's own material.

Output form:
study modes and TTS produce different revision artefacts.

The key is the architecture.

The agent maps user intent to a mode.

The tools enforce contracts:
ordered output,
bounded concurrency,
retry handling,
schema control,
and explicit artefacts.

Point to the metrics.

72 out of 72 OCR pages succeeded
in the throughput benchmark.

26 semantic chunks supported
the textbook RAG workflow.

24 speech chunks produced
the notes-to-audio workflow.

Stress **practical**.

The project shows a working path
from raw course material
to searchable,
testable,
and listenable study outputs.

Close:
the final claim is practical integration
with inspectable processing contracts.

Transition:
finish on the three metrics,
then advance.

---

## Slide 25: Questions

Target: final hold.

Core message:
close confidently and invite discussion.

VISUAL ANCHOR:
large Questions title,
project title underneath.

Stop speaking for a beat.

Then say:

Thank you.

I am happy to take questions
on the architecture,
the implementation,
the evaluation,
or the recorded workflows.

Stress **questions**.


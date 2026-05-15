# Speaker Notes

Target length: 14:15-14:30 spoken time.

Use these as presenter notes.
They are written as short spoken sentences,
with line breaks for pacing and recovery.

---

## Slide 1: Title

Target: 20 seconds.

Core message:
This project is about coordinating AI tools around a real study workflow.

VISUAL ANCHOR:
Large title.
Subtitle with OCR, RAG, and TTS.
Candidate and advisor blocks.

This project presents an agent-based study assistant for academic revision.

The system helps students move from fragmented course material
to useful revision artefacts.

Those artefacts include searchable text,
explanations,
practice questions,
flashcards,
and audio.

The key point is that the **agent** coordinates the workflow.

The individual tools handle the specialised processing.

Transition:
I will start with the study problem that motivates the system.

---

## Slide 2: Problem Context

Target: 50 seconds.

Core message:
Students do not just need summaries.
They need repeated transformations of their own material.

VISUAL ANCHOR:
Top headline.
Five-step flow.
Core thesis card.

Students rarely revise from one clean source.

They usually work across lecture PDFs,
scanned pages,
textbook extracts,
notes,
and copied fragments.

The problem is not only that these sources are messy.

The deeper problem is that study requires the same material
to be reused in different forms.

A student may need notes today,
flashcards tomorrow,
and an audio version later.

The flow on the slide shows that movement.

Raw material becomes prepared text.
Prepared text becomes searchable.
Searchable material becomes study artefacts.
Some artefacts become audio.

The core thesis is that AI study support must stay **grounded**
in the student's own material.

Transition:
That practical context creates three barriers for the system to solve.

---

## Slide 3: Problem Statement

Target: 55 seconds.

Core message:
The design problem has three connected barriers.

VISUAL ANCHOR:
Three cards across the top.
Design challenge at the bottom.

The first barrier is input readiness.

Scanned pages and PDFs may be readable to a student,
but they are not directly usable by a language-based assistant.

They need OCR before they can participate in later workflows.

The second barrier is grounded access.

Long or fragmented course material should not be treated
as one uncontrolled prompt.

The student needs to ask,
what does my material say about this topic?

The third barrier is output form.

Study is not one output type.

Sometimes the student needs an explanation.
Sometimes they need active recall.
Sometimes they need essay practice or audio.

The design challenge is to move from raw course material
to source-grounded study artefacts.

Transition:
The project aim and scope are built around that challenge.

---

## Slide 4: Aim, Objectives, and Scope

Target: 55 seconds.

Core message:
The project makes a focused engineering claim,
not a broad educational-impact claim.

VISUAL ANCHOR:
Aim and objectives on the left.
Claim boundary on the right.

The aim is to design and evaluate an agent-based study assistant
for realistic revision workflows.

The system coordinates OCR,
retrieval-augmented assistance,
generation,
and text-to-speech.

The objectives combine student-facing behaviour
with engineering controls.

The system should support multiple study modes.
It should preserve source grounding.
It should keep OCR, RAG, and TTS inspectable as separate tools.
It should evaluate reliability, throughput, model suitability, and workflow feasibility.

The claim boundary is important.

This is a system-design and engineering thesis.

It does not claim measured grade improvement.
It does not replace student judgement.
It does not replace instructor feedback.

The claim is **narrow**,
but it is testable.

Transition:
Within that scope, the requirements follow directly from the workflow barriers.

---

## Slide 5: Study Workflow Requirements

Target: 55 seconds.

Core message:
Each technology is included because it solves a specific study-workflow barrier.

VISUAL ANCHOR:
OCR, RAG, and TTS cards.
Bottom contract strip.

OCR addresses input readiness.

For academic material,
simple character extraction is not enough.

Reading order matters.
Equations matter.
Tables matter.
Missing definitions matter.

RAG addresses grounded access.

It lets the system retrieve from the student's prepared material
instead of relying only on the model's general memory.

TTS addresses output modality.

But speech is not just reading Markdown aloud.

Technical notation and visual structure need to be rewritten
so the result makes sense when heard.

The bottom strip shows the software consequence.

Each path leaves an inspectable artefact:
ordered JSONL,
stored chunks,
or a complete audio file.

Those artefacts make the workflow **inspectable**.

Transition:
The architecture shows how those responsibilities fit together.

---

## Slide 6: Architecture: Flexible Agent, Deterministic Tools

Target: 70 seconds.

Core message:
The agent owns study intent,
while the tools own reliable execution.

VISUAL ANCHOR:
Top lane from input to orchestration to output.
Bottom lanes for OCR, RAG, and TTS.

At the top level,
the student provides a request and source material.

The request contains intent.

The student may want notes,
flashcards,
a quiz,
essay practice,
or audio.

The `study-assistant` interprets that intent
and selects the appropriate mode.

The output is a study artefact,
not just an unstructured chat response.

The lower lanes show the specialised paths.

The OCR path prepares difficult source material as text.

The RAG path stores and retrieves source-grounded chunks.

The TTS path turns prepared material into final audio.

The central architectural decision is separation of concerns.

The agent can remain flexible
because the tools enforce stable contracts.

Those contracts include schemas,
ordering,
exit codes,
retry behaviour,
and artefact publication.

That separation is the architectural **core**.

Transition:
The next slide shows the engineering decisions that make that separation work.

---

## Slide 7: Engineering Decisions

Target: 65 seconds.

Core message:
The engineering design makes model-based workflows testable and inspectable.

VISUAL ANCHOR:
Six decision cards.
Ordered output card.
Failure semantics card.

The first decision is to separate agent orchestration
from deterministic tools.

That prevents the system from becoming one opaque prompt.

The second decision is to keep the processing stages
as standalone command-line tools.

That means each stage can be run,
inspected,
cached,
redirected,
or tested independently.

The third decision is ordered output.

Remote requests may finish in any order,
but the published pages and chunks follow the source order.

The fourth decision is artefact-specific failure behaviour.

Partial OCR can still be useful
if the failed pages are explicit.

Partial final audio is different.

It may sound complete
while silently omitting part of the content.

The shared Nim libraries support the same execution style
across OCR,
retrieval,
and speech.

The design turns model calls into **contracts**.

Transition:
The evaluation checks whether those contracts support realistic study workflows.

---

## Slide 8: Workflow Evaluation Method

Target: 60 seconds.

Core message:
The workflow evaluation follows artefacts through realistic revision tasks.

VISUAL ANCHOR:
Top artefact flow.
Evaluation criteria.
Four workflow cards.

The evaluation is not based on whether one generated answer sounds impressive.

It asks whether the system can move through realistic revision tasks
while leaving enough evidence behind.

The top flow shows the chain.

A PDF becomes OCR text.
OCR text becomes a study-mode output.
Material can be stored and retrieved.
Selected content can become speech.

The criteria are source grounding,
mode appropriateness,
operational reproducibility,
inspectable intermediate artefacts,
and visible limitations.

The recorded workflows cover essay practice,
RAG-based exam revision,
flashcards,
and notes-to-audio.

The evidence is the **chain**,
not just the final answer.

Transition:
Before looking at workflow results, I will show how the implementation contracts are verified.

---

## Slide 9: Testing Strategy and Evaluation Credibility

Target: 55 seconds.

Core message:
The evaluation separates local correctness from live model variability.

VISUAL ANCHOR:
Deterministic evidence column.
Evaluation principle column.

The deterministic tests focus on what the implementation controls.

For OCR,
that includes page selection,
request identifiers,
retry queues,
and JSON result schemas.

For retrieval,
that includes chunk parsing,
configuration,
embeddings,
and SQLite vector integration.

For speech,
that includes chunk splitting,
retry handling,
audio validation,
and final file publication.

The shared libraries are also tested
for transport,
JSON parsing,
and provider request construction.

Live model runs are different.

They are empirical operational evidence,
not deterministic unit tests.

That distinction keeps the evaluation **credible**.

Transition:
The first quantitative result is the OCR throughput benchmark.

---

## Slide 10: Evaluation: OCR Throughput

Target: 70 seconds.

Core message:
Bounded concurrency made the recorded OCR workflow practical without breaking output order.

VISUAL ANCHOR:
15.89x metric.
93.71% metric.
Runtime bars.
Caveat line.

The throughput benchmark used the same 72-page slide PDF
in two configurations.

The sequential baseline used `K=1`.

It took 316.66 seconds
and completed all 72 pages.

The concurrent run used `K=32`.

It took 19.93 seconds
and also completed all 72 pages.

That is a 15.89 times speedup.

It is also a 93.71 percent reduction in runtime.

The improvement comes from overlapping network-bound OCR requests.

It does not come from skipping pages.
It does not come from relaxing output order.

The caveat matters.

This is an operational measurement,
not a universal speed guarantee.

It depends on provider latency,
rate limits,
network conditions,
and document complexity.

The result supports the system's **practicality**.

Transition:
Throughput is only one part of OCR suitability, so the next result looks at model choice.

---

## Slide 11: Evaluation: OCR Model Benchmark

Target: 70 seconds.

Core message:
The OCR model choice is a workflow tradeoff,
not a simple winner-takes-all result.

VISUAL ANCHOR:
Accuracy table.
Cost table.
Selection tradeoff card.

The OCR benchmark uses 68 pages
from 34 academic PDFs.

The pages have human gold labels.

They include equations,
tables,
diagrams,
and multi-column layouts.

That is the kind of material
that makes study-document OCR difficult.

The table shows a tradeoff.

PaddleOCR-VL has the strongest strict accuracy aggregate
in this run.

DeepSeek-OCR is the cheapest.

`olmOCR 2` is selected because it gives the strongest recall-oriented fit
for the study workflow
while costing less than the strict-accuracy winner.

Recall matters in this context.

A missing theorem,
definition,
equation,
or table row
can damage downstream notes,
quizzes,
and explanations.

The selection is about **suitability**,
not only a single metric.

Transition:
The workflow results show how these technical choices appear at the student-facing level.

---

## Slide 12: Workflow Evaluation Results

Target: 80 seconds.

Core message:
The workflow results are strongest
when interpreted critically,
not described as demos.

VISUAL ANCHOR:
Four result cards.

This slide is not a demo checklist.

It is the judgement from the workflow evaluation.

Essay practice showed strong mode fit.

The system moved lecture material
into exam-style reasoning,
which is exactly the purpose of that mode.

The challenge is provenance.

If OCR introduces small errors,
the exact source record still needs to be retained.

RAG exam revision is the strongest usefulness signal.

The answer aligned with course-specific material,
not just a generic model response.

But a defence-level evaluation should show
retrieved evidence beside the final synthesis.

Flashcards worked well as active recall.

The output was concise and examinable.

The weakness is validation:
coverage,
duplicates,
and formula clarity need checking.

The audio workflow showed a strong modality shift.

The notes became listenable revision,
but audio inevitably compresses visual material.

That matters for diagrams,
tables,
and worked examples.

The overall finding is **balanced**.

The workflows are practically useful,
but the next version needs stronger audit trails.

Transition:
Those observations define the limits of the claim.

---

## Slide 13: Critical Interpretation and Threats to Validity

Target: 75 seconds.

Core message:
The project is practically useful inside clear limits.

VISUAL ANCHOR:
Interpretation column.
Threats and limitations column.

The interpretation is that modularity helps.

When OCR,
retrieval,
generation,
and speech are separated,
errors are easier to locate.

Artefact boundaries create practical checkpoints:
page records,
stored chunks,
database entries,
and audio files.

The throughput benchmark supports bounded concurrency
for network-bound OCR.

The workflow evaluation supports practical feasibility
for several revision tasks.

The limitations are equally important.

There is no controlled learning-outcome study.

There is no labelled retrieval benchmark yet.

TTS naturalness is not evaluated subjectively.

The OCR benchmark is dataset-specific.

The throughput results are recorded runs,
not statistical guarantees.

The system also depends on remote providers,
so model behaviour,
pricing,
latency,
and availability can change.

These are **boundaries**,
not excuses.

Transition:
Within those boundaries, the contributions are clear.

---

## Slide 14: Contributions

Target: 55 seconds.

Core message:
The contribution is the cohesive system design,
not one isolated tool.

VISUAL ANCHOR:
Four contribution cards.

The conceptual contribution is the study-workflow framing.

The project treats study assistance
as a source-grounded movement from raw material
to revision artefacts.

The architectural contribution is the separation
between agent orchestration,
tool definitions,
core Nim executables,
and shared libraries.

The technical contribution is the implemented tool ecosystem:
OCR,
semantic retrieval,
and speech generation
with ordering,
retries,
schemas,
and exit contracts.

The evaluation contribution is the combination of contract tests,
throughput evidence,
OCR model comparison,
and workflow critique.

The contribution is **integration**,
with explicit boundaries.

Transition:
The future work follows directly from the gaps exposed by the evaluation.

---

## Slide 15: Future Work

Target: 55 seconds.

Core message:
The next step is stronger evidence and auditability,
not just more features.

VISUAL ANCHOR:
Near-term engineering column.
Broader validation column.

The most immediate future work is run manifests.

Each run should connect the source PDF,
OCR cache entries,
retrieved chunks,
generated text,
TTS input,
and final audio.

That would make workflow evaluation much stronger.

The RAG subsystem also needs labelled retrieval queries
and stored retrieved evidence.

OCR evaluation should use broader corpora
and repeated measurements.

Generated outputs should be checked for coverage,
duplication,
formula ambiguity,
and diagram uncertainty.

The broader validation work includes provider-selection policies,
local or private backends,
human usefulness evaluation,
and learning-outcome studies.

The priority is **auditability**.

Transition:
I will close by returning to the central claim.

---

## Slide 16: Conclusion

Target: 55 seconds.

Core message:
Practical AI study support needs constraints,
not just generation.

VISUAL ANCHOR:
Main conclusion block.
Three metric cards.

The project returns to the three barriers from the beginning.

OCR improves input readiness.

RAG supports source-grounded access.

Study modes and TTS support different revision forms.

The main result is not simply that these tools exist together.

The result is that flexible generation is constrained
by source grounding,
modular tools,
ordered outputs,
and explicit artefact contracts.

The metrics on the right are concrete examples:
72 OCR pages,
26 RAG chunks,
and 24 speech chunks.

They show that the system produces inspectable workflow artefacts.

The final claim is that `study-assistant` makes AI study support
practical,
modular,
and **inspectable**.

Transition:
I will stop here and take questions.

---

## Slide 17: Questions

Target: final hold.

VISUAL ANCHOR:
Large Questions title.

Thank you.

I am happy to take questions.

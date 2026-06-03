# Speaker Notes

Target length: approximately 11:00 spoken time.

Live-delivery notes.
Short beats.
Use silent `>>` markers to recover quickly after looking up.
Speak only the `DELIVERY` and `TRANSITION` lines.
Do not speak the `>>` markers.

---

## Slide 1: Title

Target: 20 seconds.

CORE MESSAGE

This is a study-workflow system.

Not a single chatbot prompt.

DELIVERY

>> INTRO

Mnemon is an agent-based study assistant.

It starts with the student's own course material.

It then coordinates OCR,
retrieval,
generation,
and speech.

The central idea is **coordination**.

TRANSITION

To see why that matters,
consider how revision actually works.

---

## Slide 2: Problem Context

Target: 50 seconds.

CORE MESSAGE

Revision is repeated transformation
of fragmented material.

DELIVERY

>> SOURCES

Students rarely begin with one clean source.

They work across slides,
scans,
textbook pages,
and personal notes.

The process moves through several stages.

>> TRANSFORMATIONS

First,
the material becomes usable text.

Then it becomes searchable.

From there,
it can become different study outputs.

And some of those outputs
can become audio.

The same source keeps changing **form**.

>> PROBLEM

A plain LLM chat
is difficult to manage
across several sources.

It is also harder to trace an answer
back to the passages that support it.

The workflow must remain
source-grounded,
modular,
and inspectable.

TRANSITION

That leads to three design barriers.

---

## Slide 3: Problem Statement

Target: 55 seconds.

CORE MESSAGE

The problem is a chain of three barriers.

DELIVERY

>> OCR

The first barrier is
input readiness.

A student can read a scanned PDF.

OCR converts the scan
into text.

That text can then be searched
and reused.

>> RETRIEVAL

Course material should not be sent
as one large prompt.

The system indexes
the student's material.

For each student query,
it retrieves
the relevant passages.

The student should be able to ask:

what does my material say
about this topic?

>> OUTPUTS

The third is
output form.

Revision needs more than summaries.

It needs explanation,
recall,
essay practice,
and listening.

TRANSITION

That defines the scope
of the project.

---

## Slide 4: Aim, Objectives, and Scope

Target: 55 seconds.

CORE MESSAGE

This is a focused engineering thesis.

DELIVERY

>> TOOLS

The focus is the engineering.

OCR,
RAG,
and TTS remain separate tools.

Each can be run
independently.

>> EVALUATION

The evaluation checks
tool reliability.

It measures OCR performance.

It compares OCR models.

And it reviews whether
the recorded workflows
complete their intended tasks.

>> LIMITS

This project does not claim
measured grade improvement.

It does not replace instructors.

It does not replace student judgement.

Remote model quality,
latency,
cost,
and privacy remain practical constraints.

TRANSITION

Within that scope,
each tool has a precise job.

---

## Slide 5: Study Workflow Requirements

Target: 55 seconds.

CORE MESSAGE

Each tool solves one barrier
and leaves evidence behind.

DELIVERY

>> OCR

OCR extracts text
from scanned documents.

For academic pages,
simple character extraction
is not enough.

Reading order matters.

Tables and equations matter.

Missing content matters too.

OCR errors can affect
everything that comes after.

>> RETRIEVAL

RAG retrieves from the student's
prepared course material.

That keeps later answers tied
to course-specific sources.

It avoids relying only
on the model's general knowledge.

>> AUDIO

TTS changes the **modality**
from text to audio.

Speech is not simply
reading Markdown aloud.

Some content needs rewriting
before it works as audio.

>> ARTIFACTS

Each tool leaves behind
an intermediate artifact.

OCR leaves page records.

RAG leaves retrieved passages.

TTS leaves prepared text.

Those artifacts make
each stage **visible**.

TRANSITION

Next, the architecture shows
where the agent stops
and the tools begin.

---

## Slide 6: Architecture: Flexible Agent, Deterministic Tools

Target: 70 seconds.

CORE MESSAGE

The agent decides what to do.

The tools guarantee how it is done.

DELIVERY

>> AGENT

The student provides source material
and a study request.

`study-assistant` selects
the appropriate mode.

Notes.
Flashcards.
Quiz.
Essay practice.
Audio.

>> TOOLS

The tools handle
the processing.

OCR extracts text
from PDFs.

RAG stores and searches
the student's material.

TTS prepares text
for listening
and creates the audio file.

>> RESPONSIBILITIES

This creates a clear
division of labour.

The agent remains flexible.

The tools also handle caching,
chunking,
retries,
output order,
and clear failures.

TRANSITION

That leads
to several engineering decisions.

---

## Slide 7: Engineering Decisions

Target: 65 seconds.

CORE MESSAGE

Model-driven workflows become testable
when their boundaries are explicit.

DELIVERY

>> COMMAND-LINE TOOLS

To make that separation practical,
the processing tools remain
standalone command-line tools.

They can be run,
inspected,
cached,
and tested independently.

That keeps the system
from becoming one opaque prompt.

>> SHARED LIBRARIES

Shared libraries handle
HTTP requests and JSON
consistently.

>> ORDER

Concurrency can reorder completion.

Published output must still follow source order.

>> PARTIAL OUTPUTS

Failures are handled differently
for each output.

If some OCR requests fail,
the successful pages are still kept.

Partial audio is different.

Incomplete audio
is not published.

TRANSITION

Next, let's look at
how the workflows were evaluated.

---

## Slide 8: Workflow Evaluation Method

Target: 60 seconds.

CORE MESSAGE

Evaluate the evidence chain,
not just the final response.

DELIVERY

>> SAVED OUTPUTS

The evaluation begins with a PDF.

Intermediate outputs are saved
as the workflow progresses.

A final answer
is not enough.

We also inspect
the intermediate outputs.

>> QUESTIONS

The criteria are practical:

Is the output source-grounded?

Does the selected mode fit the task?

Can the intermediate outputs be inspected?

Can the run be reproduced?

Are failures
clearly reported?

>> WORKFLOWS

The four recorded workflows cover
essay practice,
RAG revision,
flashcards,
and notes-to-audio.

TRANSITION

The evaluation
has two parts.

---

## Slide 9: Testing and Recorded Runs

Target: 55 seconds.

CORE MESSAGE

Tests check
what the code controls.

Recorded runs show
what happens
when remote models are called.

DELIVERY

>> LOCAL TESTS

Local tests check the parts
we control:

the tools
and their shared libraries.

>> RECORDED RUNS

Recorded runs show
how the full workflow behaves
when it calls remote models.

Together,
they give us evidence
from both sides.

TRANSITION

The first quantitative result
is OCR throughput.

---

## Slide 10: Evaluation: OCR Throughput

Target: 70 seconds.

CORE MESSAGE

Bounded concurrency made OCR practical
without sacrificing ordered output.

DELIVERY

>> RUNTIME

One request at a time
took just over five minutes.

With up to 32 requests
running at once,
it took about 20 seconds.

Both runs completed
the full document.

That made it
about sixteen times faster.

>> PAGE ORDER

Every page is still included.

The final output remains
in page order.

TRANSITION

Speed is only part
of the picture.

The next question
is model choice.

---

## Slide 11: Evaluation: OCR Model Benchmark

Target: 70 seconds.

CORE MESSAGE

The most accurate model
is not automatically
the best choice.

DELIVERY

>> BENCHMARK

The benchmark covers
nearly 70 academic pages
from a range of PDFs.

The reference transcriptions
were labelled by hand.

These are difficult pages:

equations,
tables,
diagrams,
and multi-column layouts.

>> WHY RECALL MATTERS

For study material,
recall matters.

Missing a theorem,
definition,
equation,
or table row
can affect later notes,
questions,
and audio.

>> MODEL CHOICE

`olmOCR 2` was less likely
to miss important content.

It also cost less
than the most accurate model.

TRANSITION

Now let's see
how the workflows performed.

---

## Slide 12: Workflow Evaluation Results

Target: 80 seconds.

CORE MESSAGE

The workflows are useful,
but the critique matters as much as the output.

DELIVERY

>> ESSAY PRACTICE

Essay practice produced
useful exam-style questions.

But OCR errors make it important
to trace each answer
back to the source.

>> FLASHCARDS

For flashcards,
the cards were concise
and examinable.

They worked well
for active recall.

Future checks should catch
coverage gaps,
duplicates,
and unclear formulae.

>> AUDIO

For audio,
visual notes became
listenable revision material.

But audio cannot fully represent
figures,
tables,
or equations.

>> RETRIEVAL

Retrieval provides
the strongest evidence
of practical value.

The answer matched course-specific material,
not just a generic model response.

TRANSITION

That brings us
to the limitations.

---

## Slide 13: Results and Limitations

Target: 75 seconds.

CORE MESSAGE

The system is practically useful
inside explicit limits.

DELIVERY

>> RESULTS

Separate tools make failures
easier to locate.

Concurrent requests
made OCR faster.

The recorded workflows
completed their intended tasks.

Retrieval quality depends on
how material is split,
labelled,
and retrieved.

>> LIMITATIONS

The limitations matter equally.

There is no controlled study
of learning outcomes
or retention.

The TTS output file is checked,
but not whether
the audio sounds natural.

OCR results depend
on the documents
and provider.

Remote models,
pricing,
latency,
and availability can drift.

TRANSITION

Within those limits,
the contributions are clear.

---

## Slide 14: Contributions

Target: 55 seconds.

CORE MESSAGE

The contribution is the integrated system design.

DELIVERY

>> CONCEPTUAL

Conceptually,
it organises course material
into revision formats
that remain grounded
in the source.

>> ARCHITECTURAL

Architecturally,
it separates the agent
from OCR,
retrieval,
and speech tools.

>> TECHNICAL

Technically,
it adds ordering,
retries,
clear failures,
and saved intermediate artifacts.

>> EVIDENCE

Finally,
the project provides evidence
from tests,
benchmarks,
and recorded workflows.

TRANSITION

That gives us
a foundation
to build on

---

## Slide 15: Future Work

Target: 55 seconds.

CORE MESSAGE

The priority is a stronger audit trail
and stronger evidence.

DELIVERY

>> TRACEABILITY

Each run should be traceable
from the source PDF
to the final output.

That would strengthen
the workflow evaluation.

>> RETRIEVAL AND OCR

Retrieval should be tested
with fixed questions
and expected passages.

OCR evaluation should cover
more documents
and repeated measurements.

>> VALIDATION

Validation passes should check formulae,
diagrams,
duplicates,
coverage gaps,
and unclear content.

>> PROVIDERS

Broader validation should compare
providers and models
for cost,
latency,
quality,
and privacy.

It should also examine local
or private model inference
for sensitive course material.

>> STUDENTS

Then students should evaluate
whether the outputs are useful.

And eventually,
study the effects on retention
and exam preparation.

TRANSITION

That brings us
to the conclusion.

---

## Slide 16: Conclusion

Target: 55 seconds.

CORE MESSAGE

The workflow needs constraints,
not just generation.

DELIVERY

>> MAIN CONTRIBUTION

The project shows
a different way
to build an AI study assistant.

Give an agent
a set of open tools.

Keep those tools separate.

Make them easy to inspect,
change,
and run on their own.

That is the main contribution.

TRANSITION

---

## Slide 17: Questions

Target: final hold.

CORE MESSAGE

Hold the final frame.

DELIVERY

Thank you.

I am happy to take questions.

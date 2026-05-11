= User Manual <app:user-manual>


This appendix summarises operator-facing use of the study-assistant tool suite. The agent coordinates workflows, while the command-line tools remain available for direct use.

== Agent Workflow


Use `study-assistant` when the goal is to transform prepared study material into one of the supported outputs:

- verbatim transcription;
- lecture-style explanation;
- ELI5 explanation;
- flashcards;
- Mermaid mind map;
- quiz with answer key;
- essay prompts and sample answers;
- exam-focused study notes.

The agent requires source material that is already text or has been extracted through the OCR workflow.

== OCR Workflow


OCR selected PDF pages:

```bash
pdfocr INPUT.pdf --pages:"1,4-6,12" > results.jsonl
```


OCR all pages:

```bash
pdfocr INPUT.pdf --all-pages > results.jsonl
```


The `--pages` selector uses 1-based page numbering and supports single pages, inclusive ranges, and comma-separated combinations. Exactly one selector mode must be supplied.

On non-fatal completion, stdout contains JSON Lines only, with one object per selected page in strict page order.

Success example:

```json
{"page":12,"status":"ok","attempts":1,"text":"..."}
```


Error example:

```json
{
  "page": 12,
  "status": "error",
  "attempts": 3,
  "error_kind": "Timeout",
  "error_message": "...",
  "http_status": 504
}
```


== RAG Store Workflow


Prepare a marked text file using `<chunk ...>` markers:

```text
<chunk page=4 label="Embeddings">
Embeddings map text into vectors where similar meanings stay close.

<chunk page=5 label="Vector Search">
Nearest-neighbour search compares a query vector against stored vectors.
```


Ingest it:

```bash
cvstore --doc=notes-course --kind=source --source=course/notes.md notes.txt
```


The `doc` value should be stable so that retrieval can target the same logical material.

== RAG Search Workflow


Query stored material:

```bash
cvquery --doc=notes-course --kind=source "How do embeddings help search?"
```


Optional filters include `--doc`, `--kind`, `--page`, and `--label`, subject to the tool's validation rules.

== TTS Workflow


Prepare text with `<bk>` boundaries:

```text
Introduction paragraph.<bk>
This should become the second spoken section.<bk>
Closing section.
```


Generate audio:

```bash
chunktts input.txt output.opus
```


The output is one final `.opus` file. Logs and fatal errors are written to stderr.

== Configuration


The core tools support optional `config.json` files beside their executables. API keys can be supplied through `DEEPINFRA_API_KEY` or through tool configuration. The environment variable takes precedence when present and non-empty.

Typical configurable values include endpoint URLs, model names, concurrency limits, retry counts, timeouts, OCR render settings, embedding dimensions, and TTS voice/speed.

== Exit Codes


The command-line tools use stable exit codes:

- `0`: requested work succeeded;
- `2`: processing completed with permanent item failures where the tool contract permits this result;
- `3`: fatal startup or runtime failure.

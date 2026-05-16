# Final Year Project — Typst Sources

Typst-based build for the thesis and defense presentation of:

**Mnemon** — An Agent-Based Study Assistant System with OCR, Retrieval-Augmented Generation, and Text-to-Speech Tools

Antonis Geralis — University of Nicosia, May 2026

Project codename: **Mnemon** (Μνήμων — mindful, remembering).

## Repository layout

```
thesis/
  report.typ            Thesis entry point (APA 7 template)
  lib.typ               Shared helper functions
  report.pdf            Compiled thesis
  sections/             Thesis chapters (ch01–ch09) + abstract + acknowledgements
  appendices/           Administrative data and appendices A–D
  bibliography/         CSL-backed reference data (references.yml)
  assets/               Diagram helpers and style files
  utils/                Internal utilities (APA figure, appendix, title, etc.)

presentation/
  defense.typ           Defense slide deck source
  defense.pdf           Compiled slides
  deck/                 Slide theme and reusable layout components
  speaker-notes.md      Per-slide delivery notes (~20 min target)

workflows/              Recorded study-workflow artefacts
  wf1-transcribe/       OCR transcription output
  wf2-rag/              RAG store and search outputs
  wf3-flashcards/       Flashcard generation output
  wf4-tts/              Study-notes-to-audio pipeline
```

## Build

```bash
# Thesis
typst compile thesis/report.typ thesis/report.pdf

# Presentation
typst compile presentation/defense.typ presentation/defense.pdf
```

## License

Apache License 2.0 — see [LICENSE.txt](LICENSE.txt).

# Final Year Project Thesis

This Typst project contains the APA 7 template-based thesis build for:

*An Agent-Based Study Assistant System with OCR, Retrieval-Augmented Generation, and Text-to-Speech Tools*

## Structure

- `report.typ` is the main entry point and applies the `versatile-apa` template.
- `sections/` contains the abstract, acknowledgements, and thesis chapters.
- `appendices/` contains appendix content using the template appendix system.
- `bibliography/` contains the CSL-backed reference data and citation anchors used by the preserved in-text numeric citation labels.
- `assets/` contains project-local generated diagram helpers.
- `versatile-apa/` contains the APA 7 Typst template used by the thesis.

## Build

From this directory:

```bash
typst compile report.typ report.pdf
```

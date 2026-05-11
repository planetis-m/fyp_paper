= Installation and Build Guide <app:installation-build>


This appendix summarises installation and build requirements for the unified tool suite.

== Prebuilt Binaries


The core tools are designed to be distributed as platform-specific command-line binaries:

- `pdfocr`;
- `cvstore` and `cvquery`;
- `chunktts`.

Runtime dependencies vary by tool and platform:

- `pdfocr`: `libcurl` and `libwebp`; the release archive also includes the PDFium runtime library, which must remain beside the executable.
- `cvstore` and `cvquery`: `libcurl`, SQLite, and the platform `sqlite-vector` runtime library (`vector.so`, `vector.dylib`, or `vector.dll`) beside the executables.
- `chunktts`: `libcurl` and `libsndfile`.

Typical Linux runtime packages are `libcurl4`, `libwebp7`, `sqlite3`, and `libsndfile1`, depending on which tools are installed. On macOS, install `curl`, `webp`, `sqlite`, and `libsndfile` with Homebrew as needed. Windows release archives bundle the required DLLs; keep those DLLs in the same directory as the `.exe` files.

== Source Build Overview


The implementations are Nim projects. Source builds require:

- Nim;
- Atlas or Nimble dependency resolution as documented by each repository;
- platform development packages for the relevant native libraries; and
- downloaded native runtime artefacts where required, specifically PDFium for `pdfocr` and `sqlite-vector` for `cvstore` and `cvquery`.

On Linux, the development packages used by the project workflows are `libcurl4-openssl-dev`, `libwebp-dev`, `sqlite3`, and `libsndfile1-dev`. On macOS, the workflows use Homebrew packages `curl`, `webp`, `sqlite`, and `libsndfile`. On Windows, the workflows use vcpkg packages such as `curl[http2,ssl,c-ares]`, `libwebp`, `sqlite3`, and `libsndfile`.

The common build shape is:

```bash
atlas install
nim c -d:release -o:TOOL src/ENTRYPOINT.nim
```


Representative outputs are:

```bash
nim c -d:release -o:pdfocr src/app.nim
nim c -d:release -o:cvstore src/cvstore.nim
nim c -d:release -o:cvquery src/cvquery.nim
nim c -d:release -o:chunktts src/app.nim
```


== Shared Libraries


The processing tools depend on the custom libraries:

- `relay` for HTTP;
- `jsonx` for JSON;
- `openai` for OpenAI-compatible API schemas and helpers.

These libraries are resolved as Nim dependencies in the tool repositories.

== Testing


Each repository exposes a Nim test task. The common command form is:

```bash
nim test tests/ci.nims
```


Live end-to-end runs require model-provider credentials. Deterministic unit and integration tests cover local parsing, retry, ordering, JSON, vector, and audio-validation behavior where possible.

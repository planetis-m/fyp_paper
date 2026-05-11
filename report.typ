#import "versatile-apa/lib.typ": abstract-page, appendix, appendix-outline, title-page, versatile-apa as apa-style

#set document(
  title: [An Agent-Based Study Assistant System with OCR, Retrieval-Augmented Generation, and Text-to-Speech Tools],
  author: "Antonis Geralis",
  keywords: ("study assistant", "OCR", "retrieval-augmented generation", "text-to-speech"),
)

#show: apa-style.with(
  font-size: 12pt,
  running-head: [AGENT-BASED STUDY ASSISTANT],
)

#let thesis-title = [An Agent-Based Study Assistant System with OCR, Retrieval-Augmented Generation, and Text-to-Speech Tools]
#let author-name = [Antonis Geralis]

#title-page(
  title: thesis-title,
  authors: (
    (
      name: author-name,
      affiliations: "unic",
    ),
  ),
  affiliations: (
    "unic": [Department of Computer Science, School of Sciences and Engineering, University of Nicosia],
  ),
  course: [Final Year Project submitted in partial fulfilment of the requirements for the Degree of Bachelor of Science in Computer Science],
  instructor: [Project Advisor: Ioannis Katakis],
  due-date: [May 2026],
)

#abstract-page(
  {
    include "sections/abstract.typ"
  },
  keywords: ("study assistant", "OCR", "retrieval-augmented generation", "text-to-speech"),
)

= Acknowledgements

#include "sections/acknowledgements.typ"

#pagebreak()
#outline(title: [Table of Contents], depth: 3)
#pagebreak()
#outline(target: figure.where(kind: table), title: [List of Tables])
#pagebreak()
#outline(target: figure.where(kind: image), title: [List of Figures])
#pagebreak()
#outline(target: figure.where(kind: math.equation), title: [List of Equations])
#pagebreak()
#outline(target: figure.where(kind: raw), title: [List of Listings])
#pagebreak()
#appendix-outline(title: [Appendices])
#pagebreak()

#set heading(numbering: "1.1")

#include "sections/ch01-introduction.typ"
#pagebreak()
#include "sections/ch02-background-related-work.typ"
#pagebreak()
#include "sections/ch03-requirements-and-specification.typ"
#pagebreak()
#include "sections/ch04-architecture-and-design.typ"
#pagebreak()
#include "sections/ch05-implementation.typ"
#pagebreak()
#include "sections/ch06-testing-and-evaluation.typ"
#pagebreak()
#include "sections/ch07-usage-workflows.typ"
#pagebreak()
#include "sections/ch08-discussion-contributions.typ"
#pagebreak()
#include "sections/ch09-conclusion-future-work.typ"

#pagebreak()
#include "bibliography/reference-anchors.typ"
#bibliography(
  "bibliography/references.yml",
  full: true,
  title: [References],
)

#show: appendix.with(numbering-for-all: true)

#include "appendices/appendix-a-user-manual.typ"
#include "appendices/appendix-b-installation-build.typ"
#include "appendices/appendix-c-benchmarks-testcases.typ"
#include "appendices/appendix-d-code-listings.typ"
#include "appendices/administrative-data.typ"

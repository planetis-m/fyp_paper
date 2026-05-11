#import "versatile-apa/lib.typ": abstract-page, appendix, appendix-outline, versatile-apa as apa-style

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
#let degree = [Bachelor of Science in Computer Science]
#let department = [Department of Computer Science]
#let school = [School of Sciences and Engineering]
#let university = [University of Nicosia]
#let submission-date = [May 2026]

#align(center)[
  #set par(first-line-indent: 0in)
  #v(1fr)
  #text(weight: "bold")[#thesis-title]

  #v(1.1in)
  #text(weight: "bold")[Candidate] \
  #author-name

  #v(0.8in)
  Final Year Project submitted in partial fulfilment of the requirements for the Degree of

  #v(0.25in)
  #degree \
  #department \
  #school \
  #university

  #v(0.8in)
  #submission-date
  #v(1fr)
]

#pagebreak()

#align(center)[
  #set par(first-line-indent: 0in)
  #text(weight: "bold")[Acceptance Page]

  #v(0.55in)
  #text(weight: "bold")[#thesis-title]

  #v(0.35in)
  By
  #parbreak()

  #author-name

  #v(0.55in)
  This Final Year Project has been accepted in partial fulfilment of the requirements for the Degree of

  #v(0.25in)
  #degree
]

#v(0.5in)

#table(
  columns: (1.25in, 2in, 1.35in, 1.1in),
  align: (x, y) => if y == 0 { center } else if x <= 1 { left } else { center },
  table.header([Role], [Name], [Signature], [Date]),
  [Project Advisor], [Ioannis Katakis], [#move(dy: 0.6em, line(length: 1in))], [#move(dy: 0.6em, line(length: 0.75in))],
  [Examiner], [Athena Stassopoulou], [#move(dy: 0.6em, line(length: 1in))], [#move(dy: 0.6em, line(length: 0.75in))],
  [Examiner], [Vaso Stylianou], [#move(dy: 0.6em, line(length: 1in))], [#move(dy: 0.6em, line(length: 0.75in))],
)

#v(1fr)

#align(center)[
  #set par(first-line-indent: 0in)
  #department \
  #school \
  #university
]

#pagebreak()

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
#outline(title: [Appendices], target: heading.where(supplement: [Appendix]))
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

#[
  #show: appendix.with(numbering-for-all: true)

  #include "appendices/appendix-a-user-manual.typ"
  #include "appendices/appendix-b-installation-build.typ"
  #include "appendices/appendix-c-benchmarks-testcases.typ"
  #include "appendices/appendix-d-code-listings.typ"
]

#include "appendices/administrative-data.typ"

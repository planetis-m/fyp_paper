#set document(
  title: [Declaration of Responsibility],
  author: "Antonios Geralis",
)

#set page(
  paper: "a4",
  margin: (top: 1in, bottom: 1in, left: 1in, right: 1in),
)

#set text(font: "New Computer Modern", size: 12pt)
#set par(leading: 0.65em, justify: true)

#let filled-field(label, value, width: 4.0in) = {
  grid(
    columns: (1.85in, width),
    gutter: 0.15in,
    align: (left, bottom),
    label,
    box(width: width)[
      #align(center)[#value]
      #v(-0.14in)
      #line(length: 100%, stroke: 0.45pt)
    ],
  )
}

#let full-width-field(value) = {
  box(width: 100%)[
    #align(center)[#value]
    #v(-0.14in)
    #line(length: 100%, stroke: 0.45pt)
  ]
}

#let signature-field() = {
  grid(
    columns: (1.85in, 2.5in),
    gutter: 0.15in,
    align: (left, bottom),
    move(dy: 0.72in)[Signature:],
    box(width: 2.5in)[
      #v(0.815in)
      #line(length: 100%, stroke: 0.45pt)
    ],
  )
}

#align(center)[
  #text(size: 15pt, weight: "bold")[DECLARATION OF RESPONSIBILITY]
]

#v(0.45in)

#set par(justify: false)

#filled-field([Full Name:], [Antonios Geralis])

#v(0.15in)

#filled-field([Student ID Number:], [U214N2586])

#v(0.35in)

I hereby declare that my postgraduate thesis titled:

#v(0.15in)

#full-width-field[
  “Mnemon” — An Agent-Based Study Assistant System with OCR, Retrieval-Augmented Generation, and Text-to-Speech Tools
]

#v(0.25in)

#set par(justify: true)

has been prepared solely by me in fulfillment of the academic requirements of the University of Nicosia.

All sources used have been properly acknowledged in accordance with academic integrity standards.

Any AI tools were utilized only for support purposes (e.g., language editing or code assistance), and not for generating or writing any section or part of this thesis, its analysis, or conclusions.

Any support of use is disclosed in the introductory chapter of this thesis. I retain full responsibility for the originality, accuracy, and integrity of the work.

I understand that submitting a false declaration may result in academic penalties.

Submission of this form together with the thesis is mandatory.

#v(0.55in)

#set par(justify: false)

#signature-field()

#v(0.2in)

#filled-field([Date:], [May 25, 2026], width: 2.5in)

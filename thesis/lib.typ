#import "utils/to-string.typ": to-string
#import "utils/languages.typ": get-terms, language-terms
#import "utils/authoring.typ": print-affiliations, print-authors
#import "utils/appendix.typ": appendix, appendix-outline
#import "utils/apa-figure.typ": apa-figure
#import "utils/abstract.typ": abstract-page
#import "utils/title.typ": title-page
#import "utils/constants.typ": double-spacing, first-indent-length, quote-word-trigger


/// The APA 7th edition template for academic and professional documents.
#let versatile-apa(
  font-size: 12pt,
  custom-terms: (:),
  running-head: none,
  running-head-limit: 50,
  body,
) = {
  context language-terms.update(custom-terms)

  set text(
    size: font-size,
  )

  show std.title: set text(size: font-size, weight: "bold")
  show std.title: set block(spacing: double-spacing)
  show std.title: set align(center)

  set page(
    paper: "us-letter",
    numbering: "1",
    number-align: top + right,
    margin: 1in,
    header: if running-head != none {
      grid(
        columns: (1fr, auto),
        upper(running-head), context here().page(),
      )
    } else { auto },
  )

  set par(
    leading: double-spacing,
    spacing: double-spacing,
  )

  // Show-set rules are at least, easier to override compared to show-function
  // https://github.com/typst/typst/discussions/2883
  show link: set text(fill: blue)
  show link: underline // considering one would want to disable underline, current workaround is set its stroke to 0pt

  if running-head != none {
    if type(running-head) == content { running-head = to-string(running-head) }
    if running-head.len() > running-head-limit {
      panic(
        "Running head must be no more than",
        running-head-limit,
        "characters, including spaces and punctuation.",
        "Current length:",
        running-head.len(),
      )
    }
  }

  // Approximate LaTeX's 12pt report-class heading scale and spacing.
  let latex-chapter-size = font-size * 2.07
  let latex-section-size = font-size * 1.44
  let latex-subsection-size = font-size * 1.2
  let latex-chapter-before = font-size * 4.15
  let latex-chapter-after = font-size * 3.3

  show heading: set text(size: font-size, weight: "bold")
  show heading: set align(left)
  show heading: set block(above: 1.75em, below: 1.15em, sticky: true)

  show heading.where(level: 1): set text(size: latex-chapter-size)
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    block(above: latex-chapter-before, below: latex-chapter-after, sticky: true)[#it]
  }
  show heading.where(level: 2): set text(size: latex-section-size)
  show heading.where(level: 2): set block(above: 1.75em, below: 1.15em, sticky: true)
  show heading.where(level: 3): set text(size: latex-subsection-size)
  show heading.where(level: 3): set block(above: 1.6em, below: 0.75em, sticky: true)
  show heading.where(level: 4): set block(above: 1.5em, below: 0.65em, sticky: true)
  show heading.where(level: 5): set block(above: 1.5em, below: 0.65em, sticky: true)

  set par(
    first-line-indent: (
      amount: first-indent-length,
      all: true,
    ),
    leading: double-spacing,
  )

  show table.cell: set par(leading: 1.18em)
  show table.cell.where(y: 0): set text(weight: "bold")

  show figure.where(kind: image): set block(above: 1.2em, below: 1.2em, breakable: true, sticky: true)
  show figure.where(kind: table): set block(above: 1.2em, below: 1.2em, breakable: true, sticky: false)

  set figure(
    gap: 0.65em,
    placement: auto,
  )

  show figure: set figure.caption(separator: [], position: bottom)
  show figure.caption: set align(center)
  show figure.caption: set par(first-line-indent: 0em)
  show figure.caption: it => {
    block(above: 0pt, below: 0pt, width: 100%)[
      #set text(size: font-size * 0.9)
      #strong[#it.supplement #context it.counter.display(it.numbering):]
      #h(0.35em)
      #it.body
    ]
  }

  set table(
    inset: (x: 0.55em, y: 0.45em),
    stroke: (x, y) => if y == 0 {
      (
        top: (thickness: 0.9pt, dash: "solid"),
        bottom: (thickness: 0.45pt, dash: "solid"),
      )
    } else {
      (bottom: (thickness: 0.25pt, dash: "solid", paint: luma(210)))
    },
  )

  set list(
    marker: ([•], [–]),
    indent: 2.1em,
    body-indent: 1em,
    spacing: double-spacing,
    tight: false,
  )

  set enum(
    indent: 2.15em,
    body-indent: 1em,
    spacing: double-spacing,
    tight: false,
  )

  set raw(
    tab-size: 4,
    block: true,
  )

  show raw.where(block: true): block.with(
    above: 1em,
    below: 1em,
    fill: luma(250),
    stroke: 0.45pt + luma(170),
    inset: (x: 0.9em, y: 0.65em),
    width: 100%,
    breakable: true,
  )

  show raw.where(block: false): set text(size: 0.95em)

  show raw.where(block: true): set text(size: font-size * 0.85)
  show raw.where(block: true): set par(leading: 1.1em)
  show figure.where(kind: raw): set block(breakable: true, sticky: false, width: 100%)

  set math.equation(numbering: "(1)")

  show quote.where(block: true): set block(spacing: double-spacing)

  show quote: it => context {
    let quote-text-words = to-string(it.body).split(regex("\\s+")).filter(word => word != "").len()

    // https://apastyle.apa.org/style-grammar-guidelines/citations/quotations
    if quote-text-words < quote-word-trigger.get() {
      ["#it.body" ]

      if (type(it.attribution) == label) {
        cite(it.attribution)
      } else if (
        type(it.attribution) == str or type(it.attribution) == content
      ) {
        it.attribution
      }
    } else {
      block(inset: (left: 0.5in))[
        #set par(first-line-indent: 0.5in)
        #it.body
        #if (type(it.attribution) == label) {
          cite(it.attribution)
        } else if (type(it.attribution) == str or type(it.attribution) == content) {
          it.attribution
        }
      ]
    }
  }

  show outline.entry: it => context {
    let entry = if (
      (
        it.element.supplement == [#context get-terms(text.lang, text.script).Appendix]
      )
        and it.element.has("level")
        and it.element.level == 1
    ) {
      link(it.element.location(), it.indented([#it.element.supplement #it.prefix().], it.inner()))
    } else {
      it
    }

    if it.element.has("level") and it.element.level == 1 {
      strong(entry)
    } else {
      entry
    }
  }

  set outline(depth: 3, indent: 1.8em)

  set bibliography(style: "assets/styles/apa.csl")
  show bibliography: set par(
    first-line-indent: 0in,
    hanging-indent: 0.5in,
  )

  body
}

#let excerpt(body) = block(
  above: 1em,
  below: 1em,
  fill: luma(250),
  stroke: 0.45pt + luma(170),
  inset: (x: 0.9em, y: 0.65em),
  width: 100%,
  breakable: true,
)[
  #set par(first-line-indent: 0pt)
  #body
]

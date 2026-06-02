// Reusable layout and content components for the defense deck.

#import "theme.typ": *

#let slide-title(body) = block(below: slide-title-gap)[
  #grid(columns: (1fr,), align: horizon)[
    #text(size: slide-title-size, weight: slide-title-weight, fill: ink)[#body]
  ]
  #v(0.08cm)
  #line(length: 100%, stroke: title-rule-stroke + line-color)
]

#let slide(title, body) = [
  #slide-title(title)
  #v(slide-body-gap)
  #body
]

#let card(title, body, fill: white, height: auto) = block(
  width: 100%,
  height: height,
  inset: card-inset,
  radius: radius,
  fill: fill,
  stroke: card-stroke + line-color,
)[
  #text(size: card-title-size, weight: "bold", fill: ink)[#title]
  #v(0.18cm)
  #set par(leading: body-leading, spacing: body-spacing)
  #set list(spacing: list-spacing, tight: false)
  #text(size: card-body-size, fill: ink)[#body]
]

#let metric(value, label, note: none, fill: soft, inset: metric-inset) = block(
  width: 100%,
  inset: inset,
  radius: radius,
  fill: fill,
  stroke: card-stroke + line-color,
)[
  #text(size: 18pt, weight: "bold", fill: accent-dark)[#value]
  #v(0.025cm)
  #text(size: 6.9pt, weight: "semibold", fill: ink)[#label]
  #if note != none [
    #v(0.04cm)
    #text(size: 6.2pt, fill: muted)[#note]
  ]
]

#let eyebrow(body) = text(size: 6.35pt, weight: "bold", fill: muted)[#upper(body)]

#let subhead(body) = [
  #text(size: 8.45pt, weight: "bold", fill: accent-dark)[#body]
  #v(0.16cm)
]

#let bar(label, value, maximum, color: accent) = [
  #grid(columns: (2.95cm, 1fr, 1.2cm), gutter: 5pt, align: horizon)[
    #text(size: 6.7pt, fill: ink)[#label]
  ][
    #box(width: 100%, height: 0.24cm, fill: bar-track, radius: 2pt)[
      #box(width: (value / maximum) * 100%, height: 0.24cm, fill: color, radius: 2pt)
    ]
  ][
    #align(right)[#text(size: 6.7pt, weight: "bold", fill: ink)[#value]]
  ]
]

#let spacious-list(body, size: 7.6pt) = [
  #set par(leading: 0.88em, spacing: 0em)
  #set list(spacing: list-spacing, tight: false)
  #set enum(spacing: list-spacing, tight: false)
  #text(size: size)[#body]
]

#let surface(body, fill: panel) = block(
  width: 100%,
  inset: surface-inset,
  radius: radius,
  fill: fill,
  stroke: surface-stroke + shadow-line,
)[#body]

#let big-statement(body) = block(width: 100%)[
  #text(size: statement-size, weight: statement-weight, fill: ink)[#body]
]

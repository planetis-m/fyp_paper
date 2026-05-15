// Reusable layout and content components for the defense deck.

#import "theme.typ": *

#let slide-title(body) = block(below: slide-title-gap)[
  #grid(columns: (1fr,), align: horizon)[
    #text(size: slide-title-size, weight: "bold", fill: ink)[#body]
  ]
  #v(0.08cm)
  #line(length: 100%, stroke: title-rule-stroke + line-color)
]

#let slide(title, body) = [
  #slide-title(title)
  #v(slide-body-gap)
  #body
]

#let section-slide(title, subtitle) = [
  #v(section-top-space)
  #block(width: 78%)[
    #line(length: 1.45cm, stroke: 0.65pt + accent)
    #v(0.32cm)
    #text(size: section-title-size, weight: "bold", fill: ink)[#title]
    #v(0.22cm)
    #text(size: 9.2pt, fill: muted)[#subtitle]
  ]
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
  #v(0.12cm)
  #set par(leading: 0.75em, spacing: body-spacing)
  #set list(spacing: 0.3em)
  #text(size: card-body-size, fill: ink)[#body]
]

#let metric(value, label, note: none, fill: soft) = block(
  width: 100%,
  inset: metric-inset,
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

#let note-box(body, fill: soft-2, height: auto) = block(
  width: 100%,
  height: height,
  inset: note-inset,
  radius: radius,
  fill: fill,
  stroke: card-stroke + line-color,
)[#text(size: 7.2pt, fill: ink)[#body]]

#let lane(label, body, fill: white) = block(
  width: 100%,
  inset: lane-inset,
  radius: radius,
  fill: fill,
  stroke: card-stroke + line-color,
)[
  #text(size: 6.3pt, weight: "bold", fill: muted)[#upper(label)]
  #v(0.06cm)
  #text(size: 7.3pt, weight: "semibold", fill: ink)[#body]
]

#let flow(items) = {
  let cols = ()
  let cells = ()
  for i in range(items.len()) {
    cols.push(1fr)
    cells.push(box(
      width: 100%,
      inset: (x: 5.5pt, y: 6.5pt),
      radius: radius,
      fill: if calc.rem(i, 2) == 0 { panel } else { soft },
      stroke: card-stroke + line-color,
    )[#align(center)[#text(size: 6.75pt, weight: "semibold")[#items.at(i)]]])
    if i < items.len() - 1 {
      cols.push(auto)
      cells.push(text(size: 8.2pt, fill: accent)[→])
    }
  }
  block(width: 100%)[
    #grid(columns: cols, gutter: 4pt, align: horizon, ..cells)
  ]
}

#let bar(label, value, max, color: accent) = [
  #grid(columns: (2.95cm, 1fr, 1.2cm), gutter: 5pt, align: horizon)[
    #text(size: 6.7pt, fill: ink)[#label]
  ][
    #box(width: 100%, height: 0.24cm, fill: bar-track, radius: 2pt)[
      #box(width: (value / max) * 100%, height: 0.24cm, fill: color, radius: 2pt)
    ]
  ][
    #align(right)[#text(size: 6.7pt, weight: "bold", fill: ink)[#value]]
  ]
]

#let spacious-list(body, size: 7.6pt) = [
  #set par(leading: 0.68em, spacing: 0em)
  #set list(spacing: 0.5em)
  #set enum(spacing: 0.5em)
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
  #text(size: 11.4pt, weight: "bold", fill: ink)[#body]
]

#import "@preview/cetz:0.3.4": canvas, draw

#let cbox(
  pos,
  title,
  body: none,
  name: none,
  fill: rgb("#f7f8fa"),
  stroke: rgb("#c3ccd4"),
  width: 2.05,
  height: .95,
) = {
  let x = pos.at(0)
  let y = pos.at(1)
  draw.content(
    (x - width / 2, y - height / 2),
    (x + width / 2, y + height / 2),
    align(center + horizon)[
      #set par(justify: false, leading: 0.46em, spacing: 0em)
      #set text(hyphenate: false)
      #text(size: 8.4pt)[
        *#title*
        #if body != none [
          #linebreak()
          #text(size: 7.3pt)[#body]
        ]
      ]
    ],
    frame: "rect",
    fill: fill,
    stroke: 0.45pt + stroke,
    padding: .06,
    name: name,
  )
}

#let cwide(pos, title, body: none, name: none, width: 2.55, height: .98) = {
  cbox(pos, title, body: body, name: name, width: width, height: height)
}

#let cstore(pos, title, body: none, name: none, width: 2.05, height: .95) = {
  cbox(pos, title, body: body, name: name, fill: rgb("#edf4f5"), stroke: rgb("#7fa9af"), width: width, height: height)
}

#let cdecision(pos, title, body: none, name: none, width: 2.05, height: .95) = {
  cbox(pos, title, body: body, name: name, fill: rgb("#f4f0eb"), stroke: rgb("#a98d72"), width: width, height: height)
}

#let carrow(from, to) = {
  draw.line(from, to, mark: (end: ">"), stroke: 0.5pt + rgb("#52606b"))
}

#let cpatharrow(..pts) = {
  draw.line(..pts, mark: (end: ">"), stroke: 0.5pt + rgb("#52606b"))
}

#let ctext(pos, body, size: 7pt, width: .72, height: .24) = {
  let x = pos.at(0)
  let y = pos.at(1)
  draw.content(
    (x - width / 2, y - height / 2),
    (x + width / 2, y + height / 2),
    align(center + horizon)[#text(size: size)[#body]],
  )
}

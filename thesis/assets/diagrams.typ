#import "@preview/cetz:0.3.4": canvas, draw

#let colors = (
  ink: rgb("#1f2933"),
  muted: rgb("#52606b"),
  line: rgb("#9aa6b2"),
  grid: rgb("#d9e2ec"),
  agent-fill: rgb("#e8f0fb"),
  agent-line: rgb("#5277a3"),
  tool-fill: rgb("#edf2f7"),
  tool-line: rgb("#6b7c8f"),
  core-fill: rgb("#f6f7f9"),
  core-line: rgb("#495766"),
  store-fill: rgb("#e8f4f0"),
  store-line: rgb("#4f8f7a"),
  external-fill: rgb("#fff4df"),
  external-line: rgb("#b7791f"),
  retry-fill: rgb("#fff0ed"),
  retry-line: rgb("#b95d4f"),
  ok-fill: rgb("#eef8ee"),
  ok-line: rgb("#5f9f6a"),
  warn-fill: rgb("#fff7db"),
  warn-line: rgb("#b38b00"),
  purple-fill: rgb("#f0eefc"),
  purple-line: rgb("#7463b6"),
)

#let node-scale = 1.5
#let compact-node-scale = node-scale

#let kind-style(kind) = (
  agent: (fill: colors.agent-fill, stroke: colors.agent-line),
  tool: (fill: colors.tool-fill, stroke: colors.tool-line),
  core: (fill: colors.core-fill, stroke: colors.core-line),
  store: (fill: colors.store-fill, stroke: colors.store-line),
  external: (fill: colors.external-fill, stroke: colors.external-line),
  retry: (fill: colors.retry-fill, stroke: colors.retry-line),
  ok: (fill: colors.ok-fill, stroke: colors.ok-line),
  warn: (fill: colors.warn-fill, stroke: colors.warn-line),
  evidence: (fill: colors.purple-fill, stroke: colors.purple-line),
).at(kind, default: (fill: colors.core-fill, stroke: colors.core-line))

#let box-node(
  pos,
  title,
  subtitle: none,
  name: none,
  kind: "core",
  width: 2.35,
  height: .82,
  title-size: 8pt,
  body-size: 6.9pt,
  scale: node-scale,
) = {
  let style = kind-style(kind)
  draw.content(
    pos,
    align(center + horizon)[
      #set par(justify: false, leading: .43em, spacing: 0em)
      #set text(size: title-size, weight: "semibold", hyphenate: false, fill: colors.ink)
      #title
      #if subtitle != none [
        #linebreak()
        #set text(size: body-size, weight: "regular", fill: colors.muted)
        #subtitle
      ]
    ],
    frame: "rect",
    fill: style.fill,
    stroke: .55pt + style.stroke,
    padding: .09,
    name: name,
  )
}

#let small-label(pos, body, width: 1.0, height: .24, size: 6.4pt, fill: white) = {
  let x = pos.at(0)
  let y = pos.at(1)
  draw.content(
    (x - width / 2, y - height / 2),
    (x + width / 2, y + height / 2),
    align(center + horizon)[
      #set par(justify: false, leading: .4em)
      #set text(size: size, fill: colors.muted)
      #body
    ],
    fill: fill,
    padding: 0pt,
  )
}

#let band(y, height, title, subtitle: none, width: 15.8, kind: "core") = {
  let style = kind-style(kind)
  draw.rect(
    (-.25, y - height / 2),
    (width, y + height / 2),
    fill: style.fill,
    stroke: .45pt + style.stroke,
  )
  draw.content(
    (-.1, y - height / 2 + .08),
    (2.35, y + height / 2 - .08),
    align(left + horizon)[
      #set par(justify: false, leading: .45em, spacing: 0em)
      #set text(size: 7.5pt, weight: "bold", fill: style.stroke)
      #title
      #if subtitle != none [
        #linebreak()
        #set text(size: 6.4pt, weight: "regular", fill: colors.muted)
        #subtitle
      ]
    ],
  )
}

#let boundary(a, b, title, kind: "core") = {
  let style = kind-style(kind)
  draw.rect(a, b, fill: none, stroke: .7pt + style.stroke)
  draw.content(
    (a.at(0) + .12, b.at(1) - .36),
    (a.at(0) + 2.45, b.at(1) - .06),
    align(left + horizon)[
      #set text(size: 7pt, weight: "bold", fill: style.stroke)
      #title
    ],
    fill: white,
    padding: 0pt,
  )
}

#let arrow(from, to, label: none, stroke: colors.muted, dashed: false) = {
  draw.line(
    from,
    to,
    mark: (end: ">"),
    stroke: (paint: stroke, thickness: .55pt, dash: if dashed { "dashed" } else { "solid" }),
  )
  if label != none {
    small-label((0, 0), label)
  }
}

#let path-arrow(..pts, stroke: colors.muted, dashed: false) = {
  draw.line(
    ..pts,
    mark: (end: ">"),
    stroke: (paint: stroke, thickness: .55pt, dash: if dashed { "dashed" } else { "solid" }),
  )
}

#let lane(x, width, title, height: 5.4, y: 0, kind: "core") = {
  let style = kind-style(kind)
  draw.rect(
    (x, y - height),
    (x + width, y),
    fill: style.fill.lighten(55%),
    stroke: .35pt + colors.grid,
  )
  draw.content(
    (x + .08, y - .38),
    (x + width - .08, y - .06),
    align(center + horizon)[
      #set text(size: 7.1pt, weight: "bold", fill: style.stroke)
      #title
    ],
  )
}

#let state-node(pos, title, subtitle: none, name: none, terminal: false, kind: "core", scale: node-scale) = {
  box-node(
    pos,
    title,
    subtitle: subtitle,
    name: name,
    kind: if terminal { "ok" } else { kind },
    width: 2.05,
    height: .75,
    title-size: 7.6pt,
    body-size: 6.4pt,
    scale: scale,
  )
}

#let register-field(x, y, width, title, bits, fill, stroke, name: none) = {
  draw.content(
    (x, y - .42),
    (x + width, y + .42),
    align(center + horizon)[
      #set par(justify: false, leading: .42em, spacing: 0em)
      #set text(size: 8pt, weight: "bold")
      #title
      #linebreak()
      #set text(size: 6.7pt, weight: "regular", fill: colors.muted)
      #bits
    ],
    frame: "rect",
    fill: fill,
    stroke: .55pt + stroke,
    padding: 0pt,
    name: name,
  )
}

#let legend(items) = {
  grid(
    columns: items.len(),
    gutter: .8em,
    ..items.map(item => {
      let style = kind-style(item.at(0))
      box(inset: (x: .2em, y: .12em))[
        #box(width: .75em, height: .75em, fill: style.fill, stroke: .45pt + style.stroke)
        #h(.25em)
        #set text(size: 7.4pt)
        #item.at(1)
      ]
    })
  )
}

#let heat-cell(mark, fill) = box(
  width: 100%,
  inset: (x: .35em, y: .22em),
  fill: fill,
  stroke: .25pt + colors.grid,
)[
  #align(center)[
    #set text(size: 8pt, weight: "bold")
    #mark
  ]
]

#let bar(value, max, label, fill: colors.agent-fill, stroke: colors.agent-line, width: 2.2in) = {
  let pct = value / max
  stack(
    dir: ltr,
    spacing: 0pt,
    box(width: width * pct, height: .58em, fill: fill, stroke: .35pt + stroke),
    box(width: width * (1 - pct), height: .58em, fill: luma(245), stroke: .25pt + colors.grid),
    h(.35em),
    box[
      #set text(size: 8pt)
      #label
    ],
  )
}

#let layered-architecture-diagram() = canvas({
  band(6.0, 1.29, [User interaction], subtitle: [request and output], kind: "agent")
  band(4.25, 1.29, [Agent orchestration], subtitle: [mode and workflow], kind: "agent")
  band(2.5, 1.29, [Tool definitions], subtitle: [tool policies], kind: "tool")
  band(.75, 1.29, [Core tools], subtitle: [deterministic execution], kind: "core")
  band(-1.0, 1.29, [Libraries and local state], subtitle: [transport, JSON, storage], kind: "store")

  boundary((-.42, -1.9), (12.15, 5.2), [local process boundary], kind: "core")
  boundary((12.45, -1.9), (15.6, 1.65), [remote provider], kind: "external")

  box-node((3.15, 6.0), [Student], subtitle: [request], name: "student", kind: "agent", width: 2.85, scale: compact-node-scale)
  box-node((9.3, 6.0), [Study artefacts], subtitle: [notes, quiz, audio], name: "outputs", kind: "store", width: 2.75, scale: compact-node-scale)
  box-node((6.1, 4.25), [study-assistant], subtitle: [mode selection], name: "assistant", kind: "agent", width: 3.05, scale: compact-node-scale)
  box-node((2.6, 2.5), [ocr-tool], subtitle: [extraction], name: "ocrtool", kind: "tool", width: 2.15, scale: compact-node-scale)
  box-node((6.1, 2.5), [rag-tool], subtitle: [store/search], name: "ragtool", kind: "tool", width: 2.15, scale: compact-node-scale)
  box-node((9.6, 2.5), [tts-tool], subtitle: [speech prep], name: "ttstool", kind: "tool", width: 2.15, scale: compact-node-scale)
  box-node((2.6, .75), [pdfocr], subtitle: [OCR JSONL], name: "pdfocr", kind: "core", width: 2.15, scale: compact-node-scale)
  box-node((6.1, .75), [chunkvec], subtitle: [vector DB], name: "chunkvec", kind: "core", width: 2.15, scale: compact-node-scale)
  box-node((9.6, .75), [chunktts], subtitle: [.opus], name: "chunktts", kind: "core", width: 2.15, scale: compact-node-scale)
  box-node((1.75, -1.0), [relay], subtitle: [HTTP], name: "relay", kind: "store", width: 1.8, scale: compact-node-scale)
  box-node((4.65, -1.0), [openai], subtitle: [schemas], name: "openai", kind: "store", width: 1.8, scale: compact-node-scale)
  box-node((7.55, -1.0), [jsonx], subtitle: [JSON], name: "jsonx", kind: "store", width: 1.8, scale: compact-node-scale)
  box-node((10.75, -1.0), [SQLite + files], subtitle: [artefacts], name: "local", kind: "store", width: 2.2, scale: compact-node-scale)
  box-node((14.0, .75), [Model APIs], subtitle: [OCR, embed, speech], name: "api", kind: "external", width: 2.1, scale: compact-node-scale)

  path-arrow("student.south", "assistant.north")
  path-arrow("assistant.north", "outputs.south")
  path-arrow("assistant.south-west", "ocrtool.north")
  path-arrow("assistant.south", "ragtool.north")
  path-arrow("assistant.south-east", "ttstool.north")
  path-arrow("ocrtool.south", "pdfocr.north")
  path-arrow("ragtool.south", "chunkvec.north")
  path-arrow("ttstool.south", "chunktts.north")
  path-arrow("pdfocr.south", "relay.north")
  path-arrow("chunkvec.south-west", "relay.north-east")
  path-arrow("chunktts.south-west", "relay.north-east")
  path-arrow("relay.east", "openai.west")
  path-arrow("openai.east", "jsonx.west")
  path-arrow("openai.east", "api.west", stroke: colors.external-line)
  path-arrow("chunkvec.south-east", "local.north-west")
  path-arrow("chunktts.south", "local.north")
})

#let capability-routing-diagram() = canvas({
  box-node((1.0, 2.75), [PDF], subtitle: [visual source], name: "pdf", kind: "store", width: 1.8, scale: compact-node-scale)
  box-node((1.0, 1.45), [Text], subtitle: [prepared], name: "text", kind: "store", width: 1.8, scale: compact-node-scale)
  box-node((1.0, .15), [Corpus], subtitle: [stored], name: "stored", kind: "store", width: 1.8, scale: compact-node-scale)
  box-node((4.0, 2.75), [Extract], subtitle: [OCR], name: "extract", kind: "tool", width: 2.05, scale: compact-node-scale)
  box-node((4.0, 1.45), [Prepare], subtitle: [clean/chunk], name: "evidence", kind: "tool", width: 2.15, scale: compact-node-scale)
  box-node((4.0, .15), [Retrieve], subtitle: [search], name: "retrieve", kind: "tool", width: 2.05, scale: compact-node-scale)
  box-node((7.15, 1.45), [study-assistant], subtitle: [one mode], name: "assistant", kind: "agent", width: 2.65, scale: compact-node-scale)
  box-node((10.25, 2.75), [Study output], subtitle: [notes / quiz], name: "study", kind: "ok", width: 2.45, scale: compact-node-scale)
  box-node((10.25, 1.45), [Speech prep], subtitle: [\<bk\> text], name: "speech", kind: "tool", width: 2.55, scale: compact-node-scale)
  box-node((13.25, 1.45), [Audio], subtitle: [.opus], name: "audio", kind: "ok", width: 2.45, scale: compact-node-scale)
  box-node((10.25, .15), [Answer], subtitle: [grounded], name: "answer", kind: "ok", width: 2.45, scale: compact-node-scale)

  path-arrow("pdf.east", "extract.west")
  path-arrow("extract.south", "evidence.north")
  path-arrow("text.east", "evidence.west")
  path-arrow("stored.east", "retrieve.west")
  path-arrow("evidence.east", "assistant.west")
  path-arrow("retrieve.east", "assistant.south-west")
  path-arrow("assistant.east", "study.west")
  path-arrow("study.south", "speech.north", dashed: true)
  path-arrow("speech.east", "audio.west")
  path-arrow("assistant.south-east", "answer.west", dashed: true)
  small-label((2.45, 2.55), [if not extracted], width: 1.2)
  small-label((8.75, 2.05), [mode contract], width: 1.1, fill: colors.agent-fill)
  small-label((11.75, 1.8), [only if audio requested], width: 1.45)
})

#let core-execution-pattern-diagram() = canvas({
  box-node((.8, 2.2), [Input normalization], subtitle: [pages, chunks, query], name: "norm", kind: "core", width: 2.2)
  box-node((3.35, 3.8), [Ordered work list], subtitle: [seqId = 0..N-1], name: "work", kind: "store", width: 2.15)
  box-node((5.9, 2.2), [Bounded active window], subtitle: [inFlight <= K], name: "window", kind: "core", width: 2.25)
  box-node((8.45, 3.8), [Request id codec], subtitle: [seqId | attempt], name: "codec", kind: "evidence", width: 2.1)
  box-node((11.0, 2.2), [relay batch], subtitle: [remote calls], name: "relay", kind: "core", width: 2.1)
  box-node((13.55, 2.2), [Completion classifier], subtitle: [ok / retry / final error], name: "classify", kind: "core", width: 2.35)
  box-node((11.0, .75), [Retry heap], subtitle: [dueAt + jitter], name: "retry", kind: "retry", width: 2.0)
  box-node((5.4, .75), [Ordered terminal action], subtitle: [emit, insert, or publish], name: "terminal", kind: "ok", width: 2.55)

  path-arrow("norm.north", "work.south")
  path-arrow("work.south", "window.north")
  path-arrow("window.north", "codec.south")
  path-arrow("codec.south", "relay.north")
  path-arrow("relay.east", "classify.west")
  path-arrow("classify.south-west", "retry.north-east", stroke: colors.retry-line)
  path-arrow("retry.north-west", "window.south-east", stroke: colors.retry-line)
  path-arrow("classify.south-west", (12.2, .25), (5.4, .25), "terminal.south")
  small-label((5.4, -.08), [OCR: JSONL  |  RAG: transaction  |  TTS: final .opus], width: 5.4, size: 6.8pt)
})

#let ocr-state-machine-diagram() = canvas({
  state-node((.7, 1.65), [Pending], subtitle: [page], name: "pending", scale: compact-node-scale)
  state-node((3.0, 1.65), [Rendered], subtitle: [bitmap], name: "render", scale: compact-node-scale)
  state-node((5.3, 1.65), [Payload], subtitle: [O(K)], name: "payload", kind: "store", scale: compact-node-scale)
  state-node((7.6, 1.65), [In flight], subtitle: [request], name: "flight", scale: compact-node-scale)
  state-node((7.6, 3.0), [Retry wait], subtitle: [jitter], name: "retry", kind: "retry", scale: compact-node-scale)
  state-node((10.0, 1.65), [Terminal], subtitle: [ok/error], name: "terminal", terminal: true, scale: compact-node-scale)
  state-node((12.35, 1.65), [Staged], subtitle: [seqId], name: "staged", kind: "store", scale: compact-node-scale)
  state-node((14.7, 1.65), [Emitted], subtitle: [ordered], name: "emitted", terminal: true, scale: compact-node-scale)
  state-node((5.3, .25), [Local error], subtitle: [render/encode], name: "localerr", kind: "retry", scale: compact-node-scale)

  path-arrow("pending.east", "render.west")
  path-arrow("render.east", "payload.west")
  path-arrow("payload.east", "flight.west")
  path-arrow("flight.east", "terminal.west")
  path-arrow("terminal.east", "staged.west")
  path-arrow("staged.east", "emitted.west")
  path-arrow("flight.north", "retry.south", stroke: colors.retry-line)
  path-arrow("retry.south-east", "flight.north-east", stroke: colors.retry-line)
  path-arrow("render.south", "localerr.north-west", stroke: colors.retry-line)
  path-arrow("payload.south", "localerr.north", stroke: colors.retry-line)
  path-arrow("localerr.north-east", "terminal.south-west", stroke: colors.retry-line)
  small-label((8.7, 2.36), [retryable failure], width: 1.3, fill: colors.retry-fill)
  small-label((13.55, 2.08), [ordered guard], width: 1.25, fill: colors.ok-fill)
})

#let request-id-register-diagram() = canvas({
  register-field(.4, 1.15, 8.2, [seqId], [logical page or chunk, 47 bits], colors.store-fill, colors.store-line, name: "seq")
  register-field(8.6, 1.15, 3.0, [attempt], [low 16 bits], colors.warn-fill, colors.warn-line, name: "attempt")
  draw.content((.4, -.15), (11.6, .55), align(center + horizon)[
    #set par(justify: false, leading: .45em)
    #set text(size: 8.2pt)
    requestId = (seqId << 16) | attempt
    #linebreak()
    #set text(size: 7pt, fill: colors.muted)
    Async completions decode without lookup ambiguity.
  ], frame: "rect", fill: colors.core-fill, stroke: .45pt + colors.core-line)
  path-arrow("seq.south", (4.5, .55))
  path-arrow("attempt.south", (10.1, .55))
  small-label((.55, 1.78), [most significant bits], width: 1.55)
  small-label((11.35, 1.78), [least significant bits], width: 1.55)
})

#let rag-access-path-diagram() = canvas({
  boundary((-.2, -.55), (10.6, 4.05), [local retrieval boundary], kind: "store")
  boundary((11.0, 1.05), (15.0, 3.4), [remote embedding boundary], kind: "external")
  box-node((1.05, 3.2), [Chunks], subtitle: [marked], name: "chunks", kind: "store", width: 2.1, scale: compact-node-scale)
  box-node((4.0, 3.2), [Parser], subtitle: [strict], name: "parser", kind: "core", width: 2.0, scale: compact-node-scale)
  box-node((7.0, 3.2), [Missing check], subtitle: [idempotent], name: "missing", kind: "core", width: 2.25, scale: compact-node-scale)
  box-node((13.0, 2.65), [Embedding API], subtitle: [vectors], name: "api", kind: "external", width: 2.35, scale: compact-node-scale)
  box-node((5.2, 1.6), [chunks table], subtitle: [text/meta/vector], name: "table", kind: "store", width: 3.05, height: 1.05, scale: compact-node-scale)
  box-node((2.1, .05), [B-tree], subtitle: [filters], name: "btree", kind: "core", width: 2.55, scale: compact-node-scale)
  box-node((5.2, .05), [Vector scan], subtitle: [distance], name: "vector", kind: "core", width: 2.55, scale: compact-node-scale)
  box-node((8.3, 1.6), [Results], subtitle: [ranked chunks], name: "results", kind: "ok", width: 2.55, scale: compact-node-scale)
  box-node((1.05, 1.6), [Query], subtitle: [semantic], name: "query", kind: "agent", width: 2.1, scale: compact-node-scale)

  path-arrow("chunks.east", "parser.west")
  path-arrow("parser.east", "missing.west")
  path-arrow("missing.east", "api.west", stroke: colors.external-line)
  path-arrow("api.south-west", "table.north-east", stroke: colors.external-line)
  path-arrow("query.north-east", "api.west", stroke: colors.external-line, dashed: true)
  path-arrow("query.south", "btree.north")
  path-arrow("table.south-west", "btree.north-east")
  path-arrow("table.south", "vector.north")
  path-arrow("btree.north-east", "results.south-west")
  path-arrow("vector.north", "results.south")
})

#let cvstore-ingest-sequence-diagram() = canvas({
  lane(.1, 2.45, [cvstore], kind: "core")
  lane(2.55, 2.45, [chunk parser], kind: "core")
  lane(5.0, 2.65, [SQLite], kind: "store")
  lane(7.65, 2.65, [embedding pipeline], kind: "core")
  lane(10.3, 2.65, [Embedding API], kind: "external")
  lane(12.95, 2.25, [commit state], kind: "store")

  for x in (1.32, 3.78, 6.32, 8.98, 11.62, 14.08) {
    draw.line((x, -.48), (x, -5.15), stroke: .35pt + colors.line)
  }

  path-arrow((1.32, -1.0), (3.78, -1.0))
  small-label((2.55, -.82), [parse markers], width: 1.15)
  path-arrow((3.78, -1.45), (6.32, -1.45))
  small-label((5.05, -1.27), [open transaction], width: 1.35)
  path-arrow((6.32, -1.9), (8.98, -1.9))
  small-label((7.65, -1.72), [select missing chunks], width: 1.55)
  path-arrow((8.98, -2.35), (11.62, -2.35), stroke: colors.external-line)
  small-label((10.3, -2.17), [embed loop], width: 1.05, fill: colors.external-fill)
  path-arrow((11.62, -2.8), (8.98, -2.8), stroke: colors.external-line)
  small-label((10.3, -3.02), [vectors], width: .8, fill: colors.external-fill)
  path-arrow((8.98, -3.35), (6.32, -3.35))
  small-label((7.65, -3.17), [insert rows], width: 1.05)
  path-arrow((6.32, -3.9), (14.08, -3.9))
  small-label((10.2, -3.72), [quantize + commit], width: 1.4, fill: colors.store-fill)
  path-arrow((6.32, -4.5), (1.32, -4.5), stroke: colors.retry-line, dashed: true)
  small-label((3.8, -4.32), [rollback on fatal failure], width: 1.65, fill: colors.retry-fill)
})

#let tts-publication-gate-diagram() = canvas({
  box-node((.8, 1.8), [\<bk\> text], subtitle: [chunks], name: "input", kind: "store", width: 2.25, scale: compact-node-scale)
  box-node((3.25, 1.8), [Requests], subtitle: [seqId], name: "requests", kind: "core", width: 2.1, scale: compact-node-scale)
  box-node((5.7, 1.8), [WAV], subtitle: [responses], name: "wav", kind: "external", width: 2.1, scale: compact-node-scale)
  box-node((8.15, 1.8), [Decoded], subtitle: [samples], name: "decoded", kind: "store", width: 2.1, scale: compact-node-scale)
  box-node((10.75, 1.8), [Gate], subtitle: [all valid], name: "gate", kind: "warn", width: 2.35, scale: compact-node-scale)
  box-node((13.55, 2.55), [Publish], subtitle: [.opus], name: "publish", kind: "ok", width: 2.2, scale: compact-node-scale)
  box-node((13.55, .75), [No file], subtitle: [failure], name: "nofile", kind: "retry", width: 2.2, scale: compact-node-scale)
  path-arrow("input.east", "requests.west")
  path-arrow("requests.east", "wav.west")
  path-arrow("wav.east", "decoded.west")
  path-arrow("decoded.east", "gate.west")
  path-arrow("gate.north-east", "publish.west")
  path-arrow("gate.south-east", "nofile.west", stroke: colors.retry-line)
  small-label((12.15, 2.34), [pass], width: .65, fill: colors.ok-fill)
  small-label((12.15, 1.02), [fail], width: .65, fill: colors.retry-fill)
})

#let relay-concurrency-diagram() = canvas({
  lane(.05, 2.4, [Tool scheduler], kind: "core")
  lane(2.45, 2.35, [RequestBatch], kind: "store")
  lane(4.8, 2.55, [Relay worker], kind: "core")
  lane(7.35, 2.45, [libcurl multi], kind: "core")
  lane(9.8, 2.45, [Remote API], kind: "external")
  lane(12.25, 2.4, [Ready results], kind: "store")

  for x in (1.25, 3.62, 6.08, 8.58, 11.02, 13.45) {
    draw.line((x, -.48), (x, -5.05), stroke: .35pt + colors.line)
  }
  path-arrow((1.25, -1.0), (3.62, -1.0))
  small-label((2.45, -.82), [append request ids], width: 1.4)
  path-arrow((3.62, -1.45), (6.08, -1.45))
  small-label((4.82, -1.27), [submit batch], width: 1.15)
  path-arrow((6.08, -1.9), (8.58, -1.9))
  small-label((7.35, -1.72), [dispatch easy handles], width: 1.5)
  path-arrow((8.58, -2.35), (11.02, -2.35), stroke: colors.external-line)
  small-label((9.8, -2.17), [HTTP transfer], width: 1.1, fill: colors.external-fill)
  path-arrow((11.02, -2.8), (8.58, -2.8), stroke: colors.external-line)
  path-arrow((8.58, -3.25), (6.08, -3.25))
  small-label((7.35, -3.07), [done messages], width: 1.1)
  path-arrow((6.08, -3.7), (13.45, -3.7))
  small-label((9.75, -3.52), [push completed result], width: 1.55, fill: colors.store-fill)
  path-arrow((13.45, -4.25), (1.25, -4.25))
  small-label((7.35, -4.07), [tool drains and classifies; ordering stays tool-owned], width: 3.4)
})

#let artifact-lineage-diagram() = canvas({
  box-node((.6, 2.2), [PDF], subtitle: [source], name: "pdf", kind: "store", width: 1.55, scale: compact-node-scale)
  box-node((2.55, 2.2), [pdfocr], name: "pdfocr", kind: "core", width: 1.55, scale: compact-node-scale)
  box-node((4.5, 2.2), [JSONL], subtitle: [pages], name: "jsonl", kind: "store", width: 1.85, scale: compact-node-scale)
  box-node((6.75, 2.2), [Clean text], subtitle: [source], name: "clean", kind: "store", width: 1.9, scale: compact-node-scale)
  box-node((9.0, 2.2), [Chunks], subtitle: [marked], name: "chunkfile", kind: "store", width: 1.9, scale: compact-node-scale)
  box-node((11.25, 2.2), [cvstore], name: "cvstore", kind: "core", width: 1.65, scale: compact-node-scale)
  box-node((13.25, 2.2), [SQLite], subtitle: [vectors], name: "sqlite", kind: "store", width: 1.9, scale: compact-node-scale)

  box-node((13.25, .65), [cvquery], name: "cvquery", kind: "core", width: 1.65, scale: compact-node-scale)
  box-node((11.1, .65), [Retrieved], subtitle: [evidence], name: "retrieved", kind: "store", width: 2.0, scale: compact-node-scale)
  box-node((8.7, .65), [study-assistant], subtitle: [mode], name: "assistant", kind: "agent", width: 2.1, scale: compact-node-scale)
  box-node((6.35, .65), [Study output], subtitle: [notes / quiz], name: "study", kind: "store", width: 2.05, scale: compact-node-scale)
  box-node((4.05, .65), [tts-tool], subtitle: [rewrite], name: "ttstool", kind: "tool", width: 1.75, scale: compact-node-scale)
  box-node((2.05, .65), [\<bk\>], subtitle: [speech text], name: "bk", kind: "store", width: 1.75, scale: compact-node-scale)
  box-node((.35, .65), [chunktts], name: "chunktts", kind: "core", width: 1.55, scale: compact-node-scale)
  box-node((.35, -.85), [.opus], subtitle: [complete], name: "opus", kind: "ok", width: 2.05, scale: compact-node-scale)

  path-arrow("pdf.east", "pdfocr.west")
  path-arrow("pdfocr.east", "jsonl.west")
  path-arrow("jsonl.east", "clean.west")
  path-arrow("clean.east", "chunkfile.west")
  path-arrow("chunkfile.east", "cvstore.west")
  path-arrow("cvstore.east", "sqlite.west")
  path-arrow("sqlite.south", "cvquery.north")
  path-arrow("cvquery.west", "retrieved.east")
  path-arrow("retrieved.west", "assistant.east")
  path-arrow("assistant.west", "study.east")
  path-arrow("study.west", "ttstool.east")
  path-arrow("ttstool.west", "bk.east")
  path-arrow("bk.west", "chunktts.east")
  path-arrow("chunktts.south", "opus.north")

  small-label((4.5, 2.83), [inspect], width: .75, fill: colors.store-fill)
  small-label((9.0, 2.83), [validate markers], width: 1.25, fill: colors.store-fill)
  small-label((11.1, 1.25), [evidence], width: .9, fill: colors.store-fill)
  small-label((.35, -.15), [publication gate], width: 1.25, fill: colors.ok-fill)
})

#let verification-evidence-diagram() = canvas({
  box-node((.85, 2.75), [Instructions], subtitle: [policies], name: "instr", kind: "agent", width: 2.35, scale: compact-node-scale)
  box-node((.85, .9), [Core tools], subtitle: [pipelines], name: "tools", kind: "core", width: 2.35, scale: compact-node-scale)
  box-node((.85, -.95), [Libraries], subtitle: [shared], name: "libs", kind: "store", width: 2.35, scale: compact-node-scale)

  box-node((4.0, 3.0), [Inspection], subtitle: [contracts], name: "inspection", kind: "evidence", width: 2.45, scale: compact-node-scale)
  box-node((4.0, 1.82), [Contract checks], subtitle: [CLI/schema], name: "contracts", kind: "evidence", width: 2.45, scale: compact-node-scale)
  box-node((4.0, .64), [Unit tests], subtitle: [local logic], name: "unit", kind: "evidence", width: 2.45, scale: compact-node-scale)
  box-node((4.0, -.54), [Integration], subtitle: [DB/audio/HTTP], name: "integration", kind: "evidence", width: 2.45, scale: compact-node-scale)
  box-node((4.0, -1.35), [Benchmarks], subtitle: [recorded], name: "bench", kind: "evidence", width: 2.45, scale: compact-node-scale)

  box-node((7.45, 1.75), [Deterministic], subtitle: [ordering/retry], name: "det", kind: "ok", width: 2.65, scale: compact-node-scale)
  box-node((7.45, .2), [Empirical], subtitle: [cost/quality], name: "emp", kind: "warn", width: 2.65, scale: compact-node-scale)
  box-node((10.85, .98), [Evaluation claim], subtitle: [separated evidence], name: "claim", kind: "ok", width: 3.0, scale: compact-node-scale)

  path-arrow("instr.east", "inspection.west")
  path-arrow("instr.east", "contracts.west")
  path-arrow("tools.east", "contracts.west")
  path-arrow("tools.east", "unit.west")
  path-arrow("tools.east", "integration.west")
  path-arrow("tools.east", "bench.west", dashed: true)
  path-arrow("libs.east", "unit.west")
  path-arrow("libs.east", "integration.west")
  path-arrow("inspection.east", "det.west")
  path-arrow("contracts.east", "det.west")
  path-arrow("unit.east", "det.west")
  path-arrow("integration.east", "det.west")
  path-arrow("bench.east", "emp.west")
  path-arrow("det.east", "claim.west")
  path-arrow("emp.east", "claim.west")
})

#let throughput-speedup-diagram() = canvas({
  draw.line((2.0, .55), (13.8, .55), mark: (end: ">"), stroke: .55pt + colors.line)
  draw.line((2.0, 2.7), (13.8, 2.7), mark: (end: ">"), stroke: .55pt + colors.line)
  small-label((13.0, .2), [runtime seconds], width: 1.25)
  small-label((13.05, 2.35), [pages per second], width: 1.25)
  draw.content((.1, .32), (1.7, .78), align(right + horizon)[
    K=1
  ], fill: none)
  draw.content((.1, 1.12), (1.7, 1.58), align(right + horizon)[
    K=32
  ], fill: none)
  draw.content((.1, 2.47), (1.7, 2.93), align(right + horizon)[
    K=1
  ], fill: none)
  draw.content((.1, 3.27), (1.7, 3.73), align(right + horizon)[
    K=32
  ], fill: none)

  draw.rect((2.0, .35), (13.4, .75), fill: colors.retry-fill, stroke: .55pt + colors.retry-line)
  draw.rect((2.0, 1.15), (2.72, 1.55), fill: colors.ok-fill, stroke: .55pt + colors.ok-line)
  draw.rect((2.0, 2.5), (2.73, 2.9), fill: colors.warn-fill, stroke: .55pt + colors.warn-line)
  draw.rect((2.0, 3.3), (13.4, 3.7), fill: colors.ok-fill, stroke: .55pt + colors.ok-line)
  small-label((12.3, .95), [316.66 s], width: .9, fill: colors.retry-fill)
  small-label((3.55, 1.75), [19.93 s], width: .9, fill: colors.ok-fill)
  small-label((3.35, 2.25), [0.23 pages/s], width: 1.15, fill: colors.warn-fill)
  small-label((12.2, 3.95), [3.61 pages/s], width: 1.15, fill: colors.ok-fill)
  draw.content((5.2, 1.0), (10.0, 2.35), align(center + horizon)[
    #set text(size: 13pt, weight: "bold", fill: colors.ok-line)
    15.89x speedup
    #linebreak()
    #set text(size: 7.2pt, weight: "regular", fill: colors.muted)
    same 72-page PDF
  ], frame: "rect", fill: white, stroke: .45pt + colors.grid)
})

#let ocr-model-tradeoff-diagram() = canvas({
  draw.line((1.0, .6), (13.8, .6), mark: (end: ">"), stroke: .55pt + colors.line)
  draw.line((1.0, .6), (1.0, 4.6), mark: (end: ">"), stroke: .55pt + colors.line)
  small-label((12.85, .25), [cost/page USD], width: 1.45)
  small-label((.55, 4.25), [quality], width: .75)

  for y in (1.35, 2.1, 2.85, 3.6) {
    draw.line((1.0, y), (13.8, y), stroke: .25pt + colors.grid)
  }

  // Points are precomputed from appendix cost/page and aggregate OCR quality values.
  draw.circle((2.18, 1.28), radius: .16, fill: colors.warn-fill, stroke: .8pt + colors.warn-line, name: "deepseek")
  draw.content((2.55, 1.0), (5.1, 1.6), align(left + horizon)[
    #set text(size: 7.2pt)
    DeepSeek-OCR\
    lowest cost
  ], fill: white)
  draw.circle((7.19, 3.84), radius: .18, fill: colors.agent-fill, stroke: .8pt + colors.agent-line, name: "olm")
  draw.content((7.42, 3.06), (10.12, 3.64), align(left + horizon)[
    #set text(size: 7.2pt)
    olmOCR 2\
    recall choice
  ], fill: white)
  draw.circle((13.17, 4.31), radius: .18, fill: colors.store-fill, stroke: .8pt + colors.store-line, name: "paddle")
  draw.content((9.95, 4.28), (12.95, 4.84), align(left + horizon)[
    #set text(size: 7.2pt)
    PaddleOCR-VL\
    accuracy winner
  ], fill: white)
  path-arrow("olm", "paddle", dashed: true)
  small-label((10.45, 3.62), [higher cost, small quality gain], width: 2.0)
})

#let failure-semantics-diagram() = canvas({
  box-node((.95, 1.65), [Tool run], subtitle: [pipeline], name: "run", kind: "core", width: 1.8, scale: compact-node-scale)
  box-node((3.25, 2.85), [Recoverable], subtitle: [unit], name: "unit", kind: "warn", width: 2.1, scale: compact-node-scale)
  box-node((3.25, 1.65), [Permanent], subtitle: [unit fail], name: "perm", kind: "retry", width: 2.25, scale: compact-node-scale)
  box-node((3.25, .45), [Fatal], subtitle: [run fail], name: "fatal", kind: "retry", width: 2.1, scale: compact-node-scale)

  box-node((6.4, 3.05), [pdfocr], subtitle: [error JSONL], name: "pdfocrfail", kind: "store", width: 2.25, scale: compact-node-scale)
  box-node((6.4, 2.0), [cvstore], subtitle: [commit rows], name: "cvfail", kind: "store", width: 2.25, scale: compact-node-scale)
  box-node((6.4, .95), [chunktts], subtitle: [no audio], name: "ttsfail", kind: "retry", width: 2.25, scale: compact-node-scale)
  box-node((6.4, -.1), [cvquery], subtitle: [no partial], name: "queryfail", kind: "retry", width: 2.25, scale: compact-node-scale)

  box-node((9.75, 3.05), [Audit trail], subtitle: [partial ok], name: "partial", kind: "ok", width: 2.35, scale: compact-node-scale)
  box-node((9.75, 2.0), [Database], subtitle: [inspectable], name: "db", kind: "ok", width: 2.35, scale: compact-node-scale)
  box-node((9.75, .95), [No artefact], subtitle: [avoid partial], name: "noaudio", kind: "ok", width: 2.35, scale: compact-node-scale)
  box-node((9.75, -.1), [No answer], subtitle: [exit only], name: "noanswer", kind: "warn", width: 2.35, scale: compact-node-scale)

  box-node((12.9, 1.65), [Exit code], subtitle: [2 or 3], name: "exit", kind: "evidence", width: 2.55, scale: compact-node-scale)

  path-arrow("run.north-east", "unit.west")
  path-arrow("run.east", "perm.west")
  path-arrow("run.south-east", "fatal.west", stroke: colors.retry-line)
  path-arrow("perm.east", "pdfocrfail.west")
  path-arrow("perm.east", "cvfail.west")
  path-arrow("perm.east", "ttsfail.west", stroke: colors.retry-line)
  path-arrow("perm.east", "queryfail.west", stroke: colors.retry-line)
  path-arrow("pdfocrfail.east", "partial.west")
  path-arrow("cvfail.east", "db.west")
  path-arrow("ttsfail.east", "noaudio.west")
  path-arrow("queryfail.east", "noanswer.west")
  path-arrow("partial.east", "exit.north-west")
  path-arrow("db.east", "exit.west")
  path-arrow("noaudio.east", "exit.west")
  path-arrow("noanswer.east", "exit.south-west")
  path-arrow("fatal.east", "exit.south-west", stroke: colors.retry-line)
  small-label((3.0, 3.5), [retry loop before permanent failure], width: 2.2, fill: colors.warn-fill)
})

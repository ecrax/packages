#import "@preview/quick-maths:0.1.0": shorthands

// Workaround for the lack of an `std` scope.
#let std-bibliography = bibliography

#let contents = (depth: 1) => {
  // show outline.entry: it => {
  //   v(-10pt, weak: true)

  //   grid(
  //     columns: (20pt, 1fr),
  //     column-gutter: 10pt,
  //     link(it.element.location())[#align(right)[*#it.page*]],
  //     link(it.element.location())[#text(fill: black.lighten(33%))[#it.body]],
  //   )
  // }

  outline(depth: depth, title: none)
}

#let quote = (body) => {
  align(center)[
    #line(length: 80%, stroke: primary)
    #text(style: "italic")[#body]
    #line(length: 80%, stroke: primary)
  ]
}

#let br = linebreak(justify: true)

#let col(body, height: none) = {
  let content = columns(2, gutter: 0.4in, body)

  if height != none [
    #box(height: height)[#content]
  ] else [
    #content
  ]
}

#let blurb(body) = {
  text(size: 13pt)[#body]
  v(0.3in)
}

#let content-page = (lang: "de", subtext: none, depth: 1) => {
  if lang == "de" {
    heading(level: 1)[Inhaltsverzeichnis]
  } else if lang == "en" {
    heading(level: 1)[Table of Contents]
  }

  col[
    #box(height: 80%)[
      #align(horizon)[#contents(depth: depth)]
    ]
    #colbreak()

    #if subtext != none {
      box(height: 100%)[
        #align(bottom)[
          #emph(subtext)
        ]
      ]
    }
  ]
  v(0.4in)
  pagebreak()
}

#let island(
  // The paper's language.
  lang: "de",
  // The paper's title.
  title: "",
  // The paper's subheading.
  subheading: none,
  // The primary color to use in the paper.
  primary: rgb("#303154"),
  // An array of authors. For each author you can specify a name,
  // and a matriculation number.
  authors: (),
  // The semester the paper was written in.
  semester: "WS2023/24",
  // Whether to display the title page.
  show-title-page: true,
  // The image to display on the title page.
  img: none,
  // Whether to display the outline.
  show-outline: true,
  // The depth of the outline to display.
  outline-depth: 1,
  // The subtext to display below/next to the outline.
  outline-subtext: none,
  // The result of a call to the `bibliography` function or `none`.
  bibliography: none,
  // The paper's contents.
  body,
) = {
  show heading: h => {
    set text(font: "Satoshi", fill: black, weight: 700)
    set block(spacing: 1em)
    h
  }
  show heading.where(level: 1): h => {
    stack(
      dir: ltr,
      place(left, dx: -0.5in, rect(height: 13pt, width: 0.4in, fill: primary)),
      text(size: 18pt, h),
    )
    v(0.4in)
  }
  show par: set par(spacing: 1.4em)
  show cite: set text(fill: primary)
  show link: set text(fill: primary)
  show figure: set text(size: 9pt)

  show: shorthands.with(
    ($+-$, $plus.minus$),
    ($|-$, math.tack),
    ($=>$, math.arrow.r.double),
    ($<==>$, math.arrow.l.r.double),
  )

  set document(title: title, author: authors.map(a => a.name))
  set text(font: "Erode", fill: black.lighten(33%), lang: lang)
  set par(justify: true)

  if not img == none {
    place(
      horizon,
      dx: -0.5in,
      dy: -1.1in,
      image(img, height: 89%, width: 100% + 2.4in),
    )
  }

  let footer = () => {

    context {
      if counter(page).get().first() == 1 and show-title-page { return }

      let loc = here()

      let elems = query(selector(heading.where(level: 1)).before(loc))
      let section = if elems == () {} else { elems.last().body }
      grid(columns: (1fr, 20pt, 1fr), align(left)[
        #text(size: 10pt, fill: black.lighten(70%))[#title]
      ], align(center)[
        *#counter(page).display()*
      ], pad(left: 15%, align(right)[
        #text(size: 10pt, fill: black.lighten(70%))[#section]
      ]))
    }
  }

  if show-title-page {
    align(bottom)[
      #text(font: "Satoshi", 1.1em, semester)
      \-
      #text(
        font: "Satoshi",
        1.1em,
        datetime.today().display("[month repr:long] [day], [year]"),
      )
      #v(1.2em, weak: true)
      #text(font: "Satoshi", weight: 700, title, size: 24pt)

      #if subheading != none {
        v(-0.9em)
        text(font: "Satoshi", size: 16pt, subheading)
      }

      // Author information.
      #pad(
        // top: 0.7em,
        right: 20%,
        grid(
          columns: (1fr,) * calc.min(3, authors.len()),
          gutter: 1em,
          ..authors.map(author => align(start)[#text(font: "Satoshi", [
              *#author.name* \
              #author.matnr
            ])
          ]),
        ),
      )
      #v(-8mm)
    ]
    pagebreak()
  }
  set page(
    margin: (bottom: 1in, rest: 0.5in),
    footer-descent: 0.5in,
    footer: footer(),
    header-ascent: -0.18in,
    header: if not show-title-page {
      locate(
        loc => if [#loc.page()] == [1] {
          v(10cm)
          grid(
            columns: (1fr, 3fr, 1fr),
            align(left, none),
            align(center, none),
            align(right, authors.map(author => align(start)[#text(font: "Satoshi", [
                *#author.name* -
                #author.matnr
              ])
            ]).join(", ")),
          )
        },
      )
    } else {
      none
    },
  )

  if show-outline {
    content-page(lang: lang, subtext: outline-subtext, depth: outline-depth)
  }

  // Display the paper's contents.
  body

  // Display bibliography.
  if bibliography != none {
    show std-bibliography: set text(11pt)
    set std-bibliography(title: none, style: "ieee")
    
    pagebreak()
    if lang == "de" {
      heading(level: 1)[Literaturverzeichnis]
    } else if lang == "en" {
      heading(level: 1)[References]
    }
    col[
      #par(justify: false, leading: 0.5em)[
        #bibliography
      ]
    ]
  }
}
#' Server-side tex math rendering
#'
#' Converts tex-style math expressions to html and mathml for use in manual pages or
#' markdown documents.
#' The conversion is to HTML done in R using V8, hence the resulting snipped can
#' be inserted into an HTML document without the need for a JavaScript library. Only the
#' [katex.css](https://cdn.jsdelivr.net/npm/katex@0.13.11/dist/katex.min.css)
#' style is required to display the html in the output document.
#' Use [math_to_rd] for embedding math into R documentation (rd) pages.
#'
#' By default, [katex_html] returns a mix of HTML for visual rendering and includes
#' MathML for accessibility. To only get html, pass `output="html"` in the extra options,
#' see also the [katex documentation](https://katex.org/docs/options.html).
#' @export
#' @name katex
#' @rdname katex
#' @family katex
#' @param tex input string with tex math expression.
#' @param preview open an HTML preview page showing the snipped in the browser
#' @param displayMode render math in a large, 2D, centered style similar to `$$` in tex.
#' Set to `FALSE` to render inline, which disables centering and tries to squeeze the
#' equation on a single line. For pdf output, this corresponds to `\deqn{}` and `\eqn{}`
#' respectively, see [WRE 2.6: Mathematics](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Mathematics)
#' @param ... additional rendering options passed to
#' [katex.render](https://katex.org/docs/options.html)
#' @examples # Basic examples
#' html <- katex_html(example_math())
#' mathml <- katex_mathml(example_math())
#'
#' # Example from katex.org homepage:
#' macros <- list("\\f" = "#1f(#2)")
#' math <- "\\f\\relax{x} = \\int_{-\\infty}^\\infty \\f\\hat\\xi\\,e^{2 \\pi i \\xi x} \\,d\\xi"
#' html <- katex_html(math,  macros = macros)
#' mathml <- katex_mathml(math,  macros = macros)
katex_html <- function(tex, include_css = FALSE, displayMode = TRUE, ..., preview = interactive()) {
  html <- katex_render(tex, displayMode = displayMode, ...)
  if(isTRUE(preview)){
    tmp <- tempfile(fileext = '.html')
    writeLines(htmlify(html), tmp, useBytes = TRUE)
    viewer <- getOption('viewer', utils::browseURL)
    viewer(tmp)
  }
  if(isTRUE(include_css))
    html <- paste('<link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/katex@0.13.11/dist/katex.min.css">', html, sep = '\n')
  html
}

#' @export
#' @rdname katex
katex_mathml <- function(tex, displayMode = TRUE, ...) {
  katex_render(tex = tex, displayMode = displayMode, output = 'mathml', ...)
}

#' @export
#' @rdname katex
example_math <- function(){
  return("f(x)= {\\frac{1}{\\sigma\\sqrt{2\\pi}}}e^{- {\\frac {1}{2}} (\\frac {x-\\mu}{\\sigma})^2}")
}

#' @importFrom V8 v8
.onLoad <- function(lib, pkg){
  assign("ctx", V8::v8("window"), environment(.onLoad))
  ctx$source(system.file("js/katex.min.js", package = pkg))
}

katex_render <- function(tex, displayMode, ...) {
  options <- list(...)
  options$displayMode <- displayMode
  html <- ctx$call('katex.renderToString', tex, options)
  Encoding(html) = 'UTF-8'
  html
}

htmlify <- function(snippet){
  sub('{{math}}', snippet, template, fixed = TRUE)
}

template <- '<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.13.11/dist/katex.min.css">
  </head>
  <body>
  {{math}}
  </body>
</html>'

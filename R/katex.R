#' Render LaTex Math to HTML or MathML
#'
#' Converts LaTeX Math to HTML to embed in manual pages or markdown documents.
#'
#' The conversion is done in R, hence the resulting HTML can be inserted into an
#' HTML document without the need for a JavaScript library. Only the
#' [katex css](https://cdn.jsdelivr.net/npm/katex@0.13.11/dist/katex.min.css) is
#' required to display the the html in the output document.
#'
#' Below is an example of `render_math_rd()` used in this manual page:
#'
#' \Sexpr[results=rd, stage=build]{
#'   katex::render_rd(katex::example_math())
#' }
#'
#' By default, [render_html] returns a mix of HTML for visual rendering and includes
#' MathML for accessibility. To only get one or the other, set the `output`
#' parameter in the `options` list. For this and other options, see the
#' [katex documentation](https://katex.org/docs/options.html).
#'
#' @export
#' @name katex
#' @rdname katex
#' @param tex string with latex math expression
#' @param preview open an HTML preview page showing the snipped in the browser
#' @param options a list with additional rendering options `katex.render()`, see:
#' [katex.render](https://katex.org/docs/options.html)
#' @examples html <- render_html(example_math(), preview = interactive())
#' mathml <- render_mathml(example_math())
render_html <- function(tex, preview = FALSE, include_css = FALSE, options = NULL) {
  html <- katex_render(tex, options)
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
render_mathml <- function(tex, options = NULL) {
  options <- as.list(options)
  options$output <- 'mathml'
  katex_render(tex = tex, options = options)
}

#' @export
#' @rdname katex
#' @param include_css adds the katex css file to the output.
#' This is only required once per html webpage.
render_rd <- function(tex, include_css = TRUE, options = NULL){
  options <- as.list(options)
  if(!length(options$displayMode))
    options$displayMode <- TRUE
  html <- render_html(tex, include_css = include_css, options = options)
  paste('\\if{html}{\\out{', html, '}}', sep = '\n')
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

# todo: add html class to make this a 'widget' ?
katex_render <- function(tex, options = NULL) {
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

#' Display math in R documentation
#'
#' Helper function to insert tex math expressions into R documentation (rd) files.
#' Uses Katex rendering for documentation rendered into HTML format, and the appropriate
#' tex macros for documentation rendered to pdf
#'
#' Use `math_to_rd()` inside `\Sexpr` to embed math in your R package documentation
#' pages. For example the code below can be inserted in your `rd` (or roxygen) text:
#'
#' ```
#' \Sexpr[results=rd, stage=build]{
#'   katex::math_to_rd(katex::example_math())
#' }
#' ```
#'
#' Which results in the following output:
#'
#' \Sexpr[results=rd, stage=build]{
#'   katex::math_to_rd(katex::example_math())
#' }
#'
#' Optionally you can specify an alternate ascii representation that will be shown in
#' the plain-text format rendering of the documentation:
#'
#' ```
#' \Sexpr[results=rd, stage=build]{
#'   katex::math_to_rd('E=MC^2', 'E=mc²')
#' }
#' ```
#'
#' \Sexpr[results=rd, stage=build]{
#'   katex::math_to_rd('E=MC^2', 'E=MC²')
#' }
#'
#' If no ascii representation is given, the input tex in displayed verbatim into the
#' plain-text documentation.
#'
#' @export
#' @name math_to_rd
#' @rdname mathtord
#' @family katex
#' @inheritParams katex
#' @param ascii alternate text representation of the input math to show when documentation is
#' rendered to plain text format.
#' @param include_css adds the katex css file to the output.
#' This is only required once per html webpage.
math_to_rd <- function(tex, ascii = tex, include_css = TRUE, displayMode = TRUE, ...){
  html <- katex_html(tex, include_css = include_css, displayMode = displayMode, ...,
                     preview = FALSE)
  html_out <- paste('\\if{html}{\\out{', html, '}}', sep = '\n')
  latex_out <- paste('\\if{latex,text}{', ifelse(displayMode, '\\deqn{', '\\eqn{'),
                     tex, '}{', ascii, '}}', sep = '\n')
  paste(html_out, latex_out, sep = '\n')
}

#' Display math in R documentation
#'
#' Helper function to insert tex math expressions into R documentation (`.rd`) files.
#' Uses Katex rendering for documentation in html format, and the appropriate latex
#' macros for documentation rendered in pdf or plain-text.
#'
#' Use `math_to_rd()` inside `\Sexpr` to embed math in your R package documentation
#' pages. For example the code below can be inserted in your `rd` (or roxygen)
#' source code:
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
#' @rdname math_to_rd
#' @family katex
#' @inheritParams katex
#' @param ascii alternate text-only representation of the input math to show in
#' documentation rendered to plain text format.
math_to_rd <- function(tex, ascii = tex, displayMode = TRUE, ..., include_css = TRUE){
  html <- katex_html(tex, include_css = include_css, displayMode = displayMode, ...,
                     preview = FALSE)
  html_out <- paste('\\if{html}{\\out{', html, '}}', sep = '\n')
  latex_out <- paste('\\if{latex,text}{', ifelse(displayMode, '\\deqn{', '\\eqn{'),
                     tex, '}{', ascii, '}}', sep = '\n')
  paste(html_out, latex_out, sep = '\n')
}

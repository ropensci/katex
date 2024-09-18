#' Display math in R documentation
#'
#' Helper function to insert TeX math expressions into R documentation (`.rd`) files.
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
#' # Note about backslash (`\`) escaping
#'
#' Expressions in TeX (math) usually start with a backslash like `\frac{}`.
#' In a normal R code string, you would need to escape that backslash *once*
#' with another backslash, i.e. write `"\\frac{}"` (because the backslash is
#' used as escape character). In R documentation, you additionally need to
#' double the escaping backslashes since a backslash there is first and
#' foremost interpreted as a special character that identifies sectioning and
#' mark-up macros.
#' 
#' This means to directly insert the TeX math formula
#' `\int u \frac{dv}{dx}\,dx=uv-\int \frac{du}{dx}v\,dx` in R documentation,
#' you need to write:
#'
#' ```
#' \Sexpr[results=rd, stage=build]{
#'   katex::math_to_rd("\\\\int u \\\\frac{dv}{dx}\\\\,dx=uv-\\\\int \\\\frac{du}{dx}v\\\\,dx")
#' }
#' ```
#'
#' which then results in
#'
#' \Sexpr[results=rd, stage=build]{
#'   katex::math_to_rd("\\\\int u \\\\frac{dv}{dx}\\\\,dx=uv-\\\\int \\\\frac{du}{dx}v\\\\,dx")
#' }
#'
#' # Note for Windows
#'
#' On Windows, R versions before 4.1.2 had a [bug](https://bugs.r-project.org/show_bug.cgi?id=18152)
#' which could lead to incorrect HTML encoding for `\Sexpr{}` output.
#' As a workaround, we automatically escape non-ascii html characters
#' on these versions of R. Linux and MacOS are unaffected.
#'
#' @export
#' @name math_to_rd
#' @rdname math_to_rd
#' @family katex
#' @inheritParams katex
#' @returns a string with an rd fragment to be included in R documentation
#' @param ascii alternate text-only representation of the input math to show in
#' documentation rendered to plain text format.
math_to_rd <- function(tex, ascii = tex, displayMode = TRUE, ..., include_css = TRUE){
  html <- katex_html(tex, include_css = include_css, displayMode = displayMode, ...,
                     preview = FALSE)
  html <- workaround_htmltidy_bug(html)
  html_out <- paste('\\if{html}{\\out{', html, '}}', sep = '\n')
  latex_out <- paste('\\if{latex,text}{', ifelse(displayMode, '\\deqn{', '\\eqn{'),
                     tex, '}{', ascii, '}}', sep = '\n')
  rd <- paste(html_out, latex_out, sep = '\n')
  if(identical(.Platform$OS.type, 'windows') && getRversion() < '4.1.2'){
    # https://bugs.r-project.org/show_bug.cgi?id=18152
    rd <- ctx$call('escape_utf8', rd)
  }
  structure(rd, class = 'Rdtext')
}

# https://github.com/htacg/tidy-html5/issues/1046
workaround_htmltidy_bug <- function(x){
  sub('<svg xmlns="http://www.w3.org/2000/svg" width=\'([0-9.]+)em\' height=\'([0-9.]+)em\'',
      '<svg xmlns="http://www.w3.org/2000/svg"',
      x, perl = TRUE)
}

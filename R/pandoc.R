#' Renders math in HTML document
#'
#' Reads an html file and substitutes elements of class `"math display"` and
#' `"math inline"` with rendered html math. This is mainly intended as a
#' post-processing step for pandoc, which generates such html for equations.
#' As a result the math can show without the need for for including mathjax.
#'
#' @rdname pandoc
#' @param input path to the html input file
#' @param output path to the output html file, or NULL to return as string
#' @param include_css automatically inject the required katex css in the html head
#' @param throwOnError should invalid math raise an error in R? See [katex options](https://katex.org/docs/options.html)
#' @inheritParams katex
#' @export
render_math_in_html <- function(input, output = NULL, ..., throwOnError = FALSE, include_css = TRUE){
  html <- rawToChar(readBin(input, raw(), file.info(input)$size))
  options <- c(list(...), throwOnError = throwOnError)
  result <- ctx$call('html_render_math', html, include_css, options)
  if(!length(output)){
    return(result)
  }
  writeLines(result, output)
  return(output)
}

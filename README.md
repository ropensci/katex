# katex [![badge](https://ropensci.r-universe.dev/badges/katex)](https://ropensci.r-universe.dev)

> Rendering Math to HTML and MathML in R

Convert latex math expressions to HTML for use in markdown documents or 
package manual pages. The rendering is done in R using the V8 engine, which 
eliminates the need for embedding the MathJax library in the web pages. 

## Installation and documentation

Install directly from [r-universe](https://ropensci.r-universe.dev/):

```r
# Install from our universe
options(repos = c(
    ropensci = 'https://ropensci.r-universe.dev',
    CRAN = 'https://cloud.r-project.org'))
install.packages('katex')
```

Docs: https://docs.ropensci.org/katex/reference/katex.html

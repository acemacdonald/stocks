% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RcppExports.R
\name{pchanges}
\alias{pchanges}
\title{Lagged Proportion Changes}
\usage{
pchanges(x, lag = 1L)
}
\arguments{
\item{x}{Numeric vector.}

\item{lag}{Numeric value (e.g. 2 for differences between 1st and 3rd
element, 2nd and 4th, ...).}
}
\value{
Numeric vector.
}
\description{
Calculates proportion changes between subsequent (or lagged) elements of a 
vector.
}
\examples{
# Generate 10 values from N(0, 1)
x <- rnorm(10)

# Calculate vector of proportion changes between subsequent values
(y <- pchanges(x))

# Equivalent base R computation
len <- length(x)
p1 <- x[2: len] 
p2 <- x[1: (len - 1)] 
y2 <- p1 / p2 - 1
all.equal(y, y2)


}

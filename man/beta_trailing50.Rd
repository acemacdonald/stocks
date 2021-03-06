% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/beta_trailing50.R
\name{beta_trailing50}
\alias{beta_trailing50}
\title{Calculate Beta Using Last 50 Daily Gains}
\usage{
beta_trailing50(ticker, benchmark = "SPY", ...)
}
\arguments{
\item{ticker}{Character string with ticker symbol that Yahoo! Finance 
recognizes.}

\item{benchmark}{Character string specifying which fund to use as benchmark.}

\item{...}{Arguments to pass to \code{\link{load_gains}}.}
}
\value{
Numeric value.
}
\description{
Calculates beta for a ticker symbol based on the previous 50 daily gains.
}
\examples{
\dontrun{
# Calculate TLT's beta based on the previous 50 daily gains
beta_trailing50("TLT")
}


}
\references{
Jeffrey A. Ryan and Joshua M. Ulrich (2019). quantmod: Quantitative Financial 
Modelling Framework. R package version 0.4-15. 
\url{https://CRAN.R-project.org/package=quantmod}
}

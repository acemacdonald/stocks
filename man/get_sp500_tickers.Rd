% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_sp500_tickers.R
\name{get_sp500_tickers}
\alias{get_sp500_tickers}
\title{Get S&P 500 Ticker Symbols as on a Particular Date}
\usage{
get_sp500_tickers(date = Sys.Date())
}
\arguments{
\item{date}{Date (or character vector that can be coerced).}
}
\value{
Character vector.
}
\description{
Scrapes ticker symbols from the Wikipedia Revision history
\url{https://en.wikipedia.org/wiki/List_of_S\%26P_500_companies}. Of course,
the data may be imperfect.
}
\examples{
\dontrun{
# S&P 500 tickers as of today
head(get_sp500_tickers())

# S&P 500 tickers at the beginning of 2019
head(get_sp500_tickers("2019-01-01"))
}

}

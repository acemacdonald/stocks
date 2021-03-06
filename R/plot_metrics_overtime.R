#' Plot One Performance Metric over Time or One vs. Another over Time
#'
#' Useful for assessing how one or two performance metrics vary over time, for
#' one or several funds. Supports fixed-width rolling windows, fixed-width
#' disjoint windows, and disjoint windows on per-month or per-year basis.
#'
#'
#' @param metrics "Long" data frame with Fund column, Date column, and column
#' for each metric you want to plot. Typically the result of a prior call to
#' \code{\link{calc_metrics_overtime}}.
#' @param formula Formula specifying what to plot, e.g. \code{cagr ~ mdd} for
#' CAGR vs. MDD or \code{cagr ~ .} for CAGR over time. See \code{?calc_metrics}
#' for list of performance metrics to choose from.
#' @param type Character string or vector specifying type of calculation.
#' Choices are (1) \code{"roll.n"} where n is a positive integer; (2)
#' \code{"hop.n"} where n is a positive integer; (3) \code{"hop.month"}; (4)
#' \code{"hop.year"}; and (5) vector of break-point dates, e.g.
#' \code{c("2019-01-01", "2019-06-01")} for 3 periods. The "roll" and "hop"
#' options correspond to rolling and disjoint windows, respectively.
#' @param minimum.n Integer value specifying the minimum number of observations
#' per period, e.g. if you want to exclude short partial months at the beginning
#' or end of the analysis period.
#' @param tickers Character vector of ticker symbols that Yahoo! Finance
#' recognizes, if you want to download data on the fly.
#' @param ... Arguments to pass along with \code{tickers} to
#' \code{\link{load_gains}}.
#' @param gains Data frame with a date variable named Date and one column of
#' gains for each investment.
#' @param prices Data frame with a date variable named Date and one column of
#' prices for each investment.
#' @param benchmark,y.benchmark,x.benchmark Character string specifying which
#' fund to use as benchmark for metrics (if you request \code{alpha},
#' \code{alpha.annualized}, \code{beta}, or \code{r.squared}).
#' @param plotly Logical value for whether to convert the
#' \code{\link[ggplot2]{ggplot}} to a \code{\link[plotly]{plotly}} object
#' internally.
#' @param title Character string. Only really useful if you're going to set
#' \code{plotly = TRUE}, otherwise you can change the title, axes, etc.
#' afterwards.
#' @param base_size Numeric value.
#' @param return Character string specifying what to return. Choices are
#' \code{"plot"}, \code{"data"}, and \code{"both"}.
#'
#'
#' @return
#' Depending on \code{return}, a \code{\link[ggplot2]{ggplot}}, a data frame
#' with the source data, or a list containing both.
#'
#'
#' @examples
#' \dontrun{
#' # Plot net growth each year for BRK-B and SPY
#' plot_metrics_overtime(formula = growth ~ ., type = "hop.year", tickers = c("BRK-B", "SPY"))
#'
#' # Create previous plot in step-by-step process with pipes
#' c("BRK-B", "SPY") %>%
#'   load_gains() %>%
#'   calc_metrics_overtime("growth", type = "hop.year") %>%
#'   plot_metrics_overtime(growth ~ .)
#'
#' # Plot betas from 100-day disjoint intervals for a 2x daily (SSO) and 3x
#' # daily (UPRO) leveraged ETF
#' plot_metrics_overtime(formula = beta ~ ., type = "hop.100", tickers = c("SSO", "UPRO"))
#'
#' # Create previous plot in step-by-step process with pipes
#' c("SPY", "SSO", "UPRO") %>%
#'   load_gains() %>%
#'   calc_metrics_overtime(metrics = "beta", type = "hop.100") %>%
#'   plot_metrics_overtime(formula = beta ~ .)
#'
#' # Plot 50-day rolling alpha vs. beta for SSO and UPRO during 2018
#' plot_metrics_overtime(
#'   formula = alpha ~ beta,
#'   type = "roll.50",
#'   tickers = c("SSO", "UPRO"),
#'   from = "2018-01-01", to = "2018-12-31"
#' )
#'
#' # Create previous plot in step-by-step process with pipes
#' c("SPY", "SSO", "UPRO") %>%
#'   load_gains(from = "2018-01-01", to = "2018-12-31") %>%
#'   calc_metrics_overtime(metrics = c("alpha", "beta"), type = "roll.50") %>%
#'   plot_metrics_overtime(alpha ~ beta)
#'
#' }
#'
#'
#'
#' @export
plot_metrics_overtime <- function(metrics = NULL,
                                  formula = cagr ~ .,
                                  type = "hop.year",
                                  minimum.n = 3,
                                  tickers = NULL, ...,
                                  gains = NULL,
                                  prices = NULL,
                                  benchmark = "SPY",
                                  y.benchmark = benchmark,
                                  x.benchmark = benchmark,
                                  plotly = FALSE,
                                  title = NULL,
                                  base_size = 16,
                                  return = "plot") {

  # Extract info from formula
  all.metrics <- all.vars(formula, functions = FALSE)

  # If metrics is specified but doesn't include the expected variables, set defaults
  if (! is.null(metrics) & ! all(unlist(metric_label(all.metrics)) %in% c(".", names(metrics)))) {
    all.metrics <- unlist(label_metric(names(metrics)))
    if (length(all.metrics) == 1) {
      all.metrics <- c(all.metrics, ".")
    } else if (length(all.metrics) >= 2) {
      all.metrics <- all.metrics[1: 2]
    } else {
      stop("The input 'metrics' must have at least one column with a performance metric")
    }
  }

  y.metric <- x.metric <- NULL
  if (all.metrics[1] != ".") y.metric <- all.metrics[1]
  if (all.metrics[2] != ".") x.metric <- all.metrics[2]
  all.metrics <- c(x.metric, y.metric)

  xlabel <- metric_label(x.metric)
  ylabel <- metric_label(y.metric)

  # Align benchmarks with metrics
  if (! any(c("alpha", "alpha.annualized", "beta", "r.squared", "r", "rho") %in% y.metric)) {
    y.benchmark <- NULL
  }
  if (! any(c("alpha", "alpha.annualized", "beta", "r.squared", "r", "rho") %in% x.metric)) {
    x.benchmark <- NULL
  }

  # Check that requested metrics are valid
  invalid.requests <- all.metrics[! (all.metrics %in% c("time", metric.choices) | grepl("growth.", all.metrics, fixed = TRUE))]
  if (length(invalid.requests) > 0) {
    stop(paste("The following metrics are not allowed (see ?calc_metrics for choices):",
               paste(invalid.requests, collapse = ", ")))
  }

  # Calculate performance metrics if not pre-specified
  if (is.null(metrics)) {

    # Download data if not pre-specified
    if (is.null(gains)) {

      if (! is.null(prices)) {

        date.var <- names(prices) == "Date"
        gains <- cbind(prices[-1, date.var, drop = FALSE],
                       sapply(prices[! date.var], pchanges))

      } else if (! is.null(tickers)) {

        gains <- load_gains(tickers = c(unique(c(y.benchmark, x.benchmark)), tickers),
                            mutual.start = TRUE, mutual.end = TRUE, ...)
        tickers <- setdiff(names(gains), c("Date", y.benchmark, x.benchmark))

      } else {
        stop("You must specify 'metrics', 'gains', 'prices', or 'tickers'")
      }

    } else {
      if (is.null(tickers)) tickers <- setdiff(names(gains), c("Date", y.benchmark, x.benchmark))
    }

    # Drop NA's and convert to data.table
    gains <- as.data.table(gains[complete.cases(gains), , drop = FALSE])

    # Figure out conversion factor in case CAGR or annualized alpha is requested
    min.diffdates <- min(diff(unlist(head(gains$Date, 10))))
    time.units <- ifelse(min.diffdates == 1, "day", ifelse(min.diffdates <= 30, "month", "year"))
    units.year <- ifelse(time.units == "day", 252, ifelse(time.units == "month", 12, 1))

    # Convert gains to long format
    gains.long <- merge(
      gains[, c("Date", unique(c(y.benchmark, x.benchmark))), with = FALSE],
      gains %>%
      melt(measure.vars = tickers, variable.name = "Fund", value.name = "Gain")
    )

    # Calculate metrics depending on user choice for type
    if (substr(type[1], 1, 3) == "hop") {

      # Add Period variable
      if (type[1] == "hop.year") {
        gains.long$Period <- year(gains.long$Date)
      } else if (type[1] == "hop.month") {
        gains.long$Period <- paste(year(gains.long$Date), month(gains.long$Date, label = TRUE), sep = "-")
      } else {
        width <- as.numeric(substr(type, 5, 10))
        gains.long$Period <- rep(rep(1: ceiling(nrow(gains) / width), each = width)[1: nrow(gains)], length(tickers))
      }

      # Drop periods with too few observations and add start/end date for each period
      gains.long <- gains.long[, if (.N >= minimum.n) .SD, by = .(Fund, Period)]
      df <- gains.long[, .(`Start date` = first(Date), `End date` = last(Date)), by = .(Fund, Period)]

      if (! is.null(y.metric)) {
        df[[ylabel]] <- gains.long[, calc_metric(
          gains = Gain, metric = y.metric, units.year = units.year, benchmark.gains = get(y.benchmark)
        ), by = .(Fund, Period)][[3]]
      }

      if (! is.null(x.metric)) {
        df[[xlabel]] <- gains.long[, calc_metric(
          gains = Gain, metric = x.metric, units.year = units.year, benchmark.gains = get(x.benchmark)
        ), by = .(Fund, Period)][[3]]
      }

    } else if (substr(type[1], 1, 4) == "roll") {

      width <- as.numeric(substr(type, 6, 11))
      df <- gains.long[, .(`Start date` = Date[1: (length(Date) - width + 1)], `End date` = Date[width: length(Date)]), Fund]

      if (! is.null(y.metric)) {
        df[[ylabel]] <- gains.long[, rolling_metric(
          gains = Gain, metric = y.metric, width = width, units.year = units.year, benchmark.gains = get(y.benchmark)
        ), Fund][[2]]
      }

      if (! is.null(x.metric)) {
        df[[xlabel]] <- gains.long[, rolling_metric(
          gains = Gain, metric = x.metric, width = width, units.year = units.year, benchmark.gains = get(x.benchmark)
        ), Fund][[2]]
      }

    } else {

      type <- as.Date(type)
      if (any(is.na(type))) {
        stop("The input 'type' must be one of the following: 'roll.n' where n is a positive integer, 'hop.n' where n is a positive integer, 'hop.month', 'hop.year', or a vector of date break-points.")
      }

      daterange <- range(gains.long$Date)
      breaks <- c(daterange[1], type, daterange[2])
      labels <- sapply(1: (length(breaks) - 1), function(x) {
        paste(format(breaks[x], "%m/%d/%y"), "-", format(breaks[x + 1], "%m/%d/%y"), sep = "")
      })
      gains.long$Period <- cut(gains.long$Date, breaks = breaks, labels = labels,
                               include.lowest = TRUE, right = TRUE)

      # Drop periods with too few observations and add end date for each period
      gains.long <- gains.long[, if (.N >= minimum.n) .SD, by = .(Fund, Period)]
      df <- gains.long[, .(`Start date` = first(Date), `End date` = last(Date)), by = .(Fund, Period)]

      if (! is.null(y.metric)) {
        df[[ylabel]] <- gains.long[, calc_metric(
          gains = Gain, metric = y.metric, units.year = units.year, benchmark.gains = get(y.benchmark)
        ), by = .(Fund, Period)][[3]]
      }

      if (! is.null(x.metric)) {
        df[[xlabel]] <- gains.long[, calc_metric(
          gains = Gain, metric = x.metric, units.year = units.year, benchmark.gains = get(x.benchmark)
        ), by = .(Fund, Period)][[3]]
      }

    }

  } else {
    df <- metrics
  }

  # Create plot
  df <- as.data.frame(df)
  df <- df[order(df$Fund, df$`End date`), ]

  if (is.null(x.metric)) {

    df$tooltip <- paste(df$Fund,
                        "<br>Start date: ", df$`Start date`,
                        "<br>End date: ", df$`End date`,
                        "<br>", metric_title(y.metric), ": ", formatC(df[[ylabel]], metric_decimals(y.metric), format = "f"), metric_units(y.metric), sep = "")
    p <- ggplot(df, aes(y = .data[[ylabel]],
                        x = `End date`,
                        group = Fund, color = Fund, text = tooltip)) +
      geom_point() +
      geom_path() +
      ylim(range(c(0, df[[ylabel]])) * 1.01) +
      theme_gray(base_size = base_size) +
      theme(legend.title = element_blank()) +
      labs(title = paste(metric_title(y.metric), "over Time"),
           y = metric_label(y.metric))

  } else if (is.null(y.metric)) {

    df$tooltip <- paste(df$Fund,
                        "<br>Start date: ", df$`Start date`,
                        "<br>End date: ", df$`End date`,
                        "<br>", metric_title(x.metric), ": ", formatC(df[[xlabel]], metric_decimals(x.metric), format = "f"), metric_units(x.metric), sep = "")
    p <- ggplot(df, aes(y = `End date`,
                        x = .data[[xlabel]],
                        group = Fund, color = Fund, text = tooltip)) +
      geom_point() +
      geom_path() +
      xlim(range(c(0, df[[xlabel]])) * 1.01) +
      theme_gray(base_size = base_size) +
      theme(legend.title = element_blank()) +
      labs(title = ifelse(! is.null(title), title, paste(metric_title(y.metric), "over Time")),
           x = xlabel)

  } else {

    df$tooltip <- paste(df$Fund,
                        "<br>Start date: ", df$`Start date`,
                        "<br>End date: ", df$`End date`,
                        "<br>", metric_title(y.metric), ": ", formatC(df[[ylabel]], metric_decimals(y.metric), format = "f"), metric_units(y.metric),
                        "<br>", metric_title(x.metric), ": ", formatC(df[[xlabel]], metric_decimals(x.metric), format = "f"), metric_units(x.metric), sep = "")
    p <- ggplot(df, aes(y = .data[[ylabel]],
                        x = .data[[xlabel]],
                        group = Fund, color = Fund, text = tooltip)) +
      geom_path() +
      geom_point() +
      geom_point(data = df %>% group_by(Fund) %>% slice(1) %>% ungroup(), show.legend = FALSE) +
      geom_path(data = df %>% group_by(Fund) %>% slice(-1) %>% ungroup(), show.legend = FALSE,
                arrow = arrow(angle = 15, type = "closed", length = unit(0.1, "inches"))) +
      ylim(range(c(0, df[[ylabel]])) * 1.01) +
      ylim(range(c(0, df[[xlabel]])) * 1.01) +
      theme_gray(base_size = base_size) +
      theme(legend.title = element_blank()) +
      labs(title = ifelse(! is.null(title), title, paste(metric_title(y.metric), "vs.", metric_title(x.metric))),
           y = ylabel, x = xlabel)

  }

  if (plotly) p <- ggplotly(p, tooltip = "tooltip")

  if (return == "plot") return(p)
  if (return == "data") return(df)
  return(list(plot = p, data = df))

}

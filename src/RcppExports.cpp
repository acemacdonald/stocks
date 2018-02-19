// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

// diffs
NumericVector diffs(NumericVector x, int lag);
RcppExport SEXP _stocks_diffs(SEXP xSEXP, SEXP lagSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericVector >::type x(xSEXP);
    Rcpp::traits::input_parameter< int >::type lag(lagSEXP);
    rcpp_result_gen = Rcpp::wrap(diffs(x, lag));
    return rcpp_result_gen;
END_RCPP
}
// pchanges
NumericVector pchanges(NumericVector x, int lag);
RcppExport SEXP _stocks_pchanges(SEXP xSEXP, SEXP lagSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericVector >::type x(xSEXP);
    Rcpp::traits::input_parameter< int >::type lag(lagSEXP);
    rcpp_result_gen = Rcpp::wrap(pchanges(x, lag));
    return rcpp_result_gen;
END_RCPP
}
// pdiffs
NumericVector pdiffs(NumericVector x, int lag);
RcppExport SEXP _stocks_pdiffs(SEXP xSEXP, SEXP lagSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericVector >::type x(xSEXP);
    Rcpp::traits::input_parameter< int >::type lag(lagSEXP);
    rcpp_result_gen = Rcpp::wrap(pdiffs(x, lag));
    return rcpp_result_gen;
END_RCPP
}
// ratios
NumericVector ratios(NumericVector x);
RcppExport SEXP _stocks_ratios(SEXP xSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericVector >::type x(xSEXP);
    rcpp_result_gen = Rcpp::wrap(ratios(x));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_stocks_diffs", (DL_FUNC) &_stocks_diffs, 2},
    {"_stocks_pchanges", (DL_FUNC) &_stocks_pchanges, 2},
    {"_stocks_pdiffs", (DL_FUNC) &_stocks_pdiffs, 2},
    {"_stocks_ratios", (DL_FUNC) &_stocks_ratios, 1},
    {NULL, NULL, 0}
};

RcppExport void R_init_stocks(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}

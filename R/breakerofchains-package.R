#' @details
#' The function you are looking for is [break_chain()]. Bind it to a keyboard
#' shortcut and run it with the cursor on the line of the chain you want to run up to.
#' 
#' Why do you want this? Do you find yourself appending code to piped
#' expressions in order to break them up for debugging? For example adding
#' `I()` to the end of a line? 
#' 
#' Apart from being an annoying number of keystrokes, using these little
#' debugging trapdoors risks leaving one around in the code and creating
#' further bugs.
#'
#' `break_chain` protects you from this class of bugs since you don't need to
#' add code, but also if you are assigning the result of chain with
#' `<-` or `=` that assignment is skipped when the chain section is run.
#' 
#' Results are printed, and stored in a global `.chain`, analogous to
#' `.Last.value`. So you don't risk accidentally putting strange state into your
#' environment that will leave you scratching your head later.
#'  
#' `break_chain` works with all infix operators, and so can be used run portions
#' of `ggplot2` code chained with `+`. In addition to RStudio, it is
#' known to work with VSCode.
#
#' @seealso [break_chain()]
#' @keywords internal
"_PACKAGE"

# The following block is used by usethis to automatically manage
# roxygen namespace tags. Modify with care!
## usethis namespace: start
## usethis namespace: end
NULL

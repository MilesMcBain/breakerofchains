#' Turn "|" operator followed by ">" operator into "|>" operator
#'
#' Rejig the value columnm of sourcetools::tokenize_string(), such that base
#' pipe is a first class operator - appears in the `value` column as "|>".
#' 
#' This allows all the other infix machinery to handle base pipe as a regular
#' infix operator.
#'
#' @author Miles McBain
#' @keywords internal
polyfill_base_pipe <- function(source_tokens) {
  vertical_bar <- source_tokens$value == "|"
  greater_than <- source_tokens$value == ">"
  same_row <-
    source_tokens$row == dplyr::lead(source_tokens$row, 
                                    default = Inf)
  pipes <- 
    vertical_bar & 
    dplyr::lead(greater_than, default = FALSE) &
    same_row

  pipe_tails <- 
    dplyr::lag(pipes, default = FALSE)

  source_tokens$value[pipes] <- "|>"  
  source_tokens[!pipe_tails, ]
}

function() {

  doc_lines <-
    c(
      "libary(tidyverse)",
      "",
      "mtcars |>",
      "group_by(gear, cyl) |>",
      "summarise(mpg = mean(mpg))"
    )

  doc_text <- paste0(doc_lines, collapse = "\n")
  source_tokens <-
    sourcetools::tokenize_string(doc_text) %>%
    polyfill_base_pipe()

  mtcars |>
    group_by(gear, cyl) |>
    summarise(mpg = mean(mpg))

}
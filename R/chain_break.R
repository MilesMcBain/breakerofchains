
#' break an infix (like %>%) chain and run.
#'
#' Run a chain of piped or otherwise infixed commands up to and including the
#' cursor line. The chain is assumed to end each line with the chaining
#' operator, as is common in ' the {tidyverse} style guide.
#'  
#' When a chain begins with an assignment via `=` or `<-` the assignment is
#' not performed. Results of running the chain section are printed to the
#' console, and by default stored in a global variable called `.chain`. 
#'
#' Storing results in `.chain` can be disabled by setting
#' `options(breakerofchains_store_result = FALSE)`.
#' 
#' Your code is read via the {rstudioapi} in RStudio or {rstudioapi} emulation
#' in VSCode. Code is parsed up to the cursor line before an algorithm
#' works backwards to find the chain start. Unfortunately this means all code
#' above the cursor line must be valid parsable R code.
#'
#' It is unlikely you want to run this function directly. You probably want to
#' bind it to a keyboard shortcut. See README for more information.
#' @export
break_chain <- function() {
    doc_context <- rstudioapi::getActiveDocumentContext()

    doc_lines <- doc_context$contents

    doc_cursor_line <- rstudioapi::primary_selection(doc_context)$range$start[[1]]

    truncated_context <-
        truncate_to_chunk_boundary(doc_lines, doc_cursor_line)

    broken_chain <- get_broken_chain(truncated_context$text, truncated_context$line_number)

    print_chain_code(broken_chain)

    calling_env <- parent.frame()
    .chain <- eval(parse(text = broken_chain), envir = calling_env)
    print(.chain)

    if (getOption("breakerofchains_store_result", TRUE)) assign(".chain", .chain, .GlobalEnv)
    invisible()
}


#' get a broken chain as text
#'
#' This interface is intended for developers who want to hook into the chain
#' breaking algorithm to create bindings in other text editors.
#' 
#' Given a character vector of R code lines, and the line number of the cursor,
#' it returns a character vector of R code lines which is the start of the
#' chained expression the cursor is on, up to the cursor line.
#' 
#' Any assignment with `<-` or `=` at the head of the chain is removed.
#'
#' @param doc_lines a character vector of R code, one element per line.
#' @param doc_cursor_line a number representing the line the cursor is on.
#' @return a character vector of R code representing the broken chain. 
#' @examples
#' get_broken_chain(
#'     c(
#'      "species_scatter <- starwars %>%",
#'      "group_by(species, sex) %>%",
#'      "select(height, mass)",
#'      "    .99s.scatter <- starwars %>%",
#'      "group_by(species, sex) %>%",
#'      "select(height, mass)"
#'     ),
#'     3
#' )
#' @export
get_broken_chain <- function(doc_lines, doc_cursor_line) {
    doc_to_cursor <-
        doc_lines[seq_len(doc_cursor_line)] %>%
        crop_trailing_non_code_lines()

    if (length(doc_to_cursor) == 0) stop("No code found on or above cursor line.")

    doc_cursor_line <- length(doc_to_cursor)

    chain_start_line <- find_chain_start(doc_to_cursor)

    # clip off any infixes on the last line
    doc_lines[doc_cursor_line] <-
        gsub(CONTINUATIONS, "", doc_lines[doc_cursor_line], perl = TRUE) %>%
        trimws(which = "right")

    # clip off any assignment ops on the first line
    doc_lines[chain_start_line] <-
        gsub(
          "(^\\s*)[.A-Za-z][.A-Za-z0-9_]*\\s*(?:(?:<-)|(?:=(?!=)))\\s*",
          "\\1",
          doc_lines[chain_start_line],
          perl = TRUE
        )

    doc_lines[chain_start_line:doc_cursor_line]
}

CONTINUATIONS <- "(%[^%]+%|\\+|(?<!<)-|\\*|/|\\||&|&&|\\|\\||\\|>)\\s*(#.*)?$"


ends_infix <- function(lines) {
    grepl(
        CONTINUATIONS,
        lines,
        perl = TRUE
    )
}


R_BRACKET <- "\\)|\\]|\\}"
L_BRACKET <- "\\(|\\[|\\{"
utils::globalVariables(c(
    "type",
    "column",
    "bracket_value",
    "value",
    "line_net_bracket_value",
    "last_item"
))
#' find the start of an infix chain
#'
#'
#' Working upward from the last line, find the start of the chain.
#'
#' @param doc_lines lines of code to examine.
#'
#' @return the index into doc_lines that contains the start of the chain
#' @importFrom magrittr %>%
find_chain_start <- function(doc_lines) {
    doc_text <- paste0(doc_lines, collapse = "\n")
    source_tokens <- 
      sourcetools::tokenize_string(doc_text) %>%
      polyfill_base_pipe()


    line_ends_summary <-
        source_tokens %>%
        dplyr::filter(!(type %in% c("whitespace", "comment"))) %>%
        dplyr::mutate(
            bracket_value = dplyr::case_when(
                type == "bracket" & grepl(L_BRACKET, value) ~ 1,
                type == "bracket" ~ -1,
                TRUE ~ 0
            )
        ) %>%
        dplyr::group_by(row) %>%
        dplyr::arrange(column) %>%
        dplyr::summarise(
            line_net_bracket_value = sum(bracket_value),
            last_item = dplyr::last(value),
            .groups = "drop"
        ) %>%
        dplyr::mutate(
            content_bracket_level = content_bracket_level(line_net_bracket_value),
            continues_chain = ends_infix(last_item) | (line_net_bracket_value > 0),
            ends_chain = dplyr::row_number() == dplyr::n()
        ) %>%
        dplyr::filter(
            content_bracket_level == dplyr::last(content_bracket_level),
        )

    chained_items_rle <- rle(line_ends_summary$continues_chain | line_ends_summary$ends_chain)
    chain_length <- utils::tail(chained_items_rle$lengths, n = 1)

    utils::tail(line_ends_summary, chain_length) %>%
        dplyr::pull(row) %>%
        min()
}

content_bracket_level <- function(line_net_bracket_value) {
    nominal_values <- cumsum(line_net_bracket_value)

    open_scopes <- line_net_bracket_value > 0

    nominal_values[open_scopes] <-
        nominal_values[open_scopes] - line_net_bracket_value[open_scopes]

    # Lines that have net positive bracket values (more open than closed),
    # always have things on the lhs of those brackets. So content at the start
    # of the line has a lower bracket context than end of line.
    #
    # This matters for the filtering step of the algorithm that removes content
    # not at the same bracket level as the end of the cursor line.
    # We need to account for the fact that content at the start of the line
    # could have the same nesting level as where the chain is broken.
    # example:
    # x <-
    #   tibble(a = 1,
    #         b = 2) %>%
    #   pull(a)
    #
    # if cursor is on pull(a), we need to take into account the `tibble` call
    # is at the same bracket level as pull, even though the line ends on a
    # higher level.
    # The solution is to subtract positive net bracket values from
    # lines that open brackets, after the cumulative sum give the bracket level
    # of the end of the line.

    nominal_values
}

function() {
    doc_lines <-
        c(
            "library(dplyr)",
            "fn1 <- function() {",
            "letters %>%",
            "rev()",
            "fn2 <- function() {",
            "mtcars %>%",
            "summary()",
            "",
            "starwars %>%",
            "group_by(species, sex) %>%",
            "select(height, mass) %>%",
            "summarise(",
            "height = mean(height, na.rm = TRUE),",
            "mass = mean(mass, na.rm = TRUE)",
            ") %>%",
            "ggplot(aes(x = height, y = mass)) + ",
            "geom_point() %>%",
            ".[[1]]",
            "}",
            "}"
        )

    doc_cursor_line <- 8

    doc_text <- paste0(doc_lines, collapse = "\n")

    drake_plan(
        thing = starwars %>% 
          group_by(species, sex) %>%
          select(height, mass) %>%
          summarise(
              height = mean(height, na.rm = TRUE),
              mass = mean(mass, na.rm = TRUE)
          )
          ,
          thing2 = starwars %>% 
          group_by(species, sex) %>%
          select(height, mass) %>%
          summarise(
              height = mean(height, na.rm = TRUE),
              mass = mean(mass, na.rm = TRUE)
          )
    )
}
print_chain_code <- function(broken_chain) {
    cat(paste0(broken_chain, collapse = "\n+"), "\n")
}
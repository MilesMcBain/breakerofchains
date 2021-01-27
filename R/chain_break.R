
#' break an infix (like %>%) chain and run.
#'
#' Run a chain of piped or otherwise infixed commands up to and including the
#cursor line.
#'
#' @export
break_chain <- function() {

    doc_context <- rstudioapi::getActiveDocumentContext()

    doc_lines <- doc_context$contents

    doc_cursor_line <- rstudioapi::primary_selection(doc_context)$range$start[[1]]

    truncated_context <- 
      truncate_to_chunk_boundary(doc_lines, doc_cursor_line)

    broken_chain <- get_broken_chain(truncated_context$text, truncated_context$line_number)

    rstudioapi::sendToConsole(
        broken_chain,
        execute = TRUE,
        echo = TRUE,
        focus = FALSE
    )

}

get_broken_chain <- function(doc_lines, doc_cursor_line) {
    doc_to_cursor <- doc_lines[seq(doc_cursor_line)]

    chain_start_line <- find_chain_start(doc_to_cursor)

    # clip off any infixes on the last line
    doc_lines[doc_cursor_line] <- 
        gsub(CONTINUATIONS, "", doc_lines[doc_cursor_line], perl = TRUE) %>%
        trimws()

    # clip off any assignment ops on the first line
    doc_lines[chain_start_line] <-
        gsub("^\\s*[.A-Za-z][.A-Za-z0-9_]*\\s*<-", "", doc_lines[chain_start_line]) %>%
        trimws()

    doc_lines[chain_start_line:doc_cursor_line]
}

CONTINUATIONS <- "(%[^%]+%|\\+|(?<!<)-|\\*|/|\\||&|&&|\\|\\|)\\s*(#.*)?$"


ends_infix <- function(lines) {
    grepl(
        CONTINUATIONS,
        lines,
        perl = TRUE
    )
}


R_BRACKET <- "\\)|\\]|\\}"
L_BRACKET <- "\\(|\\[|\\{"
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
    source_tokens <- sourcetools::tokenize_string(doc_text)


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
        chain_length <- tail(chained_items_rle$lengths,  n = 1)

        tail(line_ends_summary, chain_length) %>% 
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
}
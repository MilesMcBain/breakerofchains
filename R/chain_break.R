break_chain <- function() {

    doc_context <- rstudioapi::getActiveDocumentContext()

    doc_lines <- doc_context$contents

    doc_cursor_line <- rstudioapi::primary_selection(doc_context)$range$start[[1]]

    broken_chain <- get_broken_chain(doc_lines, doc_cursor_line)

    rstudioapi::sendToConsole(
        broken_chain,
        execute = TRUE,
        echo = TRUE,
        focus = FALSE
    )

}

get_broken_chain <- function(doc_lines, doc_cursor_line) {
    doc_to_cursor <- doc_lines[seq(doc_cursor_line)]

    chain_start_line <- find_chain_start(doc_to_cursor[-doc_cursor_line])

    doc_lines[doc_cursor_line] <- 
        gsub(CONTINUATIONS, "", doc_lines[doc_cursor_line]) %>%
        trimws()

    doc_lines[chain_start_line:doc_cursor_line]
}

CONTINUATIONS <- "%[^%]+%|\\+|-|\\*|/|\\||&|&&|\\|\\|"


continues_chain <- function(lines) {
    grepl(
        glue::glue("({CONTINUATIONS})\\s*$"),
        lines
    )
}

find_chain_start <- function(doc_lines) {

    doc_text <- paste0(doc_lines, collapse = "\n")
    source_tokens <- sourcetools::tokenize_string(doc_text)

    r_bracket <- "\\)|\\]|\\}"

    line_ends_summary <-
    source_tokens %>%
        dplyr::filter(type != "whitespace") %>%
        dplyr::mutate(
            bracket_level = dplyr::case_when(
                type == "bracket" & grepl(r_bracket, value) ~ -1,
                type == "bracket" ~ 1,
                TRUE ~ 0
            )
        ) %>%
        dplyr::group_by(row) %>%
        dplyr::arrange(column) %>%
        dplyr::summarise(
            bracket_level = sum(bracket_level),
            last_item = dplyr::last(value),
            .groups = "drop"
        ) %>%
        dplyr::mutate(
            bracket_level = cumsum(bracket_level),
            continues_chain = continues_chain(last_item)
        ) %>%
        dplyr::filter(
            bracket_level == 0,
        )

        last_item_continues_rle <- rle(line_ends_summary$continues_chain)
        chain_length <- tail(last_item_continues_rle$lengths,  n = 1)

        tail(line_ends_summary, chain_length) %>% 
            dplyr::pull(row) %>% 
            min()
        
}

function() {
    doc_lines <-
        c(
            "library(dplyr)",
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
            ".[[1]]"
        )

    doc_cursor_line <- 13

    doc_text <- paste0(doc_lines, collapse = "\n")
}
chain_break <- function() {
    doc_context <- rstudioapi::getActiveDocumentContext()

    doc_lines <- doc_context$contents

    doc_cursor_line <- rstudioapi::primary_selection(doc_context)$range$start[[1]]

    doc_to_cursor <- doc_lines[seq(doc_cursor_line)]


    candidate_text <- paste0(doc_to_cursor, collapse = "\n")

    start_line <- find_chain_start(candidate_text)

}

continuations <- "%>%|\\+"


chain_continues <- function(lines) {
    grepl(
        glue::glue("({continuations})\\s*$"),
        lines
    )
}

find_chain_start <- function(doc_text) {
    source_tokens <- sourcetools::tokenize_string(doc_text)

    r_bracket <- "\\)|\\]|\\}"

    source_tokens %>%
        filter(row <= doc_cursor_line) %>%
        filter(type != "whitespace") %>%
        mutate(
            bracket_level = case_when(
                type == "bracket" & grepl(r_bracket, value) ~ -1,
                type == "bracket" ~ 1,
                TRUE ~ 0
            )
        ) %>%
        group_by(row) %>%
        arrange(column) %>%
        summarise(
            bracket_level = sum(bracket_level),
            last_item = last(value),
            .groups = "drop"
        ) %>%
        mutate(bracket_level = cumsum(bracket_level)) %>%
        filter(
            bracket_level == 0,
            chain_continues(last_item)
        ) %>%
        pull(row) %>%
        min()
}

function() {
    doc_lines <-
        c(
            "library(dplyr)",
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

    doc_cursor_line <- 11

    doc_text <- paste0(doc_lines, collapse = "\n")
}
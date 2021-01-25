truncate_to_chunk_boundary <- function(text, line_number) {

  tripple_ticks <- gregexpr("```", text, perl = TRUE)
 
  match_lines <- which(tripple_ticks > -1)

  upper_fence <- head(match_lines[match_lines > line_number], 1)
  lower_fence <- tail(match_lines[match_lines < line_number], 1)

  if (length(upper_fence) == 0) {
    upper_bound <- length(text)
  } else {
    upper_bound <- upper_fence - 1
  }

  if (length(lower_fence) == 0) {
    lower_bound <-  1
  } else {
    lower_bound <- lower_fence + 1
  }

  list(
    line_number = line_number - (lower_bound - 1),
    text = text[lower_bound:upper_bound]
  )

}

function() {
  text <-
c(
  "# Blah",
  "",
  "```{r}",
  "print(\"hi again\")",
  "",
  "mtcars %>%",
  "filter(gear > 3) %>%",
  "filter()",
  "```",
  "",
  "blah blah"
  )

  line_number <- 7

}

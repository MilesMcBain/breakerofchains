truncate_to_chunk_boundary <- function(text, line_number) {

  tripple_ticks <- gregexpr("```", text, perl = TRUE)
 
tibble::tribble(
    ~s_orgu_id,        ~name,       ~type, ~identifier, ~levy_class,          ~lon,          ~lat,
       239028L, "Townsville", "Permanent",        114L,         "A", 146.820588566, -19.263195895,
       239026L,     "Kirwan", "Permanent",        113L,         "A", 146.731223865, -19.309386332,
       239022L,  "Woodlands", "Permanent",        111L,         "A", 146.709546758, -19.264696038,
       239030L,    "Wulguru", "Permanent",        115L,         "A",  146.81437861, -19.319617496
    ) %>% 
    pull(s_orgu_id)

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

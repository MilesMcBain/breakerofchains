test_that("I can break chains", {
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
      "ggplot(aes(x = height, y = mass)) +",
      "geom_point() %>%",
      ".[[1]]"
    )

  expect_equal(
    get_broken_chain(doc_lines, 13),
    c(
      "starwars %>%",
      "group_by(species, sex) %>%",
      "select(height, mass) %>%",
      "summarise(",
      "height = mean(height, na.rm = TRUE),",
      "mass = mean(mass, na.rm = TRUE)",
      ") %>%",
      "ggplot(aes(x = height, y = mass)) +",
      "geom_point()"
    )
  )

  expect_equal(
    get_broken_chain(doc_lines, 3),
    c(
      "mtcars %>%",
      "summary()"
    )
  )

  expect_equal(
    get_broken_chain(doc_lines, 6),
    c(
      "starwars %>%",
      "group_by(species, sex)"
    )
  )


  doc_lines2 <-
    c(
      "libary(tidyverse)",
      "",
      "mtcars |>",
      "group_by(gear, cyl) |>",
      "summarise(mpg = mean(mpg))"
    )

  ## Will fail for now since sourcetools doesn't know new operator
  expect_equal(
    get_broken_chain(doc_lines2, 4),
    c(
      "mtcars |>",
      "group_by(gear, cyl)"
    )
  )

  doc_lines3 <-
    c(
      "c(-2, -1, 0, 1, 2) %>%",
      "mean() +",
      "1 -",
      "2 *",
      "1 /",
      "1 %>%",
      "as.logical() |",
      "TRUE &",
      "FALSE ||",
      "TRUE &&",
      "TRUE"
    )

  expect_equal(
    get_broken_chain(doc_lines3, 6),
    c(
      "c(-2, -1, 0, 1, 2) %>%",
      "mean() +",
      "1 -",
      "2 *",
      "1 /",
      "1"
    )
  )

  expect_equal(
    get_broken_chain(doc_lines3, 11),
    c(
      "c(-2, -1, 0, 1, 2) %>%",
      "mean() +",
      "1 -",
      "2 *",
      "1 /",
      "1 %>%",
      "as.logical() |",
      "TRUE &",
      "FALSE ||",
      "TRUE &&",
      "TRUE"
    )
  )

  expect_equal(
    get_broken_chain(doc_lines3, 9),
    c(
      "c(-2, -1, 0, 1, 2) %>%",
      "mean() +",
      "1 -",
      "2 *",
      "1 /",
      "1 %>%",
      "as.logical() |",
      "TRUE &",
      "FALSE"
    )
  )

  pipe_lines <-
    c(
      "foo %<>%",
      "rnorm(200) %>%",
      "matrix(ncol = 2) %*%",
      "matrix(rep(1, 200) ncol = 2) %T>%",
      "plot %>%",
      "colSums"
    )

  expect_equal(
    get_broken_chain(pipe_lines, 4),
    c(
      "foo %<>%",
      "rnorm(200) %>%",
      "matrix(ncol = 2) %*%",
      "matrix(rep(1, 200) ncol = 2)"
    )
  )

  expect_equal(
    get_broken_chain(pipe_lines, 6),
    c(
      "foo %<>%",
      "rnorm(200) %>%",
      "matrix(ncol = 2) %*%",
      "matrix(rep(1, 200) ncol = 2) %T>%",
      "plot %>%",
      "colSums"
    )
  )

  rmd_lines <-
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

  truncated_context <- truncate_to_chunk_boundary(rmd_lines, 7)

  expect_equal(
    get_broken_chain(truncated_context$text, truncated_context$line_number),
    c(
      "mtcars %>%",
      "filter(gear > 3)"
    )
  )

  doc_lines4 <-
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

  expect_equal(
    get_broken_chain(doc_lines4, 4),
    c(
      "letters %>%",
      "rev()"
    )
  )

  expect_equal(
    get_broken_chain(doc_lines4, 15),
    c(
      "starwars %>%",
      "group_by(species, sex) %>%",
      "select(height, mass) %>%",
      "summarise(",
      "height = mean(height, na.rm = TRUE),",
      "mass = mean(mass, na.rm = TRUE)",
      ")"
    )
  )

  expect_equal(
    get_broken_chain(doc_lines4, 7),
    c(
      "mtcars %>%",
      "summary()"
    )
  )

  div_lines <-
    c(
      "test <-",
      "starwars %>%",
      "group_by(species, sex) %>%",
      "select(height, mass) %>%",
      "mutate(BMI = mass / ((height * 100) ^ 2)) %>%",
      "summarise(",
      "height = mean(height, na.rm = TRUE)",
      "mass = mean(mass, na.rm = TRUE)",
      ")"
    )

  ## don't sub symbols and don't let assignment continue chain
  expect_equal(
    get_broken_chain(div_lines, 5),
    c(
      "starwars %>%",
      "group_by(species, sex) %>%",
      "select(height, mass) %>%",
      "mutate(BMI = mass / ((height * 100) ^ 2))"
    )
  )

  tribble_lines <-
    c(
      "thing <-",
      "tibble::tribble(",
      "~s_orgu_id,        ~name,       ~type, ~identifier, ~levy_class,          ~lon,          ~lat,",
      "239028L, \"Townsville\", \"Permanent\",        114L,         \"A\", 146.820588566, -19.263195895,",
      "239026L,     \"Kirwan\", \"Permanent\",        113L,         \"A\", 146.731223865, -19.309386332,",
      "239022L,  \"Woodlands\", \"Permanent\",        111L,         \"A\", 146.709546758, -19.264696038,",
      "239030L,    \"Wulguru\", \"Permanent\",        115L,         \"A\",  146.81437861, -19.319617496",
      ") %>%",
      "pull(s_orgu_id) %>%",
      "c(rev(",
      "letters",
      "))"
    )

  expect_equal(
    get_broken_chain(tribble_lines, 9),
    c(
      "tibble::tribble(",
      "~s_orgu_id,        ~name,       ~type, ~identifier, ~levy_class,          ~lon,          ~lat,",
      "239028L, \"Townsville\", \"Permanent\",        114L,         \"A\", 146.820588566, -19.263195895,",
      "239026L,     \"Kirwan\", \"Permanent\",        113L,         \"A\", 146.731223865, -19.309386332,",
      "239022L,  \"Woodlands\", \"Permanent\",        111L,         \"A\", 146.709546758, -19.264696038,",
      "239030L,    \"Wulguru\", \"Permanent\",        115L,         \"A\",  146.81437861, -19.319617496",
      ") %>%",
      "pull(s_orgu_id)"
    )
  )

  expect_equal(
    get_broken_chain(tribble_lines, 12),
    c(
      "tibble::tribble(",
      "~s_orgu_id,        ~name,       ~type, ~identifier, ~levy_class,          ~lon,          ~lat,",
      "239028L, \"Townsville\", \"Permanent\",        114L,         \"A\", 146.820588566, -19.263195895,",
      "239026L,     \"Kirwan\", \"Permanent\",        113L,         \"A\", 146.731223865, -19.309386332,",
      "239022L,  \"Woodlands\", \"Permanent\",        111L,         \"A\", 146.709546758, -19.264696038,",
      "239030L,    \"Wulguru\", \"Permanent\",        115L,         \"A\",  146.81437861, -19.319617496",
      ") %>%",
      "pull(s_orgu_id) %>%",
      "c(rev(",
      "letters",
      "))"
    )
  )

  nested_chains <-
    c(
      "table1 %>%",
      "left_join(",
      "table2 %>% select(var1, var2) %>%",
      "group_by(var1) %>%",
      "summarise(mv2 = mean(var2))",
      ") %>%",
      "pull(mv2) %>%",
      "min()"
    )

  expect_equal(
    get_broken_chain(nested_chains, 4),
    c(
      "table2 %>% select(var1, var2) %>%",
      "group_by(var1)"
    )
  )

  expect_equal(
    get_broken_chain(nested_chains, 7),
    c(
      "table1 %>%",
      "left_join(",
      "table2 %>% select(var1, var2) %>%",
      "group_by(var1) %>%",
      "summarise(mv2 = mean(var2))",
      ") %>%",
      "pull(mv2)"
    )
  )

  assignment_lines <-
    c(
      "species_scatter <- starwars %>%",
      "group_by(species, sex) %>%",
      "select(height, mass)",
      "    .99s.scatter <- starwars %>%",
      "group_by(species, sex) %>%",
      "select(height, mass)"
    )

  expect_equal(
    get_broken_chain(assignment_lines, 3),
    c(
      "starwars %>%",
      "group_by(species, sex) %>%",
      "select(height, mass)"
    )
  )
  expect_equal(
    get_broken_chain(assignment_lines, 5),
    c(
      "starwars %>%",
      "group_by(species, sex)"
    )
  )

  expect_equal(
    get_broken_chain(assignment_lines, 1),
    c(
      "starwars"
    )
  )

  equals_assignment_lines <-
    c(
      "species_scatter = starwars %>%",
      "group_by(species, sex) %>%",
      "select(height, mass)",
      "    .99s.scatter = starwars %>%",
      "group_by(species, sex) %>%",
      "select(height, mass)"
    )

   expect_equal(
    get_broken_chain(equals_assignment_lines, 3),
    c(
      "starwars %>%",
      "group_by(species, sex) %>%",
      "select(height, mass)"
    )
  )
  expect_equal(
    get_broken_chain(equals_assignment_lines, 5),
    c(
      "starwars %>%",
      "group_by(species, sex)"
    )
  )

  expect_equal(
    get_broken_chain(equals_assignment_lines, 1),
    c(
      "starwars"
    )
  )

  comment_lines <-
    c(
      "# blah blah -",
      "species_scatter <- starwars %>%",
      "group_by(species, sex) %>%",
      "select(height, mass)",
      "## something something %>%",
      "    .99s.scatter <- starwars2 %>%",
      "group_by(species, sex) %>%",
      "select(height2, mass2) %>% ## comment @ end",
      "# a comment in the middle",
      "# that does over two lines",
      "summarise()"
    )

  expect_equal(
    get_broken_chain(comment_lines, 4),
    c(
      "starwars %>%",
      "group_by(species, sex) %>%",
      "select(height, mass)"
    )
  )

  expect_equal(
    get_broken_chain(comment_lines, 5),
    c(
      "starwars %>%",
      "group_by(species, sex) %>%",
      "select(height, mass)"
    )
  )

  expect_equal(
    get_broken_chain(comment_lines, 6),
    "starwars2"
  )

  expect_equal(
    get_broken_chain(comment_lines, 8),
    c(
      "starwars2 %>%",
      "group_by(species, sex) %>%",
      "select(height2, mass2)"
    )
  )

  expect_equal(
    get_broken_chain(comment_lines, 10),
    c(
      "starwars2 %>%",
      "group_by(species, sex) %>%",
      "select(height2, mass2)"
    )
  )

  expect_equal(
    get_broken_chain(comment_lines, 11),
    c(
      "starwars2 %>%",
      "group_by(species, sex) %>%",
      "select(height2, mass2) %>% ## comment @ end",
      "# a comment in the middle",
      "# that does over two lines",
      "summarise()"
    )
  )

  many_comment_lines <-
    c(
      "# comment 1",
      "# comment 2",
      "starwars",
      "# comment 3",
      "# comment 4"
    )

  expect_equal(
    get_broken_chain(many_comment_lines, 5),
    c("starwars")
  )

  expect_error(
    get_broken_chain(many_comment_lines, 2),
    "No code found on or above cursor line."
  )

  empty_lines <-
    c(
      "",
      "species_scatter <- starwars %>%",
      "",
      "group_by(species, sex) %>%",
      "select(height, mass)",
      "",
      "",
      "    .99s.scatter <- starwars2 %>%",
      "group_by(species, sex) %>%",
      "select(height2, mass2) %>% ## comment @ end",
      "",
      "",
      "summarise()"
    )

  expect_equal(
    get_broken_chain(empty_lines, 5),
    c(
      "starwars %>%",
      "",
      "group_by(species, sex) %>%",
      "select(height, mass)"
    )
  )


  expect_equal(
    get_broken_chain(empty_lines, 7),
    c(
      "starwars %>%",
      "",
      "group_by(species, sex) %>%",
      "select(height, mass)"
    )
  )

  expect_equal(
    get_broken_chain(empty_lines, 12),
    c(
      "starwars2 %>%",
      "group_by(species, sex) %>%",
      "select(height2, mass2)"
    )
  )

  expect_equal(
    get_broken_chain(empty_lines, 13),
    c(
      "starwars2 %>%",
      "group_by(species, sex) %>%",
      "select(height2, mass2) %>% ## comment @ end",
      "",
      "",
      "summarise()"
    )
  )
})
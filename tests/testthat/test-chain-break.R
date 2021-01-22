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


})
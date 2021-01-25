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
})
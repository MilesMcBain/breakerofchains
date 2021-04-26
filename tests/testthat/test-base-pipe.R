test_that("base pipe works", {

  doc_lines <-
    c(
      "library(dplyr)",
      "mtcars |>",
      "summary()",
      "",
      "starwars |>",
      "group_by(species, sex) |>",
      "select(height, mass) |>",
      "summarise(",
      "height = mean(height, na.rm = TRUE),",
      "mass = mean(mass, na.rm = TRUE)",
      ") |>",
      "ggplot(aes(x = height, y = mass)) +",
      "geom_point() |>",
      ".[[1]]"
    )
  
expect_equal(
    get_broken_chain(doc_lines, 13),
    c(
      "starwars |>",
      "group_by(species, sex) |>",
      "select(height, mass) |>",
      "summarise(",
      "height = mean(height, na.rm = TRUE),",
      "mass = mean(mass, na.rm = TRUE)",
      ") |>",
      "ggplot(aes(x = height, y = mass)) +",
      "geom_point()"
    )
  )

  expect_equal(
    get_broken_chain(doc_lines, 3),
    c(
      "mtcars |>",
      "summary()"
    )
  )

  expect_equal(
    get_broken_chain(doc_lines, 6),
    c(
      "starwars |>",
      "group_by(species, sex)"
    )
  )
  
  doc_text <- paste0(doc_lines, collapse = "\n")

  source_tokens <- sourcetools::tokenize_string(doc_text)
  
  # need to know if sourcetools behaviour changes:
  expect_snapshot( 
    source_tokens
  )
  
  expect_snapshot( 
    polyfill_base_pipe(source_tokens)
  )
  
  not_a_pipe <-
    "123 | > I()"

  result1 <- 
    polyfill_base_pipe(sourcetools::tokenize_string(not_a_pipe)) 

  not_a_pipe2 <-
    "123 |\n> I()"

  result2 <- 
    polyfill_base_pipe(sourcetools::tokenize_string(not_a_pipe2)) 
  
  expect_equal(
    any(result1$value == "|>"),
    FALSE
  )

  expect_equal(
    any(result2$value == "|>"),
    FALSE
  )

})

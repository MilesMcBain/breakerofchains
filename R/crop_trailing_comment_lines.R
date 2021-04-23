crop_trailing_non_code_lines <- function(text) {
  comment_lines <- grepl("^\\s*#.*", text)

  empty_lines <- text == ""

  non_code_lines_rle <- rle(comment_lines | empty_lines)

  if (utils::tail(non_code_lines_rle$values, 1)) {
    num_trailing_non_code_lines <- utils::tail(non_code_lines_rle$lengths, 1)
    text_length <- length(text) - num_trailing_non_code_lines

    text[seq_len(text_length)]
  } else {
    text
  }
}
crop_trailing_comment_lines <- function(text) {
  comment_lines <- grepl("^\\s*#.*", text)

  comment_lines_rle <- rle(comment_lines)

  if (tail(comment_lines_rle$values, 1)) {
    num_trailing_comment_lines <- tail(comment_lines_rle$lengths, 1)
    text_length <- length(text) - num_trailing_comment_lines

    text[seq_len(text_length)]
  } else {
    text
  }
}
# 0.3.2

* Minor usability fix for RStudio
* Make compatible with more strict type checking in dev `{dplyr}`.

# 0.3.0

`break_chain()` is now extendable by developers. It returns the result of chain
evaluation invisibly, so that you can handle the result as you choose with a new
shortcut, e.g. `View(break_chain())`. Also in aid of this, printing and
assigning the result of evaluation can be disabled via arguments, e.g. : 

`View(break_chain(print_result = FALSE, assign_result = FALSE))`

For RStudio users, probably the best way to quickly build a custom chain result
handler is via the excellent `{shrtcts}` package. You could put something like
this in your `~/shrtcts.R`:

```{r}
#' View broken chain
#'
#' @interactive
function() {
  View(breakerofchains::break_chain(print_result = FALSE, assign_result = FALSE))
}
```

Thanks to @chorgan182 for giving me the idea for this in [#15](https://github.com/MilesMcBain/breakerofchains/issues/15)
.onLoad <- function(...) {

  tryCatch( {
    shiny::registerInputHandler(
      "shinyTree.changed",
      function(x, session, inputName) {
        result <- x$value
        attr(result, "type") <- x$type
        attr(result, "action") <- x$action
        return(result)
      },
      force = TRUE
    )
  }, error = function(err) {})
}
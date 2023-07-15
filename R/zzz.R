.onLoad <- function(...) {

  tryCatch( {
    
    shiny::registerInputHandler("shinyTree", function(val, shinysession, name){
      val
    })
    
    shiny::registerInputHandler(
      "shinyTree.changed",
      function(x, session, inputName) {
        if(is.null(x$value)) return(NULL)
        
        result <- x$value
        attr(result, "type") <- x$type
        attr(result, "action") <- x$action
        return(result)
      },
      force = TRUE
    )
  }, error = function(err) {})
}
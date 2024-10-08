.global <- new.env()

initResourcePaths <- function() {
  if (is.null(.global$loaded)) {
    shiny::addResourcePath(
      prefix = 'shinyTree',
      directoryPath = system.file('www', package='shinyTree'))
    .global$loaded <- TRUE
  }
  shiny::HTML("")
}

jsonToAttr <- function(json){
  ret <- list()
  
  if (! "text" %in% names(json)){
    # This is a top-level list, not a node.
    for (i in 1:length(json)){
      ret[[json[[i]]$text]] <- jsonToAttr(json[[i]])
      ret[[json[[i]]$text]] <- supplementAttr(ret[[json[[i]]$text]], json[[i]])
    }
    return(ret)
  }
  
  if (length(json$children) > 0){
    return(jsonToAttr(json[["children"]]))
  } else {
    ret <- 0
    ret <- supplementAttr(ret, json)    
    return(ret)
  }
}

supplementAttr <- function(ret, json){
  # Only add attributes if non-default
  #cat("JSON string:\n")
  #cat(str(json))
  
  if (json$state$selected != FALSE){
    attr(ret, "stselected") <- json$state$selected
  }
  if (json$state$disabled != FALSE){
    attr(ret, "stdisabled") <- json$state$disabled
  }
  if (json$state$opened != FALSE){
    attr(ret, "stopened") <- json$state$opened
  }
  if (exists('stid', where=json)) {
    attr(ret, "stid") <- json$stid
  }
  if (exists('stclass', where=json)) {
    attr(ret, "stclass") <- json$stclass
  }
  if (exists('id', where=json)) {
    attr(ret, "id") <- json$id
  }
  ret
}

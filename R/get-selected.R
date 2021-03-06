#' Get the selected nodes from a tree
#' 
#' Extract the nodes from the tree that are selected in a more
#' convenient format. You can choose which format you prefer.
#' 
#' @param tree The \code{input$tree} shinyTree you want to 
#' inspect.
#' @param format In which format you want the output. Use 
#' \code{names} to get a simple list of the names (with attributes
#' describing the node's ancestry), or \code{slices} to get a list
#' of lists, each of which is a slice of the list used to get down
#' to the selected node. 
#' @export
get_selected <- function(tree, format=c("names", "slices", "classid")){
  format <- match.arg(format, c("names", "slices", "classid"), FALSE)
  switch(format,
         "names"=get_selected_names(tree),
         "slices"=get_selected_slices(tree),
         "classid"=get_selected_classid(tree)
         )  
}

get_selected_names <- function(tree, ancestry=NULL, vec=list()){
  if (is.list(tree)){
    for (i in 1:length(tree)){
      anc <- c(ancestry, names(tree)[i])
      vec <- get_selected_names(tree[[i]], anc, vec)
    }    
  }
  
  a <- attr(tree, "stselected", TRUE)
  if (!is.null(a) && a == TRUE){
    # Get the element name
    el <- tail(ancestry,n=1)
    vec[length(vec)+1] <- el
    attr(vec[[length(vec)]], "ancestry") <- head(ancestry, n=length(ancestry)-1)
  }
  return(vec)
}

get_selected_slices <- function(tree, ancestry=NULL, vec=list()){
  
  if (is.list(tree)){
    for (i in 1:length(tree)){
      anc <- c(ancestry, names(tree)[i])
      vec <- get_selected_slices(tree[[i]], anc, vec)
    }    
  }
  
  a <- attr(tree, "stselected", TRUE)
  if (!is.null(a) && a == TRUE){
    # Get the element name
    ancList <- 0
    
    for (i in length(ancestry):1){
      nl <- list()
      nl[ancestry[i]] <- list(ancList)
      ancList <- nl
    }
    vec[length(vec)+1] <- list(ancList)
  }
  return(vec)
}

get_selected_classid <- function(tree, ancestry=NULL, vec=list()){
    if (is.list(tree)){
      for (i in 1:length(tree)){
        anc <- c(ancestry, names(tree)[i])
        vec <- get_selected_classid(tree[[i]], anc, vec)
      }
    }
    
    a <- attr(tree, "stselected", TRUE)
    if (!is.null(a) && a == TRUE){
      # Get the element name
      el <- tail(ancestry,n=1)
      vec[length(vec)+1] <- el
      attr(vec[[length(vec)]], "stclass") <- attr(tree, "stclass", TRUE)
      attr(vec[[length(vec)]], "stid") <- attr(tree, "stid", TRUE)
      attr(vec[[length(vec)]], "id") <- attr(tree, "id", TRUE)
    }
    return(vec)
  }

recurse <- function(l, func, ...) {
  l <- func(l, ...)
  if(is.list(l) && length(l)>0){
    lapply(
      l,
      function(ll){
        recurse(ll, func, ...)
      }
    )
  } else {
    
  }
}

#' Get Selected Nodes
#' 
#' @param tree \code{List} returned from a 'ShinyTree'.
#' @param field \code{character} name of field to return instead of 'text'
#' @export
get_selected_nodes <- function(tree = NULL, field = NULL) {
  if(is.null(tree)) { return(NULL) }
  selected <- c()
  
  lapply(
    tree,
    function(x) {
      recurse(
        x,
        function(y){
          if(
            !is.null(names(y)) &&
            !is.null(y$state$selected) &&
            y$state$selected == TRUE &&
            # only leaves
            length(y$children) == 0
          ) {
            returndat <- y$text
            if(!is.null(field) && "data" %in% names(y) && field %in% names(y$data)) {
              returndat <- y$data[[field]]
            }
            if(!is.null(field) && !("data" %in% names(y) && field %in% names(y$data))) {
              warning(paste0(field, " not found in node so returning 'text' instead'"), call. = FALSE)
            }
            selected <<- c(
              selected,
              returndat
            )
          }
          if(is.list(y) && "children" %in% names(y) && length(y$children) > 0) {
            y$children
          } else {
          }
        }
      )
    }
  )
  return(selected)
}

#' Get Leaf Nodes
#' 
#' @param tree \code{List} returned from a 'ShinyTree'.
#' @export
get_leaf_nodes <- function(tree = NULL) {
  if(is.null(tree)) { return(NULL) }
  selected <- list()
  
  lapply(
    tree,
    function(x) {
      recurse(
        x,
        function(y){
          if(
            !is.null(names(y)) &&
            # only leaves
            length(y$children) == 0
          ) {
            selected <<- c(
              selected,
              list(y),
              recursive = FALSE
            )
          }
          if(is.list(y) && "children" %in% names(y) && length(y$children) > 0) {
            y$children
          } else {
          }
        }
      )
    }
  )
  return(selected)
}

#' Get State for Leaf Nodes
#' 
#' @param tree \code{List} returned from a 'ShinyTree'.
#' @param leaves \code{logical} if \code{TRUE} then return only leaf nodes.
#' @export
get_state_nodes <- function(tree = NULL, leaves = TRUE) {
  if(is.null(tree)) { return(NULL) }
  selected <- list(text=c(), state=list(), data=list())

  lapply(
    tree,
    function(x) {
      recurse(
        x,
        function(y){
          if(
            !is.null(names(y)) &&
            !is.null(y$state)
          ) {
            if(
              (leaves == TRUE && length(y$children) == 0) || # leaf nodes only
              (leaves == FALSE) # all nodes
            ) {
              selected$text[[length(selected$text) + 1]] <<- y$text
              selected$state[[length(selected$state) + 1]] <<- y$state
              selected$data[[length(selected$data) + 1]] <<- y$data
            }
          }
          if(is.list(y) && "children" %in% names(y) && length(y$children) > 0) {
            y$children
          } else {
          }
        }
      )
    }
  )
  return(selected)
}
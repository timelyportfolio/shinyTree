#' Create a Shiny Tree
#' 
#' This creates a spot in your Shiny UI for a shinyTree which can then be filled
#' in using \code{\link{renderTree}}
#' @param outputId The ID associated with this element
#' @param checkbox If \code{TRUE}, will enable checkboxes next to each node to 
#' make the selection of multiple nodes in the tree easier.
#' @param search If \code{TRUE}, will enable search functionality in the tree by adding
#' a search box above the produced tree. Alternatively, you can set the parameter
#' to the ID of the text input you wish to use as the search field.
#' @param dragAndDrop If \code{TRUE}, will allow the user to rearrange the nodes in the
#' tree.
#' @param theme jsTree theme, one of \code{default}, \code{default-dark}, or \code{proton}.
#' @param themeIcons If \code{TRUE}, will show theme icons for each item.
#' @param themeDots If \code{TRUE}, will include level dots.
#' @parem config \code{list} of additional jsTree config
#' @seealso \code{\link{renderTree}}
#' @export
shinyTree <- function(
  outputId,
  checkbox=FALSE,
  search=FALSE,
  dragAndDrop=FALSE,
  theme="default", themeIcons=TRUE, themeDots=TRUE,
  config=NULL
){
  searchEl <- shiny::div(style="position: relative;","")
  if (search == TRUE){
    search <- paste0(outputId, "-search-input")
    searchEl <- shiny::div(
      style="position:relative; width:60%;",
      class="shinytree-search-box",
      shiny::tags$input(
        id=search,
        class="input",
        style="padding-left:2em; padding-right:2em; margin-bottom:10px; width:100%;",
        type="text",
        value="",
        placeholder="Search",
        shiny::tags$i(
          class = "fa fa-search",
          style = "font-size:1em;position:absolute;left:0.5em;top:0.25em;color:#aaa;"
        ),
        shiny::tags$span(
          class = "search-remove",
          style = "font-size:1em;position:absolute;right:0.5em;top:0.15em;padding:0.1em;",
          shiny::tags$i(class = "fa fa-remove")
        )
      )
    )
  }
  if (is.character(search)){
    # Either the search field we just created or the given text field ID
    searchEl <- shiny::tagAppendChild(searchEl, shiny::tags$script(type="text/javascript", shiny::HTML(
      paste0("shinyTree.initSearch('",outputId,"','",search,"');"))))
  }
  
  if(!theme %in% c("default","default-dark","proton")) { stop(paste("shinyTree theme, ",theme,", doesn't exist!",sep="")) }
  
  # define theme tags (default, default-dark, or proton)
  theme.tags<-shiny::tags$link(rel = 'stylesheet',
                               type = 'text/css',
                               href = paste('shinyTree/jsTree-3.3.5/themes/',theme,'/style.min.css',sep=""))
  
  shiny::tagList(
    shiny::singleton(shiny::tags$head(
      initResourcePaths(),
      #theme.tags,
      shiny::tags$link(rel = "stylesheet", 
                type = "text/css", 
                href = "shared/font-awesome/css/font-awesome.min.css"),
      shiny::tags$link(rel = "stylesheet",
                type = "text/css",
                href = "shinyTree/shinyTree.css"),
      shiny::tags$script(src = 'shinyTree/jsTree-3.3.5/jstree.min.js'),
      shiny::tags$script(src = 'shinyTree/shinyTree.js')
    )),
    searchEl,
    shiny::div(id=outputId, class="shiny-tree", 
        `data-st-checkbox`=checkbox, 
        `data-st-search`=is.character(search),
        `data-st-dnd`=dragAndDrop,
        `data-st-theme`=theme,
        `data-st-theme-icons`=themeIcons,
        `data-st-theme-dots`=themeDots,
        `data-st-config`=jsonlite::toJSON(config, auto_unbox=TRUE)
        )
  )
}

# hidden
nullToNA <- function(x) {
  x[sapply(x, is.null)] <- NA
  return(x)
}
changenull <- function(x, to = ""){
  ifelse(is.null(x),to,x)
}

#' @importFrom purrr transpose
list2df <- function(x, stringsAsFactors = FALSE) {
  l=transpose(x)
  l=sapply(l, function(c) {
    if(is.list(c)) c=nullToNA(c)
    c=unlist(c, recursive = F, use.names = F)
  }, simplify = FALSE)
  as.data.frame(l, stringsAsFactors = stringsAsFactors)
}

# hidden
insectbraindb_progress <- function (x, max = 100, message = "querying insectbraindb") {
  percent <- x / max * 100
  cat(sprintf('\r|%-50s| ~%d%% %s',
              paste(rep('+', percent / 2), collapse = ''),
              floor(percent), message))
  if (x == max)
    cat('\n')
}

# hidden
FirstLower <- function(x) {
  s <- strsplit(x, " ")[[1]]
  paste(tolower(substring(s, 1,1)), substring(s, 2),
        sep="", collapse=" ")
}

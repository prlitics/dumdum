#' Make Multiple Dummy (Binary) Variables At Once
#'
#' This function allows you to make dummy variables across many variables at once. For example,
#' if you have two variables called sex (with values "male","female","other") and marital status
#'  (with values "single", "married", "divorced", "widowed"), this function creates dummy
#'  variables for both sex and marital status based off of their unique values. This function is
#'  a wrapper of \code{dummify()} that allows multiple variables to be passed in the same function
#'  call. Currently, automatic renaming of variables and manual selection of reference categories
#'  is limited to \code{dummify()}.
#'
#' @param data A dataframe containing the variables to be dummied.
#' @param vars A list of column names or indices. Accepts variables integer, string, and factor values.
#' @param reference If TRUE, it will leave the first value observed across each variable out as a
#' reference category. Defaults to NULL, which leaves no variables as references.
#' @return The inputted dataframe with additional columns containing all of the dummified variables
#' @keywords dummy
#' @seealso \code{\link{dummify}}
#' @examples
#' install.packages("palmerpenguins")
#'
#' penguins<-palmerpenguins::penguins
#'
#' dummify_across(penguins, c("species","island","sex"))
#' dummify_across(penguins, c(1,2,7))
#' dummify_across(penguins, c("species","island","sex"), reference = TRUE)
#'
#' @export


dummify_across<-function(data, vars, reference=NULL){


  if(is.logical(reference)==FALSE & is.null(reference)==FALSE){
    stop("Reference can only be either TRUE, FALSE, or NULL in dummify_across")
  }

  if(length(vars)==1){
    stop("dummify_across should only be used when dummying multiple variables.
         To dummy a single variable, please use dummify() .")
  }
  if(is.double(vars)){
    vars<-as.integer(vars)
  }
  if(!(typeof(vars) %in% c("character", "integer"))){
    stop(paste0("vars is type,", typeof(vars),". Argument `vars` in dummy_across only
                accepts types 'character' and 'integer'."))

  }
  df<-data

  for(i in vars){
    df<-dummify(data = df, var = i, reference = reference)

  }
  return(df)
}

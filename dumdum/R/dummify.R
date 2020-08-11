#' Make Dummy (Binary) Variable from the Values of Another Variable
#'
#' This function allows you to construct a series of dummy variables from the values of a separate variable. E.g., if you have
#' a variable called "race" with the following values: "White","Black","Asian","Native American/Alaskan Native",
#' "Native Hawaiian", and "Other"--this function creates binary variables for each of the values, or however many the user
#' specifies.
#'
#' @param data A dataframe containing the variable to be dummied.
#' @param var A string naming the variable to be dummied or the column index. Accepts variables integer, string, and factor values.
#' @param reference An optional parameter that allows users to set and/or identify reference values with either TRUE, a character list,
#'  or a named list. Defaults to NULL.If TRUE, \code{dummify()} will leave out the first value encountered in the variable. If
#' \code{reference} is a single variable, \code{dummify()} will leave out that variable. If \code{reference} is multiple variables,
#' then \code{dummify()} will leave out all identified variables.
#'
#' @param dumNames An optional parameter that allows users to name the dummy variables they create with \code{dummify()}.
#'  Accepts a character vector or a named list. If passed a character vector, the columns will be renamed in the order of the list.
#'   If \code{reference} is a named list, \code{dummify()} will rename the dummied column where the named value is equal to 1 with the
#'   name passed.
#'
#' @return The inputted dataframe with additional columns containing the dummified variables
#' @keywords dummy
#' @examples
#' dummify(data = iris, var = "Species")
#' dummify(data = iris, var = 5)
#' dummify(data = iris, var = "Species", reference = TRUE)
#' dummify(data = iris, var = "Species", reference = "setosa")
#' dummify(data = iris, var = "Species", reference = c("setosa","virginica"))
#' dummify(data = iris, var = "Species", dumNames = c("BristlePointed","BlueFlag","Virginia"))
#' dummify(data = iris, var = "Species", dumNames = c("BristlePointed" = "setosa",
#' "BlueFlag" = "versicolor","Virginia" = "virginica"))
#' @export
#'



dummify<-function(data, var, reference = NULL, dumNames = NULL){



  ############################
  ## Helper Functions
  ############################
  ############################

  ## Used if users want to specify their own reference category.
  app_test<-function(x){if(!(x %in% vals) & is.logical(x) == FALSE){
    warning(paste0("Specified reference category '",x,"' is not in the values of ", var))
  }}


  ## Most of the work happens here.
  ## dum_construct accepts variable values (x), vector of new column names (y), and the
  ## variable specified for dummying (z), uses paste0 to write a string mimicing an R command
  ## parse to make it an R command, and eval so that it evaluates into the environment with
  ## the data (parent.frame()). If index is TRUE, default naming occurs where the new variable
  ## takes on the form Var_DUM_Value (e.g., race_DUM_Other, edu_DUM_hsgraduate)

  dum_construct<-function(x, y, z, index = TRUE){
    i <- 0
    for (v in x) {
      i <- i + 1
      if(index){
        cmd <- paste0("df$",y[[i]],"_",sub(" ","",v),"<-ifelse(df[",shQuote(z),"]=='",v,"', 1, 0)")
      } else {
        cmd <- paste0("df$",sub(" ","",y[[i]]),"<-ifelse(df[",shQuote(z),"]== '",v,"', 1, 0)")
      }
      eval(parse(text = cmd), envir = parent.frame())
    }
  }

  #############################
  ## Get Var and DataFrame
  ###########################

  var<-var
  df<-data

  ################################



  ###########################################
  ## Check if var and data  are appropriate data types
  ###########################################

  if(is.numeric(var)){
    val<-names(df)[[var]]
    var<-val
  }

  if(length(var)>1){
    stop(paste0("Dummify can only pass 1 variable at a time.
                If you want to dummify multiple variables, use dummify_across()."))
  }

  if( !(typeof(df[[var]]) %in% c("integer", "character"))) {
    stop(paste0("var is type ",typeof(df[[var]]),". ",var," must be of type 'factor', 'integer', or 'character'."))

  }



  if(is.data.frame(df) != TRUE){
    stop(paste0("Data is type ",typeof(data),". dummify() only accepts type dataframe."))
  }
  ############################################



  ###########################################
  ## Converts factor to string for recoding, preserving levels to be retransformed afterwards.
  ###########################################

  if(is.factor(df[[var]])){
    df[[var]]<-as.factor(df[[var]])
    assign(as.character(substitute(.lev.)), levels(df[[var]]), envir = globalenv())
    warning("dummify() converts factor variables to string. Please check to ensure factors are in the desired order")

    df[[var]]<- as.character(df[[var]])

  }
  ############################################




  ############################
  ## Get values of variable
  ###########################

  vals<-unique(df[[var]])

  ###########################


  ######################################
  ## Standard Renaming of Columns after dummying
  ######################################


  col_name_vec <- rep(paste0(var,"_DUM"), length(vals))

  ######################################



  #####################################
  ## Reducing vals to be transformed by reference
  #####################################

  if(is.null(reference) == FALSE){
    if(isTRUE(reference)){
      vals<-vals[-1]
    }
    if(typeof(reference)!= typeof(vals) & is.logical(reference) == FALSE){
      warning(paste0("Ommitted is type ",typeof(reference)," but ",var," is type ",typeof(vals)))}

    if(length(reference>1)){
      sapply(reference, app_test)
      vals<-vals[!(vals %in% reference)]}


  }
  #######################################



  #######################################
  ### Allowing user to rename the dummied variables
  #######################################

  if(is.null(dumNames) == FALSE){
    if(length(dumNames) != length(vals)){
      warning(paste0("Number of new variable names, ", length(dumNames), ", does not equal the number of values specified to be dummified
              from", var,", ",length(vals)))
    }

    ## If user did not pass a named list, use the character vector and name things in the order
    ## of the character list

    if(is.null(names(dumNames))){
      col_name_vec <- dumNames
      if(exists(as.character(substitute(.lev.)))){
        df[[var]]<- factor(df[[var]], levels = .lev.)
        rm(.lev., envir = globalenv())

      }
      dum_construct(x = vals, y = col_name_vec, z = var, index = FALSE)
      return(df)
    }

    ## If user did pass a named list, use the list to rename the variables
    ## if the user's list does not match, warn them and proceed with default renaming

    else  if(is.null(names(dumNames))==FALSE){
      if(all.equal(sort(unname(dumNames)), sort(vals)) != TRUE){
        warning(paste0("Values in dumNames do not match the values of ",var,". Default renaming performed."))
          if(exists(as.character(substitute(.lev.)))){
          df[[var]]<- factor(df[[var]], levels = .lev.)
          rm(.lev., envir = globalenv())

        }
        dum_construct(x = vals, y = col_name_vec, z = var, index = TRUE)
        return(df)

      } else if(all.equal(sort(unname(dumNames)), sort(vals)) == TRUE){
        vals <- unname(dumNames)
        col_name_vec <- names(dumNames)
        if(exists(as.character(substitute(.lev.)))){
          df[[var]]<- factor(df[[var]], levels = .lev.)
          rm(.lev., envir = globalenv())

        }
        dum_construct(x = vals, y = col_name_vec, z = var, index = FALSE)
        return(df)
      }


    }


  }
  ################################################


  if(exists(as.character(substitute(.lev.)))){
    df[[var]]<- factor(df[[var]], levels = .lev.)
    rm(.lev., envir = globalenv())

  }

  dum_construct(x = vals, y = col_name_vec, z = var, index = TRUE)






  return(df)

}

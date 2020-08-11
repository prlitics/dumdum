
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dumdum <img src="https://i.imgur.com/pa4i2JM.png" alt="dumdum_hexagon" width="120px" align ="right"/>

## Make dummy variables easily in R

<!-- badges: start -->

![version](https://img.shields.io/badge/version-v.0.8.5-blue)
![size](https://img.shields.io/github/repo-size/prlitics/dumdum)
![issues](https://img.shields.io/github/issues/prlitics/dumdum)
<!-- badges: end -->

Dummy variables (binary, 0/1 variables) are a frequent part of analyses
in the social sciences. But making them can be an arduous process in
base R, which tends rely on numerous `ifelse()`statements. This can be
especially trying and headache-inducing if you have a variable with
several values (e.g., race, education level, employment status,
political party identification, etc.).

`dumdum` cuts down on the work, gives you the ability to easily rename
the new, dummied variables, and also makes [selecting reference
categories](https://stats.idre.ucla.edu/other/mult-pkg/faq/general/faqwhat-is-dummy-coding/)
simple. It also allows you to make dummies across many variables at
once.

There are currently a few other packages that helps users make dummy
variables such as `ml`, `caret`, `tidymodels`, and `fastdummies`. What
sets `dumdum` apart is that it was designed with social-scientists and
non-machine learning folk in mind. Its functions are flexible and
intuitive. It also requires no package dependencies; all that’s
necessary to have installed are the base R packages\!

## Installation

You can install the latest version from [GitHub](https://github.com/)
with:

``` r
# install.packages("devtools")
devtools::install_github("prlitics/dumdum")
```

or

``` r
# install.packages("remotes")
remotes::install_github("prlitics/dumdum")
```

## Functions

There are two functions in `dumdum`

  - `dummify()` which allows you to make dummy variables from a
    specified dataframe and variable. (This is the main function in
    `dumdum`)
  - `dummify_across()` a wrapper for `dummify()` that lets users dummify
    multiple variables at once.

## Background in-depth look at `dummify()`

  - [`dummify()` examples](#dummify)
  - [`dummify_across` examples](#dummify_across)
  - [Playing nice with pipes](#playing-nice-with-pipes)

`dummify()` has 4 arguments; 2 mandatory and 2 options. The options are
set to `NULL` as default.

``` r
dummify(data, var, reference = NULL, dumNames = NULL)
```

### `data` & `var` requirements

  - Currently, `dummify()` accepts data frame objects in `data`.
  - `var` accepts either the name of the column or the the column index.
  - `dummify` currently accepts integer, factor, and character vectors.

### `reference` and `dumNames` options.

  - `reference` allows you to decide if you want to leave out a
    reference category from your values.
      - If you pass `TRUE`, it will leave out the first value it
        encounters.
      - If you pass the name of a value (say “Adelie”—a penguin
        species), it will leave that value out.
      - If you pass a vector of names (say `Adelie, Gentoo`), it will
        leave out all of the specified values.
  - `dumNames` has `dummify()` rename the variables for you, so you
    don’t have to do it afterwards.
      - The standard naming convention goes `variableName_DUM_Value`. So
        for a column for Adelie penguins it will be
        `species_DUM_Adelie`. All of the Adelie penguins will have a 1
        for this variable and the other penguins will have a 0.
        \*`dumNames` can accept a character list that will rename all
        the columns in the order of the list (``). *`dumNames` can also
        accept a named list so that you don't have to worry about making
        sure the names are in the right order. (``)

## Examples

These examples are going to use the [Palmer
Penguins](https://github.com/allisonhorst/palmerpenguins) dataset
because there are a number of “dummy-able” variables in it. (And, also,
like, penguins\!\!)

``` r
library(dumdum)
penguins<-palmerpenguins::penguins
```

| species | island    | bill\_length\_mm | bill\_depth\_mm | flipper\_length\_mm | body\_mass\_g | sex    | year |
| :------ | :-------- | ---------------: | --------------: | ------------------: | ------------: | :----- | ---: |
| Adelie  | Torgersen |             39.1 |            18.7 |                 181 |          3750 | male   | 2007 |
| Adelie  | Torgersen |             39.5 |            17.4 |                 186 |          3800 | female | 2007 |
| Adelie  | Torgersen |             40.3 |            18.0 |                 195 |          3250 | female | 2007 |
| Adelie  | Torgersen |               NA |              NA |                  NA |            NA | NA     | 2007 |
| Adelie  | Torgersen |             36.7 |            19.3 |                 193 |          3450 | female | 2007 |
| Adelie  | Torgersen |             39.3 |            20.6 |                 190 |          3650 | male   | 2007 |

### `dummify`

Let’s say that you want to make a dummy variable for the penguins’ sex
because you plan to run a regression where you check to see if sex is
predictive of body mass. To make dummy variables out of species, you
could do this with `dummify()`:

``` r
penguins<- palmerpenguins::penguins
penguins_dummied<-dummify(data = penguins, var = "sex")
```

| species | island    | bill\_length\_mm | bill\_depth\_mm | flipper\_length\_mm | body\_mass\_g | sex    | year | sex\_DUM\_male | sex\_DUM\_female | sex\_DUM\_NA |
| :------ | :-------- | ---------------: | --------------: | ------------------: | ------------: | :----- | ---: | -------------: | ---------------: | -----------: |
| Adelie  | Torgersen |             39.1 |            18.7 |                 181 |          3750 | male   | 2007 |              1 |                0 |            0 |
| Adelie  | Torgersen |             39.5 |            17.4 |                 186 |          3800 | female | 2007 |              0 |                1 |            0 |
| Adelie  | Torgersen |             40.3 |            18.0 |                 195 |          3250 | female | 2007 |              0 |                1 |            0 |
| Adelie  | Torgersen |               NA |              NA |                  NA |            NA | NA     | 2007 |             NA |               NA |            1 |
| Adelie  | Torgersen |             36.7 |            19.3 |                 193 |          3450 | female | 2007 |              0 |                1 |            0 |
| Adelie  | Torgersen |             39.3 |            20.6 |                 190 |          3650 | male   | 2007 |              1 |                0 |            0 |

If you wanted to set “male” as the reference category, you could do:

``` r
penguins_dummied<-dummify(data = penguins, var = "sex", reference = "male")
```

| species | island    | bill\_length\_mm | bill\_depth\_mm | flipper\_length\_mm | body\_mass\_g | sex    | year | sex\_DUM\_female | sex\_DUM\_NA |
| :------ | :-------- | ---------------: | --------------: | ------------------: | ------------: | :----- | ---: | ---------------: | -----------: |
| Adelie  | Torgersen |             39.1 |            18.7 |                 181 |          3750 | male   | 2007 |                0 |            0 |
| Adelie  | Torgersen |             39.5 |            17.4 |                 186 |          3800 | female | 2007 |                1 |            0 |
| Adelie  | Torgersen |             40.3 |            18.0 |                 195 |          3250 | female | 2007 |                1 |            0 |
| Adelie  | Torgersen |               NA |              NA |                  NA |            NA | NA     | 2007 |               NA |            1 |
| Adelie  | Torgersen |             36.7 |            19.3 |                 193 |          3450 | female | 2007 |                1 |            0 |
| Adelie  | Torgersen |             39.3 |            20.6 |                 190 |          3650 | male   | 2007 |                0 |            0 |

The default naming convention is to make sure that the user knows what
the `1` is in reference to in that column. You can also rename the
columns.

``` r
penguins_dummied<-dummify(data = penguins, var = "sex", reference = "male", dumNames = c("f","unknown"))
```

| species | island    | bill\_length\_mm | bill\_depth\_mm | flipper\_length\_mm | body\_mass\_g | sex    | year |  f | unknown |
| :------ | :-------- | ---------------: | --------------: | ------------------: | ------------: | :----- | ---: | -: | ------: |
| Adelie  | Torgersen |             39.1 |            18.7 |                 181 |          3750 | male   | 2007 |  0 |       0 |
| Adelie  | Torgersen |             39.5 |            17.4 |                 186 |          3800 | female | 2007 |  1 |       0 |
| Adelie  | Torgersen |             40.3 |            18.0 |                 195 |          3250 | female | 2007 |  1 |       0 |
| Adelie  | Torgersen |               NA |              NA |                  NA |            NA | NA     | 2007 | NA |       1 |
| Adelie  | Torgersen |             36.7 |            19.3 |                 193 |          3450 | female | 2007 |  1 |       0 |
| Adelie  | Torgersen |             39.3 |            20.6 |                 190 |          3650 | male   | 2007 |  0 |       0 |

If you didn’t want to worry about putting the list of column names in
the right order:

``` r
penguins_dummied<-dummify(data = penguins, var = "sex", reference = "male", dumNames = c("f"="female","unknown"=NA))
```

| species | island    | bill\_length\_mm | bill\_depth\_mm | flipper\_length\_mm | body\_mass\_g | sex    | year |  f | unknown |
| :------ | :-------- | ---------------: | --------------: | ------------------: | ------------: | :----- | ---: | -: | ------: |
| Adelie  | Torgersen |             39.1 |            18.7 |                 181 |          3750 | male   | 2007 |  0 |       0 |
| Adelie  | Torgersen |             39.5 |            17.4 |                 186 |          3800 | female | 2007 |  1 |       0 |
| Adelie  | Torgersen |             40.3 |            18.0 |                 195 |          3250 | female | 2007 |  1 |       0 |
| Adelie  | Torgersen |               NA |              NA |                  NA |            NA | NA     | 2007 | NA |       1 |
| Adelie  | Torgersen |             36.7 |            19.3 |                 193 |          3450 | female | 2007 |  1 |       0 |
| Adelie  | Torgersen |             39.3 |            20.6 |                 190 |          3650 | male   | 2007 |  0 |       0 |

### `dummify_across`

Let’s say that there are multiple variables that you want to dummy
across. In the case of the penguins, you might want to dummy species, as
well as the island and sex. You can do so with `dummify_across()`.

`dummify_across()` is a wrapper for `dummify()` that allows you to pass
multiple variables at once. Like `dummify()`, you specify a data frame
object and you specify a set of variables (`vars`) that you want to be
dummified. These can either be names or column indices.

``` r
penguins_dummied<-dummify_across(data = penguins, vars = c("sex","species","island"))
```

| species | island    | bill\_length\_mm | bill\_depth\_mm | flipper\_length\_mm | body\_mass\_g | sex    | year | sex\_DUM\_male | sex\_DUM\_female | sex\_DUM\_NA | species\_DUM\_Adelie | species\_DUM\_Gentoo | species\_DUM\_Chinstrap | island\_DUM\_Torgersen | island\_DUM\_Biscoe | island\_DUM\_Dream |
| :------ | :-------- | ---------------: | --------------: | ------------------: | ------------: | :----- | ---: | -------------: | ---------------: | -----------: | -------------------: | -------------------: | ----------------------: | ---------------------: | ------------------: | -----------------: |
| Adelie  | Torgersen |             39.1 |            18.7 |                 181 |          3750 | male   | 2007 |              1 |                0 |            0 |                    1 |                    0 |                       0 |                      1 |                   0 |                  0 |
| Adelie  | Torgersen |             39.5 |            17.4 |                 186 |          3800 | female | 2007 |              0 |                1 |            0 |                    1 |                    0 |                       0 |                      1 |                   0 |                  0 |
| Adelie  | Torgersen |             40.3 |            18.0 |                 195 |          3250 | female | 2007 |              0 |                1 |            0 |                    1 |                    0 |                       0 |                      1 |                   0 |                  0 |
| Adelie  | Torgersen |               NA |              NA |                  NA |            NA | NA     | 2007 |             NA |               NA |            1 |                    1 |                    0 |                       0 |                      1 |                   0 |                  0 |
| Adelie  | Torgersen |             36.7 |            19.3 |                 193 |          3450 | female | 2007 |              0 |                1 |            0 |                    1 |                    0 |                       0 |                      1 |                   0 |                  0 |
| Adelie  | Torgersen |             39.3 |            20.6 |                 190 |          3650 | male   | 2007 |              1 |                0 |            0 |                    1 |                    0 |                       0 |                      1 |                   0 |                  0 |

You can also pass along whether or not you want `dummify_across()` to
leave out a reference column for the variables you selected:

``` r
penguins_dummied<-dummify_across(data = penguins, vars = c("sex","species","island"), reference = TRUE)
```

| species | island    | bill\_length\_mm | bill\_depth\_mm | flipper\_length\_mm | body\_mass\_g | sex    | year | sex\_DUM\_female | sex\_DUM\_NA | species\_DUM\_Gentoo | species\_DUM\_Chinstrap | island\_DUM\_Biscoe | island\_DUM\_Dream |
| :------ | :-------- | ---------------: | --------------: | ------------------: | ------------: | :----- | ---: | ---------------: | -----------: | -------------------: | ----------------------: | ------------------: | -----------------: |
| Adelie  | Torgersen |             39.1 |            18.7 |                 181 |          3750 | male   | 2007 |                0 |            0 |                    0 |                       0 |                   0 |                  0 |
| Adelie  | Torgersen |             39.5 |            17.4 |                 186 |          3800 | female | 2007 |                1 |            0 |                    0 |                       0 |                   0 |                  0 |
| Adelie  | Torgersen |             40.3 |            18.0 |                 195 |          3250 | female | 2007 |                1 |            0 |                    0 |                       0 |                   0 |                  0 |
| Adelie  | Torgersen |               NA |              NA |                  NA |            NA | NA     | 2007 |               NA |            1 |                    0 |                       0 |                   0 |                  0 |
| Adelie  | Torgersen |             36.7 |            19.3 |                 193 |          3450 | female | 2007 |                1 |            0 |                    0 |                       0 |                   0 |                  0 |
| Adelie  | Torgersen |             39.3 |            20.6 |                 190 |          3650 | male   | 2007 |                0 |            0 |                    0 |                       0 |                   0 |                  0 |

Currently, `dummify_across()` will only leave out the first encountered
variable as a reference. Future updates to the package will allow you to
specify which variables you want to have reference categories for–as
well as the values for those references.

### Playing nice with pipes

I personally am a huge fan of the
[`tidyverse`](https://www.tidyverse.org/); it’s what allowed me to get
my feet wet with R before I could truly dive into it. I know a lot of
potential `dumdum` users would also use the `tidyverse`, so it was
important to me that `dumdum` functions were *pipe*-able.

``` r
library(magrittr)
pen_df <- penguins %>%
  dummify("sex")
```

| species | island    | bill\_length\_mm | bill\_depth\_mm | flipper\_length\_mm | body\_mass\_g | sex    | year | sex\_DUM\_male | sex\_DUM\_female | sex\_DUM\_NA |
| :------ | :-------- | ---------------: | --------------: | ------------------: | ------------: | :----- | ---: | -------------: | ---------------: | -----------: |
| Adelie  | Torgersen |             39.1 |            18.7 |                 181 |          3750 | male   | 2007 |              1 |                0 |            0 |
| Adelie  | Torgersen |             39.5 |            17.4 |                 186 |          3800 | female | 2007 |              0 |                1 |            0 |
| Adelie  | Torgersen |             40.3 |            18.0 |                 195 |          3250 | female | 2007 |              0 |                1 |            0 |
| Adelie  | Torgersen |               NA |              NA |                  NA |            NA | NA     | 2007 |             NA |               NA |            1 |
| Adelie  | Torgersen |             36.7 |            19.3 |                 193 |          3450 | female | 2007 |              0 |                1 |            0 |
| Adelie  | Torgersen |             39.3 |            20.6 |                 190 |          3650 | male   | 2007 |              1 |                0 |            0 |

``` r
pen_df <- penguins %>%
  dummify_across(c("sex","island","species"))
```

| species | island    | bill\_length\_mm | bill\_depth\_mm | flipper\_length\_mm | body\_mass\_g | sex    | year | sex\_DUM\_male | sex\_DUM\_female | sex\_DUM\_NA | island\_DUM\_Torgersen | island\_DUM\_Biscoe | island\_DUM\_Dream | species\_DUM\_Adelie | species\_DUM\_Gentoo | species\_DUM\_Chinstrap |
| :------ | :-------- | ---------------: | --------------: | ------------------: | ------------: | :----- | ---: | -------------: | ---------------: | -----------: | ---------------------: | ------------------: | -----------------: | -------------------: | -------------------: | ----------------------: |
| Adelie  | Torgersen |             39.1 |            18.7 |                 181 |          3750 | male   | 2007 |              1 |                0 |            0 |                      1 |                   0 |                  0 |                    1 |                    0 |                       0 |
| Adelie  | Torgersen |             39.5 |            17.4 |                 186 |          3800 | female | 2007 |              0 |                1 |            0 |                      1 |                   0 |                  0 |                    1 |                    0 |                       0 |
| Adelie  | Torgersen |             40.3 |            18.0 |                 195 |          3250 | female | 2007 |              0 |                1 |            0 |                      1 |                   0 |                  0 |                    1 |                    0 |                       0 |
| Adelie  | Torgersen |               NA |              NA |                  NA |            NA | NA     | 2007 |             NA |               NA |            1 |                      1 |                   0 |                  0 |                    1 |                    0 |                       0 |
| Adelie  | Torgersen |             36.7 |            19.3 |                 193 |          3450 | female | 2007 |              0 |                1 |            0 |                      1 |                   0 |                  0 |                    1 |                    0 |                       0 |
| Adelie  | Torgersen |             39.3 |            20.6 |                 190 |          3650 | male   | 2007 |              1 |                0 |            0 |                      1 |                   0 |                  0 |                    1 |                    0 |                       0 |

## Bugs or suggestions

If you have any bugs or suggestions, [let me
know\!](https://github.com/prlitics/dumdum/issues) Always happy for
constructive feedback.

## Acknowledgements

Huge thanks to [Sabrina Marasa](https://twitter.com/sabrina_marasa), who
tested the package on the Mac version of R.

## License

This function is distributed under a [MIT
license](https://choosealicense.com/licenses/mit/).

## Citation

    #> 
    #> To cite dumdum in publications use:
    #> 
    #>   Licari, P. R. (2020). dumdum: Make dummy variables easily in R.
    #>   version 0.8.0.  https://github.com/prlitics/dumdum/.
    #> 
    #> A BibTeX entry for LaTeX users is
    #> 
    #>   @Manual{,
    #>     title = {dumdum: Make dummy variables easily in R},
    #>     author = {Peter Licari},
    #>     year = {2020},
    #>     url = {https://github.com/prlitics/dumdum},
    #>     note = {version 0.8.0},
    #>   }

## References

**Data & packages used in this readme.**

  - Horst AM, Hill AP, Gorman KB (2020). palmerpenguins: Palmer
    Archipelago (Antarctica) penguin data. R package version 0.1.0.
    <https://allisonhorst.github.io/palmerpenguins/>. doi:
    10.5281/zenodo.3960218.

  - Stefan Milton Bache and Hadley Wickham (2014). magrittr: A
    Forward-Pipe Operator for R. R package version 1.5.
    <https://CRAN.R-project.org/package=magrittr>

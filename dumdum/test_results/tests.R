###################
#These should work:
##################

test1 <- dummify(iris,"Species")
test2 <- dummify(iris, 5)
test4 <- identical(test2, test1)
test3 <- dummify(iris, "Species", reference = "setosa")
test4 <- dummify(iris, "Species", dumNames = c("set","versi", "virgina"))
test5 <- dummify(iris, "Species", dumNames = c("set" = "setosa","veris" = "versicolor", "vriginia"= "virginica"))

# Setting up the data for tests 6 & 7
ibis<-iris
ibis$Species<-as.integer(ibis$Species)
iris$Species<-as.character(iris$Species)


test6 <- dummify(iris,"Species")
test7 <- test1 <- dummify(iris,"Species")

#Setting up the data for tests 8 & 9
mtcars$cyl<-as.integer(mtcars$cyl)
mtcars$gear <- as.factor(mtcars$gear)
mtcars$carb <- as.character(mtcars$carb)

test8<-dummify_across(mtcars, c("cyl","gear","carb"))
test9<-dummify_across(mtcars, c("cyl","gear","carb"), reference = T)

###################
#These should fail:
##################

test10 <- dummify(mtcars, c("cyl","gear","carb"))
test11 <- dummify(mtcars, "drat")
test12 <- dummify(mtcars, cyl)
test13 <- dummify_across(mtcars, c("cyl","gear","carb"), reference = 7)
test14 <- dummify_across(mtcars, "cyl", reference = 7)


# Just so I know how far back I can claim compatibility :)
R.Version()

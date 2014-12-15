## Put comments here that give an overall description of what your
## functions do

## Write a short comment describing this function

makeCacheMatrix <- function(x = matrix()) {
        m <- NULL
        set <- function(y) {
                x <<- y
                m <<- NULL
        }
        get <- function() x                    ## get the input matrix
        setinv <- function(solve) m <<- solve  ## compute the inverse of the matrix x
        getinv <- function() m                 ## save the inverse matrix      
        list(get = get, set = set, 
             setinverse = setinv, getinverse = getinv)
}


## Write a short comment describing this function

cacheSolve <- function(x, ...) {
        ## Return a matrix that is the inverse of 'x'
        m <- x$getinv()                       ## check whether the inverse has been done
        if(!is.null(m)) {
                message("getting cached data")
                return(m)
        }
        data <- x$get()                      ## if not, calculate the inverse matrix
        m <- solve(data)
        x$setinv(m)
        m
}

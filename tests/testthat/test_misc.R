context('miscellaneous')

# miscellaneous tests 

if (require(rstanarm)) {
  
  set.seed(1235)
  n <- 40
  nv <- 5
  x <- matrix(rnorm(n*nv, 0, 1), n, nv)
  b <- runif(nv)-0.5
  dis <- runif(1, 1, 2)
  weights <- sample(1:4, n, replace = T)
  offset <- rnorm(n)
  chains <- 2
  seed <- 1235
  iter <- 500
  source(testthat::test_path('helpers', 'SW.R'))
  
  
  f_gauss <- gaussian()
  df_gauss <- data.frame(y = rnorm(n, f_gauss$linkinv(x%*%b), dis), x = x)
  f_binom <- binomial()
  df_binom <- data.frame(y = rbinom(n, weights, f_binom$linkinv(x%*%b)), x = x)
  f_poiss <- poisson()
  df_poiss <- data.frame(y = rpois(n, f_poiss$linkinv(x%*%b)), x = x)
  
  SW(
    fit_gauss <- stan_glm(y ~ x, family = f_gauss, data = df_gauss, QR = T,
                          weights = weights, offset = offset,
                          chains = chains, seed = seed, iter = iter, 
                          refresh=0)
  )
  SW(
    fit_binom <- stan_glm(cbind(y, weights-y) ~ x, family = f_binom, QR = T,
                          data = df_binom, weights = weights, offset = offset,
                          chains = chains, seed = seed, iter = iter, refresh=0)
  )
  SW(
    fit_poiss <- stan_glm(y ~ x, family = f_poiss, data = df_poiss, QR = T,
                          weights = weights, offset = offset,
                          chains = chains, seed = seed, iter = iter, refresh=0)
  )
  fit_list <- list(gauss = fit_gauss, binom = fit_binom, poiss = fit_poiss)
  
  
  
  
  test_that("check that the main function calls do not return the same RNG state every time", {
    
    s <- 5 
    
    for (seed in c(130927, NULL)) {
      for (i in seq_along(fit_list)) {
        
        fit <- fit_list[[i]]
        
        # varsel
        foo <- varsel(fit, seed=seed)
        r1 <- rnorm(s)
        foo <- varsel(fit, seed=seed)
        r2 <- rnorm(s)
        expect_true(any(r1!=r2))
        
        # cv_varsel
        SW(foo <- cv_varsel(fit, seed=seed))
        r1 <- rnorm(s)
        SW(foo <- cv_varsel(fit, seed=seed))
        r2 <- rnorm(s)
        expect_true(any(r1!=r2))
        
        # project
        vind <- c(1,2)
        foo <- project(fit, vind=vind, ns = 100, seed=seed)
        r1 <- rnorm(s)
        foo <- project(fit, vind=vind, ns = 100, seed=seed)
        r2 <- rnorm(s)
        expect_true(any(r1!=r2))
        
        # proj_linpred
        vind <- c(1,3)
        foo <- proj_linpred(fit, x[,vind], vind=vind, seed=seed)
        r1 <- rnorm(s)
        foo <- proj_linpred(fit, x[,vind], vind=vind, seed=seed)
        r2 <- rnorm(s)
        expect_true(any(r1!=r2))
        
        # proj_predict
        vind <- c(1,3)
        foo <- proj_predict(fit, x[,vind], vind=vind, seed=seed)
        r1 <- rnorm(s)
        foo <- proj_predict(fit, x[,vind], vind=vind, seed=seed)
        r2 <- rnorm(s)
        expect_true(any(r1!=r2))
      }
    }
    
  })
  
  
  
  test_that("check that providing seed has the expected effect", {
    
    for (seed in c(130927, 1524542)) {
      for (i in seq_along(fit_list)) {
        
        fit <- fit_list[[i]]
        
        # varsel
        foo <- varsel(fit, seed=seed)
        bar <- varsel(fit, seed=seed)
        expect_equal(foo, bar)
        
        # cv_varsel
        SW(foo <- cv_varsel(fit, seed=seed))
        SW(bar <- cv_varsel(fit, seed=seed))
        expect_equal(foo, bar)
        
        # project
        vind <- c(1,2)
        foo <- project(fit, vind=vind, nc = 10, seed=seed)
        bar <- project(fit, vind=vind, nc = 10, seed=seed)
        expect_equal(foo, bar)
        
        
        # proj_linpred
        vind <- c(1,3)
        foo <- proj_linpred(fit, x[,vind], vind=vind, seed=seed)
        bar <- proj_linpred(fit, x[,vind], vind=vind, seed=seed)
        expect_equal(foo, bar)
        
        # proj_predict
        vind <- c(1,3)
        foo <- proj_predict(fit, x[,vind], vind=vind, seed=seed)
        bar <- proj_predict(fit, x[,vind], vind=vind, seed=seed)
        expect_equal(foo, bar)
      }
    }
    
  })
  
}
  
  
  
  
  

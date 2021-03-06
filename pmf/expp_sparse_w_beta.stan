data {
  int<lower=0> U;
  int<lower=0> I;
  int<lower=0> K;

  int<lower=0> number_entries;
  int<lower=0> user_index[number_entries];
  int<lower=0> item_index[number_entries];
  int<lower=0,upper=1> rating[number_entries];

  real<lower=0> lambda;
  real<lower=0> beta_a;  
  real<lower=0> beta_b;    
}

transformed data{
  real log1;
  log1 <- log(1.0);
}

parameters {
  matrix<lower=0>[U,K] theta; // user preferences
  matrix<lower=0>[I,K] beta;  // item attributes
  vector<lower=0,upper=1>[U] w;   
}

model {
  # temporary variables
  row_vector[K] thetasum;
  row_vector[K] betasum;

  for (k in 1:K) {
    thetasum[k] <- 0; betasum[k] <- 0;
  }

  # priors
  w ~ beta(beta_a,beta_b);
  to_vector(theta) ~ exponential(lambda);
  to_vector(beta) ~ exponential(lambda);

  # likelihood (see Eq (3) of GopalanHofmanBlei 2013)
  for (entry in 1:number_entries) {
    target +=
      w[user_index[entry]] * (
      log(dot_product(theta[user_index[entry]],beta[item_index[entry]]))
      -
      log1 );
  }

  for (u in 1:U)
    thetasum <- thetasum + theta[u] * w[u];
  for (i in 1:I)
    betasum <- betasum + beta[i];

  target += -1*dot_product(thetasum,betasum);
}

var a_1, y, pi, i, n;
varexo eps;

parameters beta, sigma, theta, rho, psi_phi, psi_y, sigma_a, rho_a, kay;

beta = 0.99;
sigma = 1;
theta = 0.75;
rho = 0.01005;
psi_phi = 1.5;
psi_y = 0.6;
sigma_a = 1;
rho_a = 0.9;
kay = 0.064375;

model;
//shock
a_1 = rho_a * a_1(-1) + eps;

//interest rate
i = rho + psi_phi*pi;

// employment
n = a_1 - y;

//inflation
pi= beta*pi(+1) + kay*(y - psi_y*a_1);

//output
y = -(1/sigma)*(i + pi(+1) - rho) + y(+1);

end;

steady;
check;

shocks;
var eps=sigma_a;

end;

stoch_simul(dr_algo=0, order =1, periods=1000, irf = 80,graph_format = eps) a_1 pi y i n;

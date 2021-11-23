* Leon Boveland, Marius Gruenewald, Daniel Prosi: Econometrics 2 PS1

cd "C:\Users\Daniel\Documents\Studium\EUI\Year1\Microeconometrics\Problem Sets\PS1"

clear

use cameron.dta


* reshape data
reshape long lwage educ black hisp expersq exper married union, i(nr) j(year)

* panel set
xtset nr year

* check whether panel has been correctly set
xtsum

global RHS educ i.black i.hisp exper expersq i.married i.union
global RHS_fe expersq i.married i.union

* pooled regression
reg lwage $RHS i.year
eststo pooled

reg lwage $RHS i.year, vce(cluster nr)
eststo pooled_vce

* LSDV regression (equivalent to fe)
* note that time-invariant variables (black, hisp, ) are incorrectly retained in this setting and instead individual f.e. for 3 individuals are dropped. We do not rely on this specification.
qui eststo LSDV: reg lwage $RHS i.nr i.year
reg lwage $RHS i.nr i.year, vce(cluster nr)
eststo LSDV_vce

* RE regression
qui eststo RE: xtreg lwage $RHS i.year, re
xtreg lwage $RHS i.year, re vce(cluster nr)
eststo RE_vce

* FE estimation
qui eststo FE: xtreg lwage $RHS_fe i.year, fe
xtreg lwage $RHS_fe i.year, fe vce(cluster nr)
eststo FE_vce
local RSS_r = e(rss)
local k_res = e(rank)

* conduct the hausman test (Note that the test is run comparing only variables present in both regressions but using the estimates obtained from the full specification
* the intuition would be that for fe the time-invariant variation in the independent variables is differenced out whereas in re the same effect is achieved by using only the variance not explained by the included time-invariant variables using the partialling 
qui{
xtreg lwage $RHS i.year, re 
eststo RE2

xtreg lwage $RHS i.year, fe 
eststo FE2
}

* we need to specify that we are only having 3 degrees of freedom as time variant but individual invariant 
hausman FE2 RE2, df(3)


* FD (noconst means constant differenced out. Leaving the constant in effectively controls for the (linear) time fixed effects)
* note that year fixed effects and the effect of experience is not separable (both are part of the intercept)!!! -> no clear interpretation
* under the assumption that there is no annual trend, we can interpret the intercept as the coefficient on experience
qui eststo FD: reg d.lwage d.exper d.expersq d.married d.union i.year, noconst
reg d.lwage d.exper d.expersq d.married d.union i.year, vce(cluster nr) noconst
eststo FD_vce

* check for autocorrelation in the errors
predict resid, residuals
reg resid l.resid
eststo autocorr
drop resid

* increased returns to education
qui eststo FEeduc: xtreg lwage $RHS_fe c.educ#i.year i.year, fe
xtreg lwage $RHS_fe c.educ#i.year i.year, fe vce(cluster nr)
eststo FEeduc_vce
local RSS_ur = e(rss)
local k2 = e(rank) - `k_res' 
local k_ur = e(rank)
local n_clust = e(N_g)
local Nn = e(N)
* degrees of freedom
local Ddf = `Nn' - `k_ur' - `n_clust'


disp "`k2'"
disp "`Nn'"
disp "`Ddf''"

* conduct joint F-test of significance of interation terms
* using formula from Ichino's slides on hypothesis testing slide 27
local Fstat = ((`RSS_r' - `RSS_ur') / `k2') / (`RSS_ur'/`Ddf')

qui{ 
gen temp = Ftail(`k2', `Ddf', `Fstat')
sum temp
local Fval = r(min)
drop temp
}
* this is the F-statistic
disp "`Fstat'"
* this is the p-value (82%)
disp "`Fval'"


* lead union 
qui eststo FEunion: xtreg lwage $RHS_fe i.year f.union, fe
xtreg lwage $RHS_fe i.year f.union, fe vce(cluster nr)
eststo FEunion_vce

* generate output without White errors
estout pooled RE FE FD FEeduc FEunion using "Regressions/LSDV.tex", ///
cells(b(star fmt(3)) se(par fmt(3))) starlevel(* 0.10 ** 0.05 *** 0.01) style(tex) replace substitute(\eq $ D.exper exper D.expersq expersq D.married married D.union union 1.black black 1.union union 1.hisp hisp 1.married married 1980.year#c.educ 1980Xeduc 1981.year#c.educ 1981Xeduc 1982.year#c.educ 1982Xeduc 1983.year#c.educ 1983Xeduc 1984.year#c.educ 1984Xeduc 1985.year#c.educ 1985Xeduc 1986.year#c.educ 1986Xeduc) ///
prehead(\begin{tabular}[h!]{l*{@M}{r}} \hline \hline) ///
posthead(\hline &&&&&&  \\) ///
prefoot(\hline &&&&&&  \\ ) ///
postfoot( \end{tabular} ) ///
stats(r2_o r2 F p, fmt(2 2 2 2) labels("R\eq^2\eq" "within-R\eq^2\eq" "F-statistic" "p")) ///
keep(educ 1.black 1.hisp exper D.exper expersq D.expersq 1.married D.married 1.union D.union F.union 1980.year#c.educ 1981.year#c.educ 1982.year#c.educ 1983.year#c.educ 1984.year#c.educ 1985.year#c.educ 1986.year#c.educ) ///
legend mlabels(pooled RE FE FD FE FE) numbers

* with White errors
estout pooled RE_vce FE_vce FD_vce FEeduc FEunion_vce using "Regressions/LSDV_vce.tex", ///
cells(b(star fmt(3)) se(par fmt(3))) starlevel(* 0.10 ** 0.05 *** 0.01) style(tex) replace substitute(\eq $ D.exper exper D.expersq expersq D.married married D.union union 1.black black 1.union union 1.hisp hisp 1.married married 1980.year#c.educ 1980Xeduc 1981.year#c.educ 1981Xeduc 1982.year#c.educ 1982Xeduc 1983.year#c.educ 1983Xeduc 1984.year#c.educ 1984Xeduc 1985.year#c.educ 1985Xeduc 1986.year#c.educ 1986Xeduc) ///
prehead(\begin{tabular}[h!]{l*{@M}{r}} \hline \hline) ///
posthead(\hline &&&&&&  \\) ///
prefoot(\hline &&&&&&  \\ ) ///
postfoot( \end{tabular} ) ///
stats(r2_o r2 F p, fmt(2 2 2 2) labels("R\eq^2\eq" "within-R\eq^2\eq" "F-statistic" "p")) ///
keep(educ 1.black 1.hisp exper D.exper expersq D.expersq 1.married D.married 1.union D.union F.union 1980.year#c.educ 1981.year#c.educ 1982.year#c.educ 1983.year#c.educ 1984.year#c.educ 1985.year#c.educ 1986.year#c.educ) ///
 ///
legend mlabels(pooled RE FE FD FE FE) numbers

* AR(1) output
estout autocorr using "Regressions/autocorr.tex", ///
cells(b(star fmt(3)) se(par fmt(3))) starlevel(* 0.10 ** 0.05 *** 0.01) style(tex) replace ///
prehead(\begin{tabular}[h!]{l*{@M}{r}} \hline \hline) ///
posthead(\hline &  \\) keep(L.resid) ///
prefoot(\hline & \\ ) ///
postfoot( \end{tabular} ) ///
legend mlabels(AR1) numbers
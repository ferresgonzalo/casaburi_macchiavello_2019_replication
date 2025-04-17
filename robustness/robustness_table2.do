# d cr
clear
set more off
set varabbrev on
set mem 200m
cap log close
# d ;
		
		*Set directory;
			cd "..";
			
		*Locals;
			local date 180719;

	
	
	*****************;
	*ROBUSTNESS FOR TABLE 2: SUPPLY EXPERIMENTS;
	*****************;
	
	* we run regressions in Table 2 clustering standard errors by farmer instead of using farmer fixed effects;
	
		use data/data_supplyexp, clear;
		replace non_guaranteed=1 if inlist(g,7);
		
		foreach y in monthly_sales any_monthly_sale {;
			dis "**************";
			dis "Outcome: `y'";
			dis "**************";
			
						
			*Preliminary: tab mean outcome by game;
				count;
				tab g, summarize(`y');
		
			*1. Basic trader analysis: guaranteed vs. non-guaranteed payments;
				estimates clear;
				*1. only g1 vs g2;
					eststo: reg `y' non_guaranteed if inlist(g,1,2), vce(cluster sid); 
					quietly sum `y' if g==1;
					estadd local y_mean_round = string(r(mean), "%9.3f");										
				
				*2. only g3 vs g4;
					eststo: reg `y' non_guaranteed if inlist(g,3,4), vce(cluster sid); 
					quietly sum `y' if g==3;
					estadd local y_mean_round = string(r(mean), "%9.3f");										

					
				*3. only g5 vs g6;
					eststo: reg `y' non_guaranteed if inlist(g,5,6), vce(cluster sid);
					quietly sum `y' if g==5;
					estadd local y_mean_round = string(r(mean), "%9.3f");										

					
				*4.  games g1-g6;	
					eststo: reg `y' non_guaranteed p50 p60 if inlist(g,1,2,3,4,5,6), vce(cluster sid); 
					quietly sum `y' if inlist(g,1,3,5);
					estadd local y_mean_round = string(r(mean), "%9.3f");										

					
				*5.	price*non-guaranteed;
					eststo: reg `y' non_guaranteed p50 p50_non_guaranteed 
							p60 p60_non_guaranteed  if inlist(g,1,2,3,4,5,6), vce(cluster sid); 
					quietly sum `y' if inlist(g,1,3,5);
					estadd local y_mean_round = string(r(mean), "%9.3f");										

				*6. trader saving constraints?;				
					eststo: reg `y' non_guaranteed no_saving_constraints if inlist(g,3,4,7), vce(cluster sid); 
					test non_guaranteed=no_saving_constraints;
					quietly sum `y' if inlist(g,3);
					estadd local y_mean_round = string(r(mean), "%9.3f");										
					
				*ESttab;
					local coef_list non_guaranteed p50 p50_non_guaranteed p60 p60_non_guaranteed no_saving_constraints;
					esttab using "robustness/tab_SE_`y'_`date'.tex", 					
					keep(`coef_list')
					order(`coef_list')
					mgroups("G1,2" "G3,4" "G5,6" "G1-6" "G4,7" , pattern(1  1 1  1 0 1   )
							prefix(\multicolumn{@span}{c}{) suffix(})
							span erepeat(\cmidrule(lr){@span}) )
					replace br se  label star(* 0.10 ** 0.05 *** 0.01) obslast nomtitles  compress longtable 	
					b(%9.3f) se(%9.3f) 
					scalars("y_mean_round Mean Y Baseline Group") 
					nonotes 
					nogaps				
					title(Supply Experiments \label{tab:lif}) ;	
			
		};
		

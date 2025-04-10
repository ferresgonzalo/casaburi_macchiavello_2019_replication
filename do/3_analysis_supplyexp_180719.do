# d cr
clear
set more off
set mem 200m
cap log close
# d ;
		
		*Set directory;
			local j 0;
			foreach path in "C:\Users\lcasaburi\Dropbox\dairy_replication_AER"{;
				capture cd "`path'";
				if _rc == 0{; 
					cd `path';
				};	
			};
			
		*Locals;
			local date 180719;
			
		

	*****************;
	*FIGURE 4: SUPPLY EXPERIMENTS;
	*****************;
		local j=0;
		foreach y in any_monthly_sale monthly_sales{;
			local j=`j'+1;
			use data/data_supplyexp,  clear;
			forvalues g=1/7{;
				sum `y' if g==`g';
				local m_g`g'=r(mean);
			};
			
			clear;
			set obs 7;
			gen mean=.;
			gen g=_n;
			forvalues g=1/7{;
				replace mean=`m_g`g'' if g==`g';
			};
			gen nonguaranteed=0;
			replace nonguaranteed=1 if inlist(g,2,4,6);
			replace nonguaranteed=2 if inlist(g,7);
			label define nong 0 "{sub:.}" 1 "{sub:.}" 2 "{sub:.}" ;
			label value nonguaranteed nong;
			gen price=40;
			replace price=50 if inlist(g,3,4,7);
			replace price=60 if inlist(g,5,6);	
			label define p 40 "Monthly Price=40" 50"Monthly Price=50" 60"Monthly Price=60";
			label value price p;			
			separate mean, by(nonguaranteed>=1);
			separate mean1, by(nonguaranteed>1);
			des mean*, fu;
			if "`y'"=="any_monthly_sale"{;
				local legend legend(off);
				local ytitle ;
				local title Panel A: Any Sale for Monthly Payments;
			};
			if "`y'"=="monthly_sales"{;
				local legend legend(label(1 "Guaranteed ({bf:G})") label(2 "Non-Guaranteed ({bf:NG})") 
				label(3 "Non-Guaranteed; Monthly Payment to Trader ({bf:NG{subscript:nc}})")) ;
				local ytitle liters;
				local title Panel B: Liters Sold for Monthly Payments;
			};
			graph bar (asis) mean0 mean10 mean11, 
				over(nonguaranteed) over(price) nofill 
				ytitle(`ytitle')  title(`title') graphregion(color(white)) bgcolor(white) asyvars
				graphregion(color(white)) bgcolor(white)
				bar (1, color(gs13) ) bar (2, color(gs9)) bar (3, color(gs5))
				`legend';
			graph save "out/g`j'.gph", replace	;					
		};	
		graph combine "out/g1.gph" "out/g2.gph", title(Supply Experiments) subtitle((N=55)) graphregion(color(white))  col(1);
		erase "out/g1.gph" ;
		erase "out/g2.gph";
		graph export "out/fig_SE_`date'.eps", replace;

	
	
	
	*****************;
	*TABLE 2: SUPPLY EXPERIMENTS;
	*****************;
	
		use data/data_supplyexp,  clear;
		replace non_guaranteed=1 if inlist(g,7);
		
		foreach y in  monthly_sales any_monthly_sale{;
			dis "**************";
			dis "Outcome: `y'";
			dis "**************";
			
						
			*Preliminary: tab mean outcome by game;
				count;
				tab g, summarize(`y');
		
			*1. Basic trader analysis: guaranteed vs. non-guaranteed payments;
				estimates clear;
				*1. only g1 vs g2;
					eststo: xi: xtreg `y' non_guaranteed  if inlist(g,1,2) , fe ; 
					quietly sum `y' if g==1;
					estadd local y_mean_round = string(r(mean), "%9.3f");										
				
				*2. only g3 vs g4;
					eststo: xi: xtreg `y' non_guaranteed  if inlist(g,3,4), fe ; 
					quietly sum `y' if g==3;
					estadd local y_mean_round = string(r(mean), "%9.3f");										

					
				*3. only g5 vs g6;
					eststo: xi: xtreg `y' non_guaranteed  if inlist(g,5,6) , fe ;
					quietly sum `y' if g==5;
					estadd local y_mean_round = string(r(mean), "%9.3f");										

					
				*4.  games g1-g6;	
					eststo: xi: xtreg `y' non_guaranteed p50 p60  if inlist(g,1,2,3,4,5,6) , fe ; 
					quietly sum `y' if inlist(g,1,3,5);
					estadd local y_mean_round = string(r(mean), "%9.3f");										

					
				*5.	price*non-guaranteed;
					eststo: xi: xtreg `y' non_guaranteed p50 p50_non_guaranteed 
							p60 p60_non_guaranteed  if inlist(g,1,2,3,4,5,6) , fe ; 
					quietly sum `y' if inlist(g,1,3,5);
					estadd local y_mean_round = string(r(mean), "%9.3f");										

				*6. trader saving constraints?;				
					eststo: xi: xtreg `y' non_guaranteed no_saving_constraints   if inlist(g,3,4,7), fe ; 
					test non_guaranteed=no_saving_constraints;
					quietly sum `y' if inlist(g,3);
					estadd local y_mean_round = string(r(mean), "%9.3f");										
					
				*ESttab;
					local coef_list non_guaranteed p50 p50_non_guaranteed p60 p60_non_guaranteed no_saving_constraints;
					esttab using "out/tab_SE_`y'_`date'.tex", 					
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
	
	*****************;
	*TABLE 1 - SUMMARY STATS (SECOND COLUMN);
	*****************;
		egen tag_sid=tag(sid);
		keep if tag_sid==1;
		count;
		local X1 e_male e_age e_hh_size e_n_cows e_production e_set_goals e_saves_groups e_saves_bank e_hires_workers e_any_buyer;
		des `X1';				
		sutex `X1' ,labels  key(tab-sum-stats) nobs   nocheck digit(3) title(Summary Statistics for Demand Experiments)
				file("out/tab_sum_stats_SE_`date'.tex") na()  placement(htbp) replace;		
		

		

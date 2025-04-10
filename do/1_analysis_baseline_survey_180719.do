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
			
		*Call data;
			use data/data_baseline, clear;

		
		*****************;
		*FIGURE 1: DESCRIPTIVE EVIDENCE;
		*****************;		
			*Figure 1-A: Coops and savings;
			preserve;
				local Y  b_sets_goals b_reach_often b_coop_helps b_reach_less_weekly;
				keep pid `Y';
				local j=0;
				local Y_num;
				foreach var of varlist `Y'{;	
					local j=`j'+1;
					rename `var' v`j';
				};
				reshape long v, i(pid) j(j);
				label define j 1 "Sets saving goals" 2 "Reaches goals most times"
					3 "Coop helps reaching goals" 4 "Would reach goals less if coop paid weekly", replace;
				label value j j;
				graph hbar v, over(j, label(labsize(medsmall))
							relabel(4 `""Would reach goals less" "if coop paid weekly""'))
						bargap(15) bar( 1,color(gs6))
						graphregion(color(white)) bgcolor(white) ytitle(Frequency) title(Panel A: Farmer Savings and the Coop)  ;
				graph save out/g1.gph, replace;	
			restore;
			
			*Figure 1-B: Traders;
			preserve;
				local Y b_wants_traders_less_often b_worries_escape b_trust_coop_more b_coop_reliable_pay;
				keep pid `Y';
				local j=0;
				local Y_num;
				foreach var of varlist `Y'{;	
					local j=`j'+1;
					rename `var' v`j';
				};
				reshape long v, i(pid) j(j);
				label define j 
					1 "Wants traders to pay less often" 2 "Worried traders escape if paying monthly"
					3 "Trusts coop more than traders" 4 "Coop more reliable than traders in payments", replace;
				label value j j;
				graph hbar v, over(j, label( labsize(medsmall)) 
						relabel(2 `""Worried traders would" "escape if paying monthly""'
								4 `""Coop more reliable than" "traders in payments"'))
						bargap(15) ytitle(Frequency) bar( 1,color(gs6))
						graphregion(color(white)) bgcolor(white) title(Panel B: Traders and Low Frequency Payments)  ;
				graph save out/g2.gph, replace;
			
			*Merge 1-A and 1-B;
				graph combine out/g1.gph out/g2.gph, graphregion(color(white))  col(1);
				graph export out/fig_baseline_`date'.eps, replace;	
				erase out/g1.gph;
				erase out/g2.gph;
			restore;
		

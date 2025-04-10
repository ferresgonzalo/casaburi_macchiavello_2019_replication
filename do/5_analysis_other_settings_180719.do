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
	*FIGURE  7-A: DEMAND FOR INFREQUENT PAYMENTS IN OTHER SETTINGS;
	*****************;
		*Preliminary: create empty database where to store result;
			set obs 4;
			gen  v_label="";
			gen v=.;
			gen c1_kenya_dairy=.;
			gen c2_kenya_tea=.;
			gen c3_myanmar_garment=.;
			replace v=_n;
			replace v_label="v1_prefer_monthly_payment" if _n==1;
			replace v_label="v2_set_saving_goals" if _n==2;
			replace v_label="v3_payment_help_reaching saving goals" if _n==3;
			replace v_label="v4_monthly_pay_help_saving_bank" if _n==4;
			tempfile r;
			sa `r';
			
		*Sum stats for each database (dairy baseline, kenya tea, myanmar garment);
			local j=0;
			foreach data in baseline kenya_tea myanmar{;
				*Call data;
					local j=`j'+1;
					use data/data_`data', clear;
					count;
					local n`j'=r(N);
					local i=0;
				*v1: Payment frequency payment;
					local i=`i'+1;
					tab preference, m nol;
					gen prefer_monthly=0 if preference!=.;
					replace prefer_monthly=1 if preference==4;
					sum prefer_monthly;										
					local a`i'`j'=r(mean);
				*v2: Set saving goals;
					local i=`i'+1;
					if "`data'"=="baseline"{;
						rename b_sets_goals saving_goals;
					};	
					replace saving_goals=0 if saving_goals==2;
					tab saving_goals, nol m;
					sum saving_goals;										
					local a`i'`j'=r(mean);
					
				*v3: monthly payments help reach goals;
					local i=`i'+1;
					if "`data'"!="baseline"{;
						tab buyer_saving;
						gen reach_less=0 if buyer_saving!=.;
						replace reach_less=1 if buyer_saving==1;
					};
					if "`data'"=="baseline"{;
						rename b_reach_less_weekly reach_less;
					};
					tab reach_less, nol m;
					sum reach_less;										
					local a`i'`j'=r(mean);
			
				*v4: monthly payment help bank saving;
					local i=`i'+1;
					if "`data'"=="baseline"{;
						local a41=.;
					};
					if "`data'"!="baseline"{;
						tab buyer_bank;
						gen bank_less=0 if buyer_bank!=.;
						replace bank_less=1 if buyer_bank==1;
						tab bank_less, nol m;
						sum bank_less;										
						local a`i'`j'=r(mean);
					};
			};		
		*Fill results table;	
			use `r', clear;			
			forvalues i=1/4{;
				forvalues j=1/3{;
					displa "a`i'`j'";
					replace c`j'=`a`i'`j'' if _n==`i';
				};
			};	
			
		*Graph;
			label define v 1 `" "Prefers" "Monthly Payments" "' 2 `" "Sets" "Saving Goals" "' 3 `" "MonthlyPay" "Help Reach Goals"  "' 4 `" "MonthlyPay" "Help Bank Saving"  "';
			label value v v ;			
			graph bar c1 c2 c3, over(v, relabel (1 `" "Prefers" "Monthly Payments" "' 2 `" "Sets" "Saving Goals" "' 3 `" "Monthly Payments" "Help Reach Goals"  "' 4 `" "Monthly Payments" "Help Bank Saving"  "') )
					ytitle("") title("Panel A: Preferences Over Payment Frequencies") subtitle("Survey Data: Kenya Dairy, Kenya Tea, Myanmar Garnment") 
					legend(label (1 "Kenya Dairy (N=`n1')") label(2 "Kenya Tea  (N=`n2')") label( 3 "Myanmar Garment  (N=`n3')")  )  scale(.8) 
						bar (1, color(gs13)) bar (2, color(gs9)) bar (3, color(gs5))
						graphregion(color(white)) bgcolor(white);
			graph save out/g1.gph, replace;

	*****************;
	*FIGURE  7-B: FIRMS SIZE AND INFREQUENT PAYMENTS (RWANDA);
	*****************;
		use data/data_rwanda, clear;
		count;
		local n4=r(N);
		graph bar monthly, over(quartile, label) text(-.15 50  "Firm Size Quartile", 
			place(c)) ytitle(% Firms Paying Workers Monthly) graphregion(color(white)) bgcolor(white)
			title(Panel B: Firm Size and Payment Frequency)  subtitle(Rwanda Coffee Mill Survey (N=`n4')) bar (1, color(gs8));
		graph save out/g2.gph, replace;
		
		

	*****************;
	*COMBINE FIGURE 7-A AND 7-B;
	*****************;
		graph combine out/g1.gph out/g2.gph, graphregion(color(white))  col(1);
		graph export out/fig_other_settings_`date'.eps, replace;
		erase out/g1.gph;
		erase out/g2.gph;
	
	
	
	

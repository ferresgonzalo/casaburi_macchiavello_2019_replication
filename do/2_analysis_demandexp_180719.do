# d cr
clear
set more off
set mem 200m
cap log close
# d ;
		
		*Set directory;
			cd "..";
			
		*Locals;
			local date 180719;
			
		*Call data;
			use data/data_demandexp, clear;
		
		*****************;
		*FIGURE 2: DEMAND EXPERIMENT;
		*****************;		
			gen monthly_c1=monthly_ch if choiceexp==1;
			gen monthly_c2=monthly_ch if choiceexp==2;
			sum monthly_c*;
			graph bar monthly_c1 monthly_c2, bargap(15)
			legend (label(1 "Demand Experiment 1 (N=96)") label(2 "Demand Experiment 2 (N=95)") )
			 bar(1, color(gs4)) bar(2, color(gs12)) graphregion(color(white)) bgcolor(white)
			title(Share of Farmers Choosing Monthly Payment Option) ytitle("");
			graph export out/fig_DE_`date'.eps, replace;	

		*****************;
		*FIGURE 3: DEMAND LAB-IN-FIELD;
		*****************;
			tab accept, m;	
			foreach x in 29 32 35 38 41 {;
				gen accept`x'_cum=.;
				replace accept`x'_cum=0 if accept>`x';
				replace accept`x'_cum=1 if accept<=`x';
				sum accept`x'_cum;	
				local mean`x'=r(mean);
			};						
			preserve;
				clear;
				set obs 5;
				gen price=.;
				gen demand=.;
				local i=0;
				foreach x in 29 32 35 38 41 {;
					local i=`i'+1;
					replace price=`x' if _n==`i';
					replace demand=`mean`x'' if price==`x';
				};
				gen monthly_demand=1-demand;
				twoway (connected monthly_demand price , lpattern(dash)) ,						
						xline(31)  xla(29 31 `""31" "(Monthly" "Price)""' 32 35 38 41) 						
						title(Demand for Monthly Payment) subtitle(Lab-in-the-Field Experiment (N=191)) 
						graphregion(color(white)) bgcolor(white)
						ytitle(% Farmers Choosing End-of-Month Payment) xtitle(Daily Price (Ksh)) ;
				graph export out/fig_demand_cum_lif_`date'.pdf, replace;					
			restore;
			
		*****************;
		*TABLE 1 - SUMMARY STATS (FIRST COLUMN);
		*****************;			
				local X1 e_male e_age e_hh_size e_n_cows e_production e_set_goals e_saves_groups e_saves_bank e_hires_workers e_any_buyer;
				des `X1';				
				sutex `X1' ,
					labels  key(tab-sum-stats) nobs   nocheck digit(3) title(Summary Statistics for Demand Experiments)
					file("out/tab_sum_stats_DE_`date'.tex") na()  placement(htbp) replace;			

	


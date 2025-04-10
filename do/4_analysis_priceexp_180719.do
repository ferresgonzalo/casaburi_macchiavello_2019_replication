# d cr
clear
set more off
set mem 200m
cap log close
# d ;

		
	*Set directory;
	*if running this script individually, make sure to define the cd as "..";
		cd "$cm_rep_dir";
	
	*Locals;
		local date 180719;
		
	*Call data;
		use data/data_priceexp, clear;
	
	*****************;
	*FIGURE  6: PRICE AND LIQUIDITY EXPERIMENTS RESULTS;
	*****************;
		preserve;
			collapse (mean) kg*, by(day TREAT_B);
			twoway 
			(scatter kg_pm day if TREAT_B=="Control", msymbol(Th)) 
			(scatter kg_pm day if TREAT_B=="Monthly", msymbol(s))
			(scatter kg_pm day if TREAT_B=="Flexibility", msymbol(D)),
			xlabel(1/6, valuelab)
			title(Price and Liquidity Experiment: Afternoon Deliveries) subtitle((N=398)) ytitle(kg) xline(3.5, lwidth(thick) ) 
			legend(label(1 "Control") label(2 "Bonus") label(3 "Bonus+Flexibility"))
			graphregion(color(white)) bgcolor(white);
			graph export out/fig_priceexp_`date'.pdf, replace;
		restore;

	*****************;
	*TABLE 3: PRICE AND LIQUIDITY EXPERIMENTS RESULTS;
	*****************;			
		estimates clear;
		
		foreach y in   kg_pm kg_pm_dummy  kg_am {;
			dis "DEP VAR IS `y'";

			eststo: xi: areg `y'  M F   mean_`y'_201409 if post==1 ,  a(stratum1) cluster(pid);
				summ `y' if post==1 & C==1 & e(sample);
				local y_mean_round=r(mean);
				local y_mean_round=string(`y_mean_round', "%9.3f");
				estadd local y_mean "`y_mean_round'";	
				test F-M=0;
				estadd local p_mean_round = string(r(p), "%9.3f");	
				estadd local pid_FE ;				
				egen tag_pid_post=tag(pid post);
				replace tag_pid_post=tag_pid_post*post;
				egen N_pid=total(tag_pid_post) if e(sample);
				quietly sum N_pid;
				estadd local N_farmers=r(mean);
				drop N_pid tag_pid_post ;
				
	
			
			eststo: xi: xtreg `y' post_M post_F post i.day, fe cluster(pid);
				summ `y' if post==1 & C==1 & e(sample);
				local y_mean_round=r(mean);
				local y_mean_round=string(`y_mean_round', "%9.3f");
				estadd local y_mean "`y_mean_round'";
				test post_F-post_M=0;
				estadd local p_mean_round = string(r(p), "%9.3f");	
				estadd local pid_FE X ;
				egen N_pid=total(tag_pid) if e(sample);				
				quietly sum N_pid;
				estadd local N_farmers=r(mean);
				drop N_pid ;
		};
		*Esttab;
			esttab using "out/tab_priceexp_`date'.tex",
				mgroups("Kg PM" "Kg PM (dummy)" "Kg AM" , pattern(1  0  1 0    1   0  )
				prefix(\multicolumn{@span}{c}{) suffix(})
				span erepeat(\cmidrule(lr){@span}) )
				keep(post_M post_F post M F)				
				order(post_M post_F post M F)
				b(%9.3f) se(%9.3f) r2
				label star(* 0.1 ** 0.05 *** 0.01)  obslast nomtitles  compress longtable	replace 
				scalars(													
						"p_mean_round p-value $\gamma=\delta$"
						"y_mean Control Group Mean (Post Period)"
						"pid_FE Farmer FE"
						"N_farmers Farmers"
						) 					
				nonotes
				nogaps				
				title(\mbox{Price and Liquidity Experiment} \label{tab-bonus});		
	
	exit;

* This script runs all the Stata code needed to replicate the paper

* set directory
cd ".."
global cm_rep_dir "`c(pwd)'"


run "do/0_install_packages.do"
run "do/1_analysis_baseline_survey_180719.do"
run "do/2_analysis_demandexp_180719.do"
run "do/3_analysis_supplyexp_180719.do"
run "do/4_analysis_priceexp_180719.do"
run "do/5_analysis_other_settings_180719.do"

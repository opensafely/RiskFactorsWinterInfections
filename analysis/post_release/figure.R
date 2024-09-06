# Specify paths ----

source("analysis/post_release/specify_paths.R")
source("analysis/post_release/utility.R")
source("analysis/post_release/fn-make_figure.R")

# Main figures ----

make_figure(name = "1",
            hr = TRUE,
            cohort = c("winter2019"), 
            subgroup = c("main"), 
            infection = c("flu","pneu","rsv"), 
            outcome = c("adm"), 
            model = c("exp_bin_chronicresp exp_bin_chd exp_bin_chronicliver exp_bin_stroke_dementia exp_bin_otherneuro exp_bin_autoimm exp_bin_transplant exp_bin_asplenia exp_bin_othimm exp_bin_hypertension exp_cat_asthma exp_cat_diabetes exp_cat_kidneyfunc exp_cat_cancer_exhaem exp_cat_cancer_haem"), 
            adjustment = "max")

make_figure(name = "2",
            hr = TRUE,
            cohort = c("winter2021"), 
            subgroup = c("main"), 
            infection = c("covid","pneu"), 
            outcome = c("adm"), 
            model = c("exp_bin_chronicresp exp_bin_chd exp_bin_chronicliver exp_bin_stroke_dementia exp_bin_otherneuro exp_bin_autoimm exp_bin_transplant exp_bin_asplenia exp_bin_othimm exp_bin_hypertension exp_cat_asthma exp_cat_diabetes exp_cat_kidneyfunc exp_cat_cancer_exhaem exp_cat_cancer_haem"), 
            adjustment = "max")

make_figure(name = "3",
            hr = TRUE,
            cohort = c("winter2019"), 
            subgroup = c("main"), 
            infection = c("flu","pneu"), 
            outcome = c("death"), 
            model = c("exp_bin_chronicresp exp_bin_chd exp_bin_chronicliver exp_bin_stroke_dementia exp_bin_otherneuro exp_bin_autoimm exp_bin_transplant exp_bin_asplenia exp_bin_othimm exp_bin_hypertension exp_cat_asthma exp_cat_diabetes exp_cat_kidneyfunc exp_cat_cancer_exhaem exp_cat_cancer_haem"), 
            adjustment = "max")

make_figure(name = "4",
            hr = TRUE,
            cohort = c("winter2021"), 
            subgroup = c("main"), 
            infection = c("covid"), 
            outcome = c("death"), 
            model = c("exp_bin_chronicresp exp_bin_chd exp_bin_chronicliver exp_bin_stroke_dementia exp_bin_otherneuro exp_bin_autoimm exp_bin_transplant exp_bin_asplenia exp_bin_othimm exp_bin_hypertension exp_cat_asthma exp_cat_diabetes exp_cat_kidneyfunc exp_cat_cancer_exhaem exp_cat_cancer_haem"), 
            adjustment = "max")


# Figure: Hospital admissions, Winter 2021 ----

make_figure(name = "_winter2021_adm",
            hr = TRUE,
            cohort = c("winter2021"), 
            subgroup = c("main"), 
            infection = c("covid","flu","pneu","rsv"), 
            outcome = c("adm"), 
            model = c("exp_bin_chronicresp exp_bin_chd exp_bin_chronicliver exp_bin_stroke_dementia exp_bin_otherneuro exp_bin_autoimm exp_bin_transplant exp_bin_asplenia exp_bin_othimm exp_bin_hypertension exp_cat_asthma exp_cat_diabetes exp_cat_kidneyfunc exp_cat_cancer_exhaem exp_cat_cancer_haem"), 
            adjustment = "max")

# Figure: Hospital readmissions, Winter 2021 ----

make_figure(name = "_winter2021_readm",
            hr = TRUE,
            cohort = c("winter2021"), 
            subgroup = c("main"), 
            infection = c("covid","flu","pneu"), 
            outcome = c("readm"), 
            model = c("exp_bin_chronicresp exp_bin_chd exp_bin_chronicliver exp_bin_stroke_dementia exp_bin_otherneuro exp_bin_autoimm exp_bin_transplant exp_bin_asplenia exp_bin_othimm exp_bin_hypertension exp_cat_asthma exp_cat_diabetes exp_cat_kidneyfunc exp_cat_cancer_exhaem exp_cat_cancer_haem"), 
            adjustment = "max")

# Figure: Deaths, Winter 2021 ----

make_figure(name = "_winter2021_death",
            hr = TRUE,
            cohort = c("winter2021"), 
            subgroup = c("main"), 
            infection = c("covid","pneu"), 
            outcome = c("death"), 
            model = c("exp_bin_chronicresp exp_bin_chd exp_bin_chronicliver exp_bin_stroke_dementia exp_bin_otherneuro exp_bin_autoimm exp_bin_transplant exp_bin_asplenia exp_bin_othimm exp_bin_hypertension exp_cat_asthma exp_cat_diabetes exp_cat_kidneyfunc exp_cat_cancer_exhaem exp_cat_cancer_haem"), 
            adjustment = "max")

# Figure: Hospital admissions, Winter 2019 ----

make_figure(name = "_winter2019_adm",
            hr = TRUE,
            cohort = c("winter2019"), 
            subgroup = c("main"), 
            infection = c("flu","pneu","rsv"), 
            outcome = c("adm"), 
            model = c("exp_bin_chronicresp exp_bin_chd exp_bin_chronicliver exp_bin_stroke_dementia exp_bin_otherneuro exp_bin_autoimm exp_bin_transplant exp_bin_asplenia exp_bin_othimm exp_bin_hypertension exp_cat_asthma exp_cat_diabetes exp_cat_kidneyfunc exp_cat_cancer_exhaem exp_cat_cancer_haem"), 
            adjustment = "max")

# Figure: Hospital readmissions, Winter 2019 ----

make_figure(name = "_winter2019_readm",
            hr = TRUE,
            cohort = c("winter2019"), 
            subgroup = c("main"), 
            infection = c("flu","pneu","rsv"), 
            outcome = c("readm"), 
            model = c("exp_bin_chronicresp exp_bin_chd exp_bin_chronicliver exp_bin_stroke_dementia exp_bin_otherneuro exp_bin_autoimm exp_bin_transplant exp_bin_asplenia exp_bin_othimm exp_bin_hypertension exp_cat_asthma exp_cat_diabetes exp_cat_kidneyfunc exp_cat_cancer_exhaem exp_cat_cancer_haem"), 
            adjustment = "max")

# Figure: Deaths, Winter 2019 ----

make_figure(name = "_winter2019_death",
            hr = TRUE,
            cohort = c("winter2019"), 
            subgroup = c("main"), 
            infection = c("flu","pneu"), 
            outcome = c("death"), 
            model = c("exp_bin_chronicresp exp_bin_chd exp_bin_chronicliver exp_bin_stroke_dementia exp_bin_otherneuro exp_bin_autoimm exp_bin_transplant exp_bin_asplenia exp_bin_othimm exp_bin_hypertension exp_cat_asthma exp_cat_diabetes exp_cat_kidneyfunc exp_cat_cancer_exhaem exp_cat_cancer_haem"), 
            adjustment = "max")
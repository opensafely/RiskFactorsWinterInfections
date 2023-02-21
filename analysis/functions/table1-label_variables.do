* Program to label variables for Table 1: summary statistics -------------------

cap prog drop label_variables
prog def label_variables

label variable sub_cat_age "Age"
label variable cov_bin_male "Sex"
label variable cov_cat_obese "Obesity"
label variable cov_cat_smoking "Smoking"
label variable cov_cat_ethnicity "Ethnicity"
label variable cov_cat_deprivation "IMD quintile"
label variable sub_bin_carehome "Carehome resident"
label variable exp_bin_hypertension "Hypertension"
label variable exp_bin_chronicresp "Chronic respiratory disease, excluding asthma"
label variable exp_cat_asthma "Asthma"
label variable exp_bin_chd "Chronic heart disease"
label variable exp_cat_diabetes "Diabetes"
label variable exp_cat_cancer_exhaem "Cancer (non-haematological)"
label variable exp_cat_cancer_haem "Haematological malignancy"
label variable exp_cat_kidneyfunc "Reduced kidney function"
label variable exp_bin_chronicliver "Chronic liver disease"
label variable exp_bin_stroke_dementia "Stroke or dementia"
label variable exp_bin_otherneuro "Other neurological disease"
label variable exp_bin_transplant "Solid organ transplant"
label variable exp_bin_asplenia "Asplenia"
label variable exp_bin_autoimm "Common autoimmune disease"
label variable exp_bin_othimm "Other immunosuppressive condition"

end

calculate_TES <- function(method, ctrl, exp)
{
  tmp <- sapply(paste0("./Rscripts/",list.files(path="Rscripts")), source)
  
  n_perm <- 10000
  n_cores <- 10
  grp_ctrl_name <- names(ctrl)[1]
  grp_exp_name <- names(exp)[1]

  # Loading RCB score values
  RCB_ctrl <- ctrl[,1]
  RCB_exp <- exp[,1]
  
  # Calculating Treatment Efficacy Score and its p-value
  res_TES <- switch(method,
                    wKS = wKS(RCB_ctrl, RCB_exp, n_perm=n_perm, n_cores=n_cores, grp_ctrl_name=grp_ctrl_name, grp_exp_name=grp_exp_name),
                    DensRatio = DensRatio(RCB_ctrl, RCB_exp, n_perm=n_perm, n_cores=n_cores, grp_ctrl_name=grp_ctrl_name, grp_exp_name=grp_exp_name),
                    DensDiff = DensDiff(RCB_ctrl, RCB_exp, n_perm=n_perm, sig="auto", n_cores=n_cores, grp_ctrl_name=grp_ctrl_name, grp_exp_name=grp_exp_name))
  res_TES
}

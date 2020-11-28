wKS <- function(RCB_ctrl,RCB_exp, n_perm=10000, scale=0.5, n_cores=1, grp_ctrl_name="Control", grp_exp_name="Experimental") {
# Estimate Treatment Efficacy Score (TES) using two sample weighted Kolmogorov-Smirnov test
# by comparing RCB score from experimental treatment cohort vs control cohort and Area Beetwen CDF curves (ABC)
#
# Input:
# RCB_ctrl - vector of RCB values in control cohort
# RCB_exp - vector of RCB values in experimental treatment cohort
# n_perm - number of test permutations (positive integer)
# scale - weight function parameter. Higher value gives higher weights to low RCB scores (non-negative value)
#
# Output: TES, its p-value and plots
# 
# Author: Michal Marczyk (michal.marczyk@yale.edu; michal.marczyk@polsl.edu)
  
  # calculate Treatment Efficacy Score
  res <- w_KS_stat(RCB_ctrl,RCB_exp, scale=scale, ifplot=T, grp_ctrl_name=grp_ctrl_name, grp_exp_name=grp_exp_name)
  TES <- res[[1]]
  p2 <- res[[2]]
  
  # prepare data for permutation test 
  n1 <- length(RCB_exp)
  n2 <- length(RCB_ctrl)
  RCB_all <- c(RCB_ctrl, RCB_exp)
  perm_list <- lapply(1:n_perm,function(x){sample.int(n1+n2, n1)})
  
  # run permutation test in parallel
  res_perm <- mclapply(perm_list, function(d){
    res_KS <- w_KS_stat(RCB_all[d], RCB_all[-d], scale=scale)
  },  mc.cores = n_cores)
  res_perm <- do.call(c,res_perm)

  # calculate p-value of one sided test
  TES_p <- sum(res_perm > TES)/n_perm  
  TES_p <- max(1/n_perm, TES_p)
  
  # create density plot
  data_plot <- data.frame(c(RCB_ctrl, RCB_exp))
  colnames(data_plot) <- "RCBscore"
  data_plot$Group <- c(rep(grp_ctrl_name,length(RCB_ctrl)), rep(grp_exp_name,length(RCB_exp)))
  p1 <- ggplot(data_plot,aes(col=Group, x=RCBscore)) + geom_density() + 
    labs(x="Residual Cancer Burden score", y="Density", 
         title=paste0("Treatment Efficacy Score = ",signif(TES,3), ". P = ",signif(TES_p,2))) +
    theme_bw() + theme(legend.position="bottom", plot.title=element_text(hjust=0.5, color="red", face="bold", size=18))
  
  # return results
  res <- list()
  res[["TES"]] <- c(TES, TES_p)
  names(res[["TES"]]) <- c("TES","P-value")
  res[["Plot1"]] <- p1
  res[["Plot2"]] <- p2
  return(res)
}
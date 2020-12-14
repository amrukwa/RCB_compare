DensRatio <- function(RCB_ctrl, RCB_exp, n_perm = 1000, sig="auto", lam=10^seq(-3,0,length.out=50), 
                      alpha=0.5, kernel_num=1000, n_cores=1, grp_ctrl_name="Control", grp_exp_name="Experimental"){
# Estimate Treatment Efficacy Score (TES) by comparing densities of RCB in experimental treatment cohort vs control cohort
# Step1: estimate density ratio using kernel functions
# Step2: calculate eCDF of density ratio
# Step3: calculate TES as area under eCDF
#
# Input:
# RCB_ctrl - vector of RCB values in control cohort
# RCB_exp - vector of RCB values in experimental treatment cohort
# sig - kernel bandwidth (vector with numeric values > 0)
# lam - regularization parameter (vector with numeric values > 0)
# alpha - relative parameter for RuLSIF density estimation method (numeric from 0 to 1)
# kernel_num - no. of kernels (integer > 0)
#
# Output: TES with 95% confidence intervals
# 
# Author: Michal Marczyk (michal.marczyk@yale.edu; michal.marczyk@polsl.edu)

  if (sig == "auto"){
    sig <- bw.nrd0(c(RCB_ctrl, RCB_exp)) 
  }

  # compute density ratio
  res <- RCB_ratio(RCB_ctrl, RCB_exp, sig=sig, lam=lam, alpha=alpha, kernel_num=kernel_num, ifplot=T, grp_ctrl_name=grp_ctrl_name, grp_exp_name=grp_exp_name)
  TES <- res$TES
  p2 <- res$Plot
  
  # prepare data for permutation test 
  n1 <- length(RCB_exp)
  n2 <- length(RCB_ctrl)
  RCB_all <- c(RCB_ctrl, RCB_exp)
  perm_list <- lapply(1:n_perm,function(x){sample.int(n1+n2, n1)})
  
  # run permutation test in parallel with fixed density ratio parameters
  res_perm <- mclapply(perm_list, function(d){
    RCB_ratio(RCB_all[d], RCB_all[-d], sig=res$Parameters["Sigma"],
                   lam=res$Parameters["Lambda"], alpha=alpha, kernel_num=kernel_num)
  },  mc.cores = n_cores)
  res_perm <- do.call(c,res_perm)
  TES_p <- (sum(res_perm > res$TES))/n_perm
  TES_p <- max(1/n_perm, TES_p)
  
  # create density plot
  data_plot <- data.frame(c(RCB_ctrl, RCB_exp))
  colnames(data_plot) <- "RCBscore"
  data_plot$Group <- c(rep(grp_ctrl_name,length(RCB_ctrl)), rep(grp_exp_name,length(RCB_exp)))
  p1 <- ggplot(data_plot,aes(col=Group, x=RCBscore)) + geom_density() + 
    labs(x="Residual Cancer Burden score", y="Density", 
         title=paste0("Treatment Efficacy Score = ",signif(TES,3), " (P = ",signif(TES_p,2), ")")) +
    scale_color_manual(values=c(alpha("#157525", 0.8), alpha("#CD0000", 0.8))) +
    guides(color = guide_legend(override.aes = list(fill =c(alpha("#157525", 0.8), alpha("#CD0000", 0.8))))) +
    theme_bw() + theme(legend.position="bottom", plot.title=element_text(hjust=0.5, color="black", face="bold", size=18))
  
  # return results
  res <- list()
  res[["TES"]] <- c(TES, TES_p)
  names(res[["TES"]]) <- c("TES","P-value")
  res[["Plot1"]] <- p1
  res[["Plot2"]] <- p2
  return(res)
}

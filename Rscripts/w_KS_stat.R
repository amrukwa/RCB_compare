w_KS_stat <- function(RCB_ctrl, RCB_exp, scale=0.0, ifplot=F, grp_ctrl_name="Control", grp_exp_name="Experimental") {
# Estimate Treatment Efficacy Score (TES) using two sample weighted Kolmogorov-Smirnov test
# by comparing RCB score from experimental treatment cohort vs control cohort and Area Beetwen CDF curves (ABC)
#
# Input:
# RCB_ctrl - vector of RCB values in control cohort
# RCB_exp - vector of RCB values in experimental treatment cohort
# scale - weight function parameter. Higher value gives higher weights to low RCB scores (non-negative value)
# ifplot - if plot should be generated  
#
# Output: TES (Treatment Efficacy score calculated as an area between weighted eCDF curves)
# 
# Author: Michal Marczyk (michal.marczyk@yale.edu; michal.marczyk@polsl.edu)
  
  # create weighted eCDFs and calculated their difference
  ecdf_ctrl <- w_eCDF(RCB_ctrl, scale=scale)
  ecdf_exp <- w_eCDF(RCB_exp, scale=scale)
  ecdf_diff <- function(x){ecdf_exp(x) - ecdf_ctrl(x)}
  
  # Calculate Treatment Efficacy score (TES) as an area between two eCDF curves
  x <- sort(unique(c(0,RCB_ctrl,RCB_exp)))
  ecdf_diff_calc <- ecdf_diff(x)
  TES <- sum(ecdf_diff_calc[-length(ecdf_diff_calc)] * (x[-1] - x[-length(x)]))/max(x)
  
  if (ifplot){
    data_plot <- data.frame(x)
    data_plot$ecdf_ctrl <- ecdf_ctrl(x)
    data_plot$ecdf_exp <- ecdf_exp(x)
    data_plot$ecdf_diff <- ecdf_diff_calc
    p <- ggplot(data_plot, aes(x=x, y=ecdf_diff)) + geom_step(col="#56B4E9") + theme_bw() +  scale_x_continuous(expand = c(0,0)) +
      labs(x="Residual Cancer Burden score", y=paste0("Weighted eCDF difference\n(",grp_exp_name," - ",grp_ctrl_name,")")) +
      theme(plot.title=element_text(hjust=0.5)) + geom_hline(yintercept=0, col="black")
    
    res <- list()
    res[[1]] <- TES
    res[[2]] <- p
    return(res)
  } else {
    return(TES)  
  }
}
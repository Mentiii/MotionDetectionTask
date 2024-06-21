#Analyses motion detection task

# Packages ----------------------------------------------------------------
library(ggplot2)
library(dplyr)
library(readr)


# Import data -------------------------------------------------------------
    #This is the data from 1 participant
data = read_table("C:/Users/menth/OneDrive - UvA/Jaar 3 semester 2/Stage/data verzameld/allData")

# Vervangen foute getallen ------------------------------------------------
    #180 en 360 in oritneNow_R worden beide 0
data$orientNow_R[data$orientNow_R == 180 | data$orientNow_R == 360] = 0

View(data)


# Adding bin column  -------------------------------------------------------

breaks1 = seq(0,91, by=6)
breaks2 = seq(270,361, by=6)
breaks = c(breaks1, breaks2) # define were to cut and bin size
labels = paste(breaks1[-length(breaks1)], breaks1[-1]-1, sep = "-")
means_lConf_rtconf
means_lConf_rtconf


bin_function <- function(x) {
  if (x <= 100) {
    return(cut(x, breaks=breaks1, labels=labels, right=FALSE))
  } else {
    return(cut(x, breaks=breaks2, labels=labels, right=FALSE))
  }
}


data = data %>% mutate(response_bin = sapply(data$orientNow_R, bin_function))


# Adding degrees turned ---------------------------------------------------

degrees_turned = data$orientNow_R - data$orientBegin
data = data %>% mutate(degrees_turned = degrees_turned)


# Indexation ----------------------------------------------------------------

  # Remove first 100 trials
data = data %>% filter(data$trialcounter > 100)

# Keep high confidence
data_hConf = data %>% filter(data$confidence >2)
  # High conficence, high visible
data_hConf_hVis = data_hConf %>% filter(data_hConf$Dots == 'HighVisible')
  # High confidence, low visible
data_hConf_lVis = data_hConf %>% filter(data_hConf$Dots == 'LowVisible')
  # High confidence, no dots
data_hConf_noDots = data_hConf %>% filter(data_hConf$Dots == 'NoDots')
  
# Keep low confidence
data_lConf = data %>% filter(data$confidence <3)
  # Low conficence, high visible
data_lConf_hVis = data_lConf %>% filter(data_lConf$Dots == 'HighVisible')
  # Low confidence, low visible
data_lConf_lVis = data_lConf %>% filter(data_lConf$Dots == 'LowVisible')
  # Low confidence, no dots
data_lConf_noDots = data_lConf %>% filter(data_lConf$Dots == 'NoDots')

# Perception
data_per = data %>% filter(data$Delay == 'NoDelay')

# Keep high confidence
data_per_hConf = data_per %>% filter(data_per$confidence >2)
# High confidence, high visible
data_per_hConf_hVis = data_per_hConf %>% filter(data_per_hConf$Dots == 'HighVisible')
# High confidence, low visible
data_per_hConf_lVis = data_per_hConf %>% filter(data_per_hConf$Dots == 'LowVisible')
# High confidence, no dots
data_per_hConf_noDots = data_per_hConf %>% filter(data_per_hConf$Dots == 'NoDots')

# Keep low confidence
data_per_lConf = data_per %>% filter(data_per$confidence <3)
# Low confidence, high visible
data_per_lConf_hVis = data_per_lConf %>% filter(data_per_lConf$Dots == 'HighVisible')
# Low confidence, low visible
data_per_lConf_lVis = data_per_lConf %>% filter(data_per_lConf$Dots == 'LowVisible')
# Low confidence, no dots
data_per_lConf_noDots = data_per_lConf %>% filter(data_per_lConf$Dots == 'NoDots')

# Short term memory
data_stm = data %>% filter(data$Delay == 'Delay')

  # Keep high confidence
data_stm_hConf = data_stm %>% filter(data_stm$confidence >2)
  # High confidence, high visible
data_stm_hConf_hVis = data_stm_hConf %>% filter(data_stm_hConf$Dots == 'HighVisible')
  # High confidence, low visible
data_stm_hConf_lVis = data_stm_hConf %>% filter(data_stm_hConf$Dots == 'LowVisible')
  # High confidence, no dots
data_stm_hConf_noDots = data_stm_hConf %>% filter(data_stm_hConf$Dots == 'NoDots')

# Keep low confidence
data_stm_lConf = data_stm %>% filter(data_stm$confidence <3)
  # Low confidence, high visible
data_stm_lConf_hVis = data_stm_lConf %>% filter(data_stm_lConf$Dots == 'HighVisible')
  # Low confidence, low visible
data_stm_lConf_lVis = data_stm_lConf %>% filter(data_stm_lConf$Dots == 'LowVisible')
  # Low confidence, no dots
data_stm_lConf_noDots = data_stm_lConf %>% filter(data_stm_lConf$Dots == 'NoDots')

# Visible high confidence errors
data_hConf__vis_wrong = data_hConf %>% filter(data_hConf$Dots != 'NoDots' & data_hConf$arrow_deviation > 10) #How large is a deviation to be wrong?




# Exclusion criteria ------------------------------------------------------

# 1) Enough high confidence, no dots trials in perception and stm (TODO what is enough?)
table_trials = table(data_hConf$condition)
      # contrast = lVis, detection = hVis
table_trials

# 2) Mean accuracy high visible trials less then 30 degrees
accuracy_hVis = signif(mean(data$arrow_deviation[data$Dots == 'HighVisible']),2)
accuracy_hVis
# 3) at least 80% detection of dots (but thats kinda point 1?)

# Statistics --------------------------------------------------------------
  # Ruwe gemiddeldes accuracy
means = by(data$arrow_deviation,data$condition,mean) #let op, NoDots getal negeren, slaat nergens op
means_hConf_acc = signif(by(data_hConf$arrow_deviation,data_hConf$condition,mean),2)
means_hConf_acc
means_lConf_acc = signif(by(data_lConf$arrow_deviation,data_lConf$condition,mean),2)
means_lConf_acc
  # Ruwe gemiddeldes reaction time arrow
means = by(data$rt_arrow,data$condition,mean)
means_hConf_rtAr = signif(by(data_hConf$rt_arrow,data_hConf$condition,mean),3)
means_hConf_rtAr
means_lConf_rtAr = signif(by(data_lConf$rt_arrow,data_lConf$condition,mean),3)
means_lConf_rtAr
  # Ruwe gemiddeldes reaction time confidence
means = by(data$rt_confidence,data$condition,mean)
means_hConf_rtconf = signif(by(data_hConf$rt_confidence,data_hConf$condition,mean),3)
means_hConf_rtconf
means_lConf_rtconf = signif(by(data_lConf$rt_confidence,data_lConf$condition,mean),3)
means_lConf_rtconf

# Ruwe gemiddeldes antwoord THIS MAKES NO SENSE becasue of negative answers
  #means_hConf_resp = signif(by(data_hConf$orientNow_R,data_hConf$condition,mean),3)
  #means_lConf_resp = signif(by(data_lConf$orientNow_R,data_lConf$condition,mean),3)



# Tables of bins ----------------------------------------------------------

table_allBins = by(data$response_bin,data$condition, table)
table_Bins_hConf = by(data_hConf$response_bin, data_hConf$condition, table)
table_Bins_hConf

  #This table shows the orientation bin of all wrong (visible) high confidence answers. However it doesnt take into account the direction of the dots (correct answer)
table_bins_hConf__vis_wrong = by(data_hConf__vis_wrong$response_bin, data_hConf__vis_wrong$condition, table)

# Table degrees turned ----------------------------------------------------
  # 0 if not turned at all
table_degrees_turned = by(data$degrees_turned, data$condition, table)
   


# Packages ----------------------------------------------------------------
library(ggplot2)
library(dplyr)
library(ez)
library(readr)
library(ggpattern)
install.packages("ggpattern")


# Import data -------------------------------------------------------------

data = read_table("C:/Users/menth/OneDrive - UvA/Jaar 3 semester 2/Stage/data verzameld/allData")


# Getting the data ready --------------------------------------------------
  # 180 en 360 in orientNow_R worden beide 0
data$orientNow_R[data$orientNow_R == 180 | data$orientNow_R == 360] = 0

  # Remove first 100 trials
data = data %>% filter(data$trialcounter > 100)

  # Adding bin column
breaks1 = seq(0,91, by=6)
breaks2 = seq(270,361, by=6)
breaks = c(breaks1, breaks2) # define were to cut and bin size
labels = paste(breaks1[-length(breaks1)], breaks1[-1]-1, sep = "-")


bin_function <- function(x) {
  if (x <= 100) {
    return(cut(x, breaks=breaks1, labels=labels, right=FALSE))
  } else {
    return(cut(x, breaks=breaks2, labels=labels, right=FALSE))
  }
}

data = data %>% mutate(response_bin = sapply(data$orientNow_R, bin_function))

  # Add column how much turned
degrees_turned = data$orientNow_R - data$orientBegin
data = data %>% mutate(degrees_turned = degrees_turned)

CON = as.character(data_nodot$confidence)
data_nodot = data_nodot %>% mutate(CON = CON)

table_degrees_turned = by(data$degrees_turned, data$condition, table)

# Keep high confidence
data_hConf = data %>% filter(data$confidence >1)
data_hConf_nodot = data %>% filter(data$confidence >1 & data$Dots == "NoDots")
    # Visible high confidence errors 
data_hConf__vis_wrong = data_hConf %>% filter(data_hConf$Dots != 'NoDots' & data_hConf$arrow_deviation > 10) #How large is a deviation to be wrong?

#data zonder dots
data_nodot= data %>% filter(data$Dots == 'NoDots')



# Discriptive participants ------------------------------------------------

table(data$gender)

table(data_aantal_corr$condition)
table(data$condition)

corr_no_lvis= signif(1257*100/2710,2)
corr_del_lvis= signif(1175*100/2705,2)
corr_no_hvis=signif(1597*100/2707,2)
corr_del_hvis=signif(1509*100/2708,2)

df = data.frame(condition=factor(rep(c("detection_per", "detection_stm", "contrast_per", "contrast_stm"))),percentage_corr= c(corr_no_lvis,corr_del_lvis,corr_no_hvis,corr_del_hvis))

data_aantal_corr=data %>% filter(data$Dots != 'NoDots' &data$arrow_deviation <10)

#figuur 2
ggplot(df, aes(x=percentage_corr,y=condition,fill=condition)) +
  geom_bar_pattern(stat="identity", aes(pattern=condition), pattern_density=0.1, pattern_fill='black', pattern_angle=45, pattern_spacing=0.19) +
  scale_y_discrete(label = c("no delay", "delay", "no delay", "delay")) +
  scale_fill_manual(values=c( "#cc0000","#ff6666","#33cc33","#99FF66"))+
  theme(legend.position="none", text=element_text(size=15)) +
  ylab("clearly visible                                    barely visible") +
  xlab("Percentage of correct trials(%)") +
  scale_pattern_manual(values=c('wave', 'stripe' ,'wave', 'stripe')) +
  geom_text(aes(label=percentage_corr), vjust=1.6, color="black", size=5)+
  coord_flip()





# Visualisation -----------------------------------------------------------
  # Violin plots
ggplot(data, aes(x=condition, y=arrow_deviation)) +
  geom_violin()

ggplot(data, aes(x=condition, y=rt_arrow)) +
  geom_violin()

ggplot(data, aes(x=condition, y=rt_confidence)) +
  geom_violin()

ggplot(data, aes(x=condition, y=dot_dir)) +
  geom_violin()

ggplot(data, aes(x=condition, y=orientNow_R)) +
  geom_violin()

plot(data$dot_dir$condition)

  #bins no dots, high confidence
plot(data$response_bin[data$condition == 'estimation_stm' & data$confidence >1])
plot(data$response_bin[data$condition == 'estimation_per' & data$confidence >1])

#plot verdeling antwoorden GOED
#plot bins met kleurtjes door elkaar FIGUUR 2
ggplot(data=data_hConf, aes(response_bin, color=Dots)) + 
  geom_histogram(stat = "count", fill = 'white', alpha=0.5, position = "dodge") +
  theme(legend.justification=c(0,0), legend.position=c(0.79,0.85)) +
  labs(title="A") + #Directions of high confidence responses
  xlab('Direction of response (degrees)') +
  ylab('Frequency')


  #zoom in op no dots
ggplot(data=data_hConf_nodot, aes(response_bin, color=Delay)) + 
  geom_histogram(stat = "count", fill = 'white', alpha=0.5, position = "dodge") +
  xlab('Direction of response (degrees)') +
  ylab('Frequency') +
  scale_color_manual(values=c("#00CCFF", "#3366FF")) +
  theme(legend.justification=c(0,0), legend.position=c(0.88,0.79)) +
  labs(title="c") +
  guides(fill=guide_legend(title=NULL)) +
  scale_y_continuous( breaks=seq(0,70, by=10))

  #plot nodots op confidence
ggplot(data=data_nodot, aes(response_bin, color=CON)) + 
  geom_histogram(stat = "count", fill = 'white', alpha=0.5, position = "dodge") +
  theme(legend.justification=c(0,0), legend.position=c(0.55,0.79)) +
  xlab('Direction of response (degrees)') +
  ylab('Frequency') +
  labs(color="confidence")







#plot met kleurtejs door elkaar als lijntjes
ggplot(data, aes(x=response_bin, color = condition)) + geom_histogram(stat="count") + geom_density()

#plot bins onder elkaar
ggplot(data=data_hConf_nodot, aes(response_bin)) + 
  geom_histogram(stat = "count", fill = 'black', alpha=0.5) +
  facet_grid(condition~.)



   #bins low visible, high confidence
plot(data$response_bin[data$condition == 'contrast_stm' & data$confidence >2])
plot(data$response_bin[data$condition == 'contrast_per' & data$confidence >2])

#bins high visible, high confidence
plot(data$response_bin[data$condition == 'detection_stm' & data$confidence >2])
plot(data$response_bin[data$condition == 'detection_per' & data$confidence >2])


# bins visible, high confidence errors
plot(data_hConf__vis_wrong$response_bin[data$condition == 'detection_stm'])
plot(data_hConf__vis_wrong$response_bin[data$condition == 'detection_per'])
plot(data_hConf__vis_wrong$response_bin[data$condition == 'contrast_stm'])
plot(data_hConf__vis_wrong$response_bin[data$condition == 'contrast_per'])


# Plot verdeling ----------------------------------------------------------

true_bins <- read_excel("C:/Users/menth/OneDrive - UvA/Jaar 3 semester 2/Stage/Data-analyse/true_bins.xlsx", 
                        col_types = c("text", "numeric"))

true_bins$bins = factor(true_bins$bins, levels = c("0-5", "6-11", "12-17", "18-23", "24-29", "30-35", "36-41", "42-47", "48-53", "54-59", "60-65", "66-71", "72-77", "78-83", "84-89"))

ggplot(data=true_bins, aes(bins, color=bins)) + 
  geom_histogram(stat = "count", fill = 'white', alpha=0.5, position = "dodge") +
  geom_density()+
  scale_color_manual(values=c("green","green","green","green","green","green","green","green","green","green","green","green","green","green","green"))+
  theme(legend.position="none") +
  labs(title="B") + #Directions of presented dots
  xlab('Direction of dots (degrees)') +
  ylab('Percentage of trials')



# plot accuaracy ----------------------------------------------------------
data=data_hConf

#goede plot accuracy 
ggplot(data, aes(x=condition, y=arrow_deviation, fill=condition)) +
  geom_boxplot(outlier.size=.2)+
  scale_fill_manual(values=c("#33cc33","#99FF66", "#cc0000","#ff6666", "#3366FF", "#00CCFF"))+
  scale_x_discrete(limits=c("detection_per", "detection_stm", "contrast_per", "contrast_stm", "estimation_per", "estimation_stm"), label = c("no delay\n high visible", "delay \n high visble", "no delay\n low visible", "delay\n low visible", "no delay\n no dots", "delay\n no dots")) +
  theme(legend.position="none") +
  ylab("Degrees deviation from dot movement") +
  xlab("Condition") +
  scale_y_continuous( breaks=seq(0,180, by=20))

# figuur 3 degrees deviation
ggplot(data, aes(x=condition, y=arrow_deviation, fill=condition)) +
  geom_boxplot_pattern(outlier.size=0.1,aes(pattern=condition), pattern_fill='black', pattern_density=0.01, pattern_spacing=0.05, patern_angle=45)+
  scale_pattern_manual(values=c('wave', 'stripe','wave', 'stripe'))+
  scale_fill_manual(values=c("#33cc33","#99FF66", "#cc0000","#ff6666"))+
  scale_x_discrete(limits=c("detection_per", "detection_stm", "contrast_per", "contrast_stm"), label = c("no delay", "delay", "no delay", "delay")) +
  theme(legend.position="none", text=element_text(size=15)) +
  ylab("Response deviation from dot movement") +
  xlab("cleary visible                         barely visible") +
  scale_y_continuous( breaks=seq(0,180, by=20))   

ezStats(data=data, dv=arrow_deviation, wid=ID, between=condition)

install.packages('xlsx')     
library(xlsx) 

write_xlsx(avocado, 'avocado.xlsx')

by(data$arrow_deviation,data$condition,shapiro.test)

res_anova= ezANOVA(data=data, dv=arrow_deviation, wid=ID, between=condition, detailed = T)
pairwise.t.test(x=data$arrow_deviation, g=data$condition, p.adjust.method = 'bonferroni', paired=F)
ezStats(data=data, dv=arrow_deviation, wid=ID, between=condition)

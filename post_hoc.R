#Post hoc tests


# packages ----------------------------------------------------------------
library(ggplot2)
library(ez)

# import data -------------------------------------------------------------
data_short_long <- read_excel("C:/Users/menth/OneDrive - UvA/Jaar 3 semester 2/Stage/Data-analyse/data_short_long.xlsx")
data=data_short_long

data[(data=="perception")] = "no delay"
data[(data=="stm")] = "delay"


# tests -------------------------------------------------------------------

#perception vs stm

ezStats(data, dv=measurement, wid = ID, within=delay)

by(data = data$measurement, INDICES = data$delay, FUN = shapiro.test)

t.test(data$measurement~data$delay, paired=TRUE)
wilcox.test(measurement~delay, data = data, paired = TRUE)

ggplot(data, aes(x=delay, y=measurement)) +
  geom_boxplot()

#bins within visibility

data_lVis=data %>% filter(data$visibility == 'lVis')
data_hVis=data %>% filter(data$visibility == 'hVis')
data_no=data %>% filter(data$visibility == 'no')
data_per=data %>% filter(data$delay =='perception')
data_stm=data %>% filter(data$delay == 'stm')
data_32= data %>% filter(data$bin =='30-35')
data_45= data %>% filter(data$bin =='42-47')

by(data = data$measurement, INDICES = data$visibility, FUN = shapiro.test)

t.test(data_lVis$measurement~data_lVis$bin, paired=TRUE)
t.test(data_hVis$measurement~data_hVis$bin, paired=TRUE)
t.test(data_no$measurement~data_no$bin, paired=TRUE)

wilcox.test(measurement~bin, data = data_lVis, paired = TRUE)
wilcox.test(measurement~bin, data = data_hVis, paired = TRUE)
wilcox.test(measurement~bin, data = data_no, paired = TRUE)

plot(data_lVis$measurement~data_lVis$bin)
boxplot(data_lVis$measurement~data_lVis$bin)

ezStats(data=data, dv=measurement, wid=ID, within = bin)

ezStats(data=data_no, dv=measurement, wid=ID, within = bin)

# Plotjes -----------------------------------------------------------------
par(mfrow=c(1,1))


  #voor elke visibility 1 KADUUK
ggplot(data=data_hVis, aes(x=bin, y = measurement, fill = delay)) +
  geom_boxplot_pattern(aes(pattern=delay), pattern_fill='black', pattern_density=0.01, pattern_spacing=0.05, patern_angle=45)+
  scale_pattern_manual(values=c('wave', 'stripe'))+
  labs(title = 'A) clearly visible dots') +
  ylab('Proportion response') +
  xlab('Around angle (degrees)') +
  scale_fill_manual(values=c("#FF6666", "#CC0000")) +
  ylim(c(0,0.4)) +
  scale_x_discrete(label = c("32","45"))+
  theme(legend.justification=c(0,0), legend.position=c(0,0.85)) +
  guides(fill=guide_legend(title=NULL))

ggplot(data=data_lVis, aes(x=bin, y = measurement, fill = delay)) +
  geom_boxplot_pattern(aes(pattern=delay), pattern_fill='black', pattern_density=0.01, pattern_spacing=0.05, pattern_angle=45)+
  scale_pattern_manual(values=c('wave', 'stripe'))+
  labs(title = 'B) barely visible dots') +
  ylab('Proportion response') +
  xlab('Around angle (degrees)') +
  #geom_dotplot(binaxis='y', stackdir='center', dotsize = 0.4) +
  scale_fill_manual(values=c("#99FF66", "#33CC33")) +
  ylim(c(0,0.4)) +
  scale_x_discrete(label = c("32","45")) +
  theme(legend.justification=c(0,0), legend.position=c(0,0.85)) +
  guides(fill=guide_legend(title=NULL))


ggplot(data=data_no, aes(x=bin, y = measurement, fill = delay)) +
  geom_boxplot_pattern(aes(pattern=delay), pattern_fill='black', pattern_density=0.01, pattern_spacing=0.05, pattern_angle=45)+
  scale_pattern_manual(values=c('wave', 'stripe'))+
  labs(title = 'C) invisible dots')+
  ylab('Proportion response') +
  xlab('Around angle (degrees)') +
  #geom_dotplot(binaxis='y', stackdir='center', dotsize = 0.4) +
  scale_fill_manual(values=c("#00CCFF", "#3366FF")) +
  ylim(c(0,0.4)) +
  scale_x_discrete(label = c("32","45")) +
  theme(legend.justification=c(0,0), legend.position=c(0,0.85)) +
  guides(fill=guide_legend(title=NULL))

  #voor perceptie en stm 1
ggplot(data_per, aes(x=bin, y = measurement, fill = visibility)) +
  geom_boxplot() +
  labs(title = 'proportions in perception')

ggplot(data_stm, aes(x=bin, y = measurement, fill = visibility)) +
  geom_boxplot() +
  labs(title= 'proportions in stm')

  #voor elke bin 1
ggplot(data=data_32, aes(x=delay, y = measurement, fill = visibility)) +
  geom_boxplot()+
  labs(title = '32 bin')
ggplot(data=data_32, aes(x=delay, y = measurement, fill = visibility)) +
  geom_boxplot()+
  labs(title = '45 bin')



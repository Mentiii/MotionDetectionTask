# MotionDetectionTask
This task is used to test memory and perceptual illusions.

**ABSTRACT**
Our experience of the world is shaped by expectations. If something happens a lot, a bias towards that thing happening forms. This can alter the report of an experience if the expectations are not lived up to. However, it is unclear if this altered report is the perception of the experience itself, or the effect of a small delay creating an illusionary memory at the recall. In this research, participants see moving dots and have to determine their direction of movement. An expectation is created with a bias towards an 32° angle. Sometimes, no dots were present, but participants answered confidently nevertheless. These trials are the illusionary reports. Here we show that the patterns in illusionary reports follow the same pattern as the valid reports, with dots present. A delay variable was added to compare perceptual and memory illusions. An interesting finding is the significant difference between answers around 35° and 45° in the barely visible dots. There seems to be an already existing bias towards 45°, overruling our induced bias of 32°. Any diagonal line might be interpreted with a bias towards the ‘ultimate diagonal’ of 45°.  

**How to run the task? **
This code is written in PsychoPy v2023.2.3.
Make sure the excel file 'stimuli_MDT' is downloaded. Windowsettings can be adjusted in line 66. 

Part 1 t/m 4 are together the whole task. Run them sequentally (remember to use the same participant number!) and restart PsychoPy in between parts to empty the RAM. 

**How to analyse the data**
1. 'Analyse_individual.R'
  Use this script to write the table_allBins in excel for every participant and check for the exclusion criteria. -> input the seperate participants from allData
3. Excel
  Use excel to calculate the the proportions for every bin in each condition, just as in data_processed4
4. JASP
  Do the repeated measureres ANOVA in JASP -> input data_processed4
5. 'post_hoc.R'
  This script does post-hoc paired t-tests (and the non-parametric equvalent) on the main effects from the ANOVA -> input data_short_long
6. 'analyse_alldata.R'
  This script gets all the raw (every trial, every participant) data as input and generates plots. -> input allData
   

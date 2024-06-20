# MOTION DETECTION TASK
# The motion detection task is designed to distinguish a perceptual illusion of movement from a stm illusion. 
# Participants will see the two conditions in random order and have to decide in what way the dots were moving 
# after a long or short delay. This is followed by a question about their certainty to measure if they perceived/remembered 
# seeing moving dots. 

#part 4 has 38 Nreps and consists of trial 685 t/m 912

# IMPORT
import pandas as pd
import random as rand
import numpy as np
import ast
import os
import sys
import gc
from math import atan2, degrees
from psychopy.gui import DlgFromDict 
from psychopy.core import quit, wait, Clock, getTime, CountdownTimer
from psychopy.visual import Window, TextStim, RatingScale, Circle, ShapeStim, ElementArrayStim, GratingStim
from psychopy.hardware.keyboard import Keyboard
from psychopy.event import Mouse, globalKeys, clearEvents, getKeys
from psychopy.data import getDateStr

# PARTICIPANT INFORMATION 
N_REPS = 38 #How often will every condition happen 152 totaal
trialcounter = 685

    # Dialog box
rand_nr = rand.randint(1,1000)  #Is het nodig om te zorgen dat er geen dubbele getallen ontstaan?
exp_info = {'Participant number': rand_nr, 'Session': '4', 'Age': '', 'Gender': ["Female", "Male", "X"]}
dlg = DlgFromDict(exp_info, title='Participant information', sortKeys=False) 

    # Check input
if not dlg.OK: # Actually canceling when cancel is pressed in dialog box
    print("User pressed 'Cancel'!") 
    quit()      ##import
else:    
    # Quit when either the participant nr or age is not filled in
    if not exp_info['Participant number'] or not exp_info['Age']: #WERKT NIET, doet wel quit maar niet print
        print("Please fill in everything.")
        quit()

    #Quit when age is unrealistic
    if not exp_info['Age'].isdigit(): #works
        print("Age should be a number")
        quit()
    age = int(exp_info['Age'])
    if age < 18 or age > 100:    #works
        print("Please try again with your real age")
        quit()
    else:
        print(f"Started experiment for participant {exp_info['Participant number']} " # uses F-string
                 f"with age {exp_info['Age']}.")

    # Save information
age = int(exp_info['Age'])
ID = int(exp_info['Participant number'])
gender = str(exp_info['Gender'])
sessnr = int(exp_info['Session'])
date = getDateStr()
expName = 'MDT'

# WINDOW        TODO Ik zou de window graag voor de dialog box doen, maar dan doet mn window raar...
backgroundColor= (-1,-1,-1)
win = Window(size=(2560,1440), fullscr=False, color=backgroundColor, monitor= 'menthes laptop', units='pix')  #size=(2560,1440) op lab pc. (1920,1080) op laptop

width = win.size[0]; # get horizontal screen size in pix
height = win.size[1];   # get vertical screen size in pix


#Deg to pixel   
DEG = 50    # 1 deg = 50 pix in Chalk
unit = width/DEG

# INITIALIZING
mouse=Mouse(win = win, visible = False) #makes mouse invisible TODO werkt niet
global_clock = Clock()
kb = Keyboard('getKeys')
fix_target  = TextStim(win, text='+')
rt_arrow = 0
t_break = 0
total_block_deviation = 0
counter_visible_trials = 0
muisx = width/2 + 10
muisy = 0
muisPos = (muisx,muisy) #(1400,-800) op lab PC. (1000, -550) op laptop
def isDivisible(number, divisor):
    return number % divisor == 0

# DATA FILE
_thisDir = os.path.dirname(os.path.abspath(__file__)) # Ensure that relative paths start from the same directory as this script
os.chdir(_thisDir)
filename = _thisDir + os.sep + u'data/%s_%s' % (expName, ID) #als sessienummer erbij u'data/%s_%s_%s' % (expName, ID, sessnr)


# WELCOME SCREEN
mouse.setPos(newPos=muisPos) #muis buiten beeld
welcome_txt = TextStim(win, text="""Welcome again!

You are always allowed to stop, without any reason given. 

Press enter to see the instructions. """, font='Calibri', color=(1,1,1))
welcome_txt.draw()
win.flip()
mouseVisible = False

while True: #wait till enter press
    keys = kb.getKeys() 
    mouse.setPos(newPos=muisPos) #muis buiten beeld
    if "return" in keys:
        break
        

    #Instructions 
mouse.setPos(newPos=muisPos) #muis buiten beeld
instruct_txt_stim= TextStim(win, text="""In this experiment, you will see a circle with moving dots in it. It is your task to determine the direction they are going. After the dots, a red line will appear. 
This line can be set in the right correction through scrolling with your mouse. Confirm your decision with a mouse click. 

However, it will be hard to notice the dots. Therefore, you will be asked how confident you are about your answer. 

You can now ask questions if something is unclear.
Press ‘u’ to start the experiment!"""
, alignText='left', color='white')
instruct_txt_stim.draw()
win.flip()

while True: #wait till 'u' press
    keys = kb.getKeys() 
    mouse.setPos(newPos=muisPos) #muis buiten beeld
    if "u" in keys:
        break

    #conditions
cond_df = pd.read_excel('stimuli_MDT.xlsx') # import excel with conditions
trial_clock=Clock()

print(cond_df)

t9=trial_clock.getTime() #begintijd


#Dingen die ik uit de loop gehaald heb
    #break

    #bolletjes
diameter_circle = 7 * unit
radius_circle = diameter_circle/2
opp_circle = radius_circle * radius_circle * np.pi
circleColor = [-0.8,-0.8,-0.8]
dots_density = 2 # amount of dots in every square degree aka 50 pix^2
num_dots = int(opp_circle/(DEG*DEG) * dots_density)
dot_size = 7 # todo dit lijkt te snel te zijn voor de refresh rate van het scherm, refreshrate is 60Hz, is niet aangepast aan chalk
dot_speed = 10
dot_presentation_time = 2 #seconds
    #background
background = Circle(win, radius=diameter_circle, units = 'pix', fillColor=circleColor) #chalk: 5.2 cd/m^2
ring = Circle(win, size = diameter_circle*2, lineColor = backgroundColor, opacity = 1, lineWidth=50, interpolate = True, fillColor = None) #makes sure the dots dissapear smoothly
    #direction
arrowVertLinks = [(0.2,0.02),(0.2,-0.02),(-0.2,-0.02), (-0.2,0.02)] #[(0.2,0.05),(0.2,-0.05),(0,-0.05),(0,-0.1),(-0.2,0),(0,0.1),(0,0.05)] # arrow to the left
    #Confidence


#LOOP

for _ in range(N_REPS):
    cond_df = cond_df.sample(frac=1) # alle rijen door elkaar gooit
    for idx, row in cond_df.iterrows():
        breakTime = isDivisible(trialcounter,20)# fill in after how many trials a break follows (first round x -1 becauese counter starts at 1)
        if breakTime: #elke x trials feedback
            mouse.setPos(newPos=muisPos) #muis buiten beeld
            t5=trial_clock.getTime()
            feedback = total_block_deviation/counter_visible_trials
            break_txt = TextStim(win, text=f"Time for a break! \n Your average deviation is {feedback:.0f} degrees. \n Press 's' when you are ready to continue", font='Calibri', color=(1,1,1)) 
            break_txt.draw()
            win.flip()

            while True: #wait till s press
                keys = kb.getKeys() 
                if "s" in keys:
                    total_block_deviation = 0
                    counter_visible_trials = 0
                    break
            t6=trial_clock.getTime()
            t_break = t6-t5

        #BIAS
        randNumber = rand.random() # get a number between 0 and 1
        if randNumber < row['bias']:
            dot_dir = rand.choice([328, 32])
            biased = 'Biased'
        else:
            dot_dir = rand.choice([300, 312, 344, 0, 16, 48, 60])
            biased = 'notBiased'
        dot_dir_rad=dot_dir*0.017453 #convert from degrees to radials
        print(f"the direction of the dots is {dot_dir}")
        
        #DOTS 
        # Parameters
        condition = row['condition']
        dot_color_str = row['dot_color']  #A string like '[-0.5,-0.5,-0.5]' row['dot_color'] 
        dot_color = ast.literal_eval(dot_color_str)  # Evaluates the string literal to a list of floats
        if condition == 'estimation_per' or condition == 'estimation_stm':
            dot_color = circleColor
        dot_colors = [dot_color] * num_dots  # Repeat the color for each dot

        # Create dot positions
        dot_positions = np.zeros((num_dots, 2))
        dot_positions[:, 0] = np.random.uniform(-diameter_circle, diameter_circle, size=num_dots)  # X positions
        dot_positions[:, 1] = np.random.uniform(-diameter_circle, diameter_circle, size=num_dots)  # Y positions

        # Create dot stimulus
        dots = ElementArrayStim(
            win=win,
            nElements=num_dots,
            sizes=dot_size,
            elementMask='circle',  # Shape of the dot
            xys=dot_positions,
            units='pix',
            fieldSize=diameter_circle,
            elementTex=None,
            colors=dot_colors
        )

        # Making the dots move
        start_time = getTime()  # Record the start time
        t7=trial_clock.getTime()
        while getTime() - start_time < dot_presentation_time:  # Run for x seconds
            # Move dots in the specified direction
            dot_positions[:, 0] += dot_speed * np.cos(dot_dir_rad)
            dot_positions[:, 1] += dot_speed * np.sin(dot_dir_rad) 
            
            # Wrap dots around the circular region
            distance_from_center = np.sqrt(dot_positions[:, 0]**2 + dot_positions[:, 1]**2)
            out_of_range = distance_from_center > (diameter_circle - 1e-6) #small adjustment magiscally makes this work
            
            # Make dots outside the circle invisible
            dot_opacities = np.ones(num_dots)  # Initialize all opacities to 1 (fully visible)
            dot_opacities[out_of_range] = 0  # Set opacity to 0 for dots outside the circular region
            dot_positions[out_of_range, :] *= -1 #reappear at the other side
            
            # Updates
            dots.setOpacities(dot_opacities)
            dots.setXYs(dot_positions)
            
            # Draw and flip
            mouse.setPos(newPos=muisPos) #muis buiten beeld
            background.draw()
            dots.draw()
            ring.draw()
            win.flip()
            mouseVisible = False
        t8=trial_clock.getTime()
        t_stim = t8-t7
        
        # Delete dot stimuli after use
        del dots
        gc.collect()

            #DELAY
        mouse.setPos(newPos=muisPos) #muis buiten beeld
        t11=trial_clock.getTime()
            #noise
        #noiseTexture = np.random.rand(128,128) * 2.0 - 1
        #patch = GratingStim(win, tex=noiseTexture,size=(diameter_circle, diameter_circle), units='pix',interpolate=False, autoLog=False, mask="circle")
        timer = CountdownTimer(row['delay_length'])
        while timer.getTime() > 0:  
            #phase_increment = np.random.uniform(-0.1, 0.1, size=2)
            #patch.phase += phase_increment
            #patch.draw()
            mouse.setPos(newPos=muisPos)
            fix_target.draw()
            win.flip()
        #wait(row['delay_length'])
        t12=trial_clock.getTime()
        t_delay=t12-t11

            #DIRECTION
        orientBegin = rand.randint(0,360)
        print(f"orientbegin = {orientBegin}")
        arrow = ShapeStim(win, vertices=arrowVertLinks, fillColor='darkred', size=500, lineColor='red', pos=[0.0], ori=orientBegin)
        t0= trial_clock.getTime()
        orientNow = orientBegin
        orientNow = 360 - orientNow # fixen dat de de graden goed lopen
        while True:
            mouse.setPos(newPos=muisPos) #muis buiten beeld
            arrow.draw()
            win.flip()
            wheel_dX, wheel_dY = mouse.getWheelRel()
            orientNow = orientNow + 5*wheel_dY
            arrow.setOri(orientNow)
            keys=kb.getKeys()
            #Confirm direction with mouse click
            if mouse.getPressed()[0]: 
                # measure reaction time
                t1=trial_clock.getTime()
                rt_arrow = t1-t0 
                # Correct for turning a lot
                while orientNow >= 360: 
                    orientNow = orientNow - 360
                    continue
                while orientNow <= -360:
                    orientNow = orientNow + 360
                    continue
                if orientNow < 0:
                    orientNow = orientNow + 360 # correct negative numbers to positieve
                    continue
                orientNow = 360 - orientNow
                print(f"orientNow = {orientNow}")
                # zorgen dat altijd het rechter uiteinde gemeten wordt
                if orientNow >90 and orientNow <180:
                    orientNow_R = orientNow + 180 
                elif orientNow >180 and orientNow <270:
                    orientNow_R = orientNow - 180
                else:
                    orientNow_R = orientNow
                print(f"orientNow_R na correctie = {orientNow_R}")
                
                #Calculate difference
                arrow_deviation_abs = abs(dot_dir-orientNow_R) 
                    # zorgen dat 259 orientNow bij 0 dit_dir als afwijking 1 geeft ipv 259)
                if arrow_deviation_abs <= 180: #max hoek is 180 graden, maar dit is op de huidige manier onnodig want alles omgezet naar rechter helft :)
                    arrow_deviation = arrow_deviation_abs
                else:
                    arrow_deviation = 360 - arrow_deviation_abs
                print(f"deviation: {arrow_deviation}")
                
                # Delete arrow stimuli after use
                del arrow
                gc.collect()
                break 

            # CONFIDENCE MEASURE
        mouse.setPos(newPos=(0,-0.25*height)) #muis in beeld
        clearEvents()
        myRatingScale = RatingScale(win, labels=['not confident', 'confident'], marker='circle', high= 4, low= 1, scale=None) #scale
        myItem = TextStim(win, text="How confident are you of your answer?", height=1*unit, units='pix') #question
        t2=trial_clock.getTime()
        while myRatingScale.noResponse:  # show & update until a response has been made
            myItem.draw()
            myRatingScale.draw()
            win.flip()
            mouseVisible = True
        t3=trial_clock.getTime()
        rt_confidence = t3-t2
        confidence = myRatingScale.getRating()
        
        # Bias deviation
        bias_deviation = 1 #waarde geven tegen error
        if condition == 'estimation_per' or condition == 'estimation_stm': 
            #positief (32 graden)
            bias_pos_deviation_abs = abs(32-orientNow_R)
            if bias_pos_deviation_abs <= 180: #max hoek is 180 graden
                bias_pos_deviation = bias_pos_deviation_abs
            else:
                bias_pos_deviation = 360 - bias_pos_deviation_abs
                
            #zelfde voor bias van -32 aka 328 graden
            bias_neg_deviation_abs = abs(328-orientNow_R)
            if bias_neg_deviation_abs <= 180: #max hoek is 180 graden
                bias_neg_deviation = bias_neg_deviation_abs
            else:
                bias_neg_deviation = 360 - bias_neg_deviation_abs
                
            #kleinste kiezen
            if bias_neg_deviation <= bias_pos_deviation:
                bias_deviation = bias_neg_deviation
            else:
                bias_deviation = bias_pos_deviation
                
                
        #bereken de richting van de bias in het antwoord wnr dots aanwezig zijn
        else: 
            if biased == 'Biased':
                bias_deviation = abs(orientNow_R - dot_dir) * -1 #if the dots are in bias direction, every deviation is off bias
            bias_deviation = orientNow_R - dot_dir
        print(f'bias_deviation: {bias_deviation}')
            
                    #Fill in data
        if condition != 'estimation_per' and condition != 'estimation_stm': 
            total_block_deviation = total_block_deviation + arrow_deviation
            counter_visible_trials = counter_visible_trials + 1
        t10=trial_clock.getTime() #eindtijd
        tot_t = t10-t9
        
        # Save condtion the easy way
        #Dots
        if condition == 'estimation_per' or condition == 'estimation_stm':
            Dots = 'NoDots'
        if condition == 'detection_per'or condition == 'detection_stm':
            Dots = 'HighVisible'
        if condition == 'contrast_per' or condition == 'contrast_stm':
            Dots = 'LowVisible'
        #Delay
        if condition == 'estimation_per' or condition == 'detection_per' or condition == 'contrast_per':
            Delay = 'NoDelay'
        else:
            Delay = 'Delay'
        
        with open(filename, 'a', encoding='utf8') as fp: 
            fp.write('%i %i %s %i %s %s %s %s %s %i %i %f %f %f %i %i %i %f %f %f %f %f %f \n' % (
                    ID, age, gender,sessnr, date, condition, Dots, Delay, biased, trialcounter, dot_dir, rt_arrow, orientNow, orientNow_R, orientBegin, arrow_deviation, bias_deviation, confidence, rt_confidence, t_break, t_stim, t_delay, tot_t)) #indent gooien 263
        
        trialcounter = trialcounter + 1
        mouse.setPos(newPos=muisPos) #muis buiten beeld

        # Print what happened
        print('Rating =', myRatingScale.getRating())
        print('condition:', row['condition'])
        
        #delete stuff
        del condition
        del Dots
        del Delay
        del biased
        del dot_dir
        del rt_arrow
        del orientNow
        del orientNow_R
        del orientBegin
        del arrow_deviation
        del bias_deviation
        del confidence
        del rt_confidence
        del t_stim
        del t_delay
        del myRatingScale
        del myItem
        gc.collect()


#screen with thanks
mouse.setPos(newPos=muisPos) #muis buiten beeld
bye_txt = TextStim(win, text="""THE END

Thank you for participating in this experiment!!! 

Please call the researcher to wrap it up. 

""", font='Calibri', color=(0.5,0.5,0))
bye_txt.draw()
win.flip()
while True: #wait till enter press
    keys = kb.getKeys() 
    if "r" in keys:
        break

# END EXPERIMENT
win.close()
quit()
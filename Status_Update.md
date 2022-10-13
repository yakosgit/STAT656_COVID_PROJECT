# Task #2 Feynman Method



# Step 1: 
ToDelete (Write down clearly and concisely what you are trying to learn. Don't write down jargon and be as specific as is reasonable.)

- We want to learn how to interpret a calibration plot to compare our predicted probabilities with the relative frequency of events in our data. The goal in doing this is to assess whether or not our predicted probabilities are “well-calibrated” to the underlying true probabilities of our event.

# Step 2: 
ToDelete (Explain the concept in simple language.  Be on the lookout for moments in which you use terminology from this class.  Seek to use the definition instead.  Include a very simple example demonstrating the underlying idea.)

- When doing a classification model, many times we will be modeling the probability of the event. While we don't know the true probability of Y given a value(s) of the predictor variable(s), we want the predicted probabilities from our model to align with the unknown truth. To estimate how well these align, we can compare a given predicted probability from our model with the proportion of events from the observations with that predicted probability. To make this easier to plot as we may not have any observations at a given probability estimate, we bin the observations much like we do when making a histogram. To create our plot we bin the probabilities and plot the midpoint of the bin against the proportion of events from the observations with estimated probabilities that fall into that bin. A calibration plot with a 45 degree line would indicate “perfectly calibrated” probabilities.

![image](https://user-images.githubusercontent.com/73800545/195630616-1dafdcfc-b6ba-4e3a-81ed-b36e01be0337.png)

<sub> *Chapter_11_Measuring_Performance_in_Classification_Models/Ch11Fig01 https://github.com/topepo/APM_Figures/blob/master/Chapter_11_Measuring_Performance_in_Classification_Models/Ch11Fig01b.pdf* 

# Step 3: 
ToDelete (During the course of 2, you'll run into moments where your explanation is vague or there is something you don't understand or can't relay using non-technical language.  Identify these moments here, using a list.)

### 1. What does it mean to bin the probabilities for plotting?
### 2. Why is a 45 degree line a "perfect" calibration?

# Step 4: 
ToDelete (Seek to solidify these concepts. Go back to your notes or ask in a live session or post to the discussion board) 

### 1. What does it mean to bin the probabilities for plotting?
- Many times we either won't have an observation that corresponds to every probability estimate or we will just have one observation. When there is no observation, we won't have a point to plot. When there is only one observation, we will have a point to plot, but the observed proportion of the event will be either 0 or 1 and will lead to a plot that is not very informative. To account for this, we "bin" the probabilities by looking at ranges like 0%-10%, 10%-20%, etc. When we do this, we get a number of observations with predicted probabilities that fall into a given range. To create the plot, we plot the midpoint of the bin against the proportion of events from the observations that fall into that bin.

### 2. Why is a 45 degree line a "perfect" calibration?
- Following the method outline above, you would get a 45 degree line in your calibration plot if the midpoint of a given bin and the proportion of successes of the observations that fall into that bin are equal. This would indicate that the calibrated probabilities from the model align with the frequencies from the observed data. If you produce a calibration plot that doesn't follow the 45 degree line, that is not necessarily a bad thing. Rare events may cause deviations in the upper probability--you may not have any observations in your data where the probability of success is high.







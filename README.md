# RCB_app
## Shiny application created for easier usage of the TES method  

## The inputs
### Method selection
For the calculation you can use one of the following methods:
* Weighted Kolmogorov-Smirnoff test for two samples - the main TES method that proved to produce the best results.
* Density ratio of RCB scores from two treatments.
* Density difference of RCB scores from two treatments.
### The data
For both of compared treatments you can change the name. By default, the treatments are called control (the one other is compared with) and experimental.  
The files with the RCB scores must be text files. What is more, they should contain uncategorised RCB scores - there cannot be any letters or numbers out of the range between 0 and 10. The file should not contain only integers - this will be read by the application as categorised data and treated as a mistake. The only exception is the situation when all the results are equal to 0. If there are some errors detected while loading the data, you will be notified with appropriate message. If you would like to take a look at exemplary data first, please tick the checkbox prepared for this.
## Running the application
After specifying the desired input, click the "Caclute" button. This will runn the proper calculations, freezing the possibility to click the button again. However, you can still change the input in the meantime, if you wish - just remember to click the button again after the end of the calculations.
## The outputs
In the application window you can see two types of outputs based on the provided data:
* Short description of the input scores:  
In the side panel of the application there are the number of scores from each treatment.  
In the tab "The data" you can see the whole scores from loaded treatments.  
* The calculation results:
In the tab "The plot" you can see the plots for the input scores: Density functions as well as weighted eCDF difference between treatments. Above them both TES value and its p-value are provided. You can download all this data by the usage of the "Download the plot" button.
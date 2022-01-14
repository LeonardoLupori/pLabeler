# pLabeler  
*A* MATLAB *software for labeling pupil images.*

> ### How to use it guide in the [pLabeler wiki](https://github.com/LeonardoLupori/pLabeler/wiki)

> ### Check out [pupillometry.it](https://www.pupillometry.it) for a ready-to-use web-based mEye pupillometry tool!  

> ### For training your own model checkout the original [MEYE repo](https://github.com/fabiocarrara/meye/)

![pupil](https://user-images.githubusercontent.com/39329654/147874854-8dddfa88-562d-4a03-85f8-68702507153a.gif)

*pLabebeler* is a tool designed to ease the process of labeling pupil images in order to train a convolutional neural network for pupil segmentation [MEYE](https://github.com/fabiocarrara/meye).  
The CNN is currently working with human and mouse eyes and you can use it for free at [pupillometry.it](https://www.pupillometry.it), however we hope to improve both its performances and its use-cases by increasing the training dataset with more images of more species.  
For this we need also *your* help!

## Requisites
The software have been tested on: 
- MATLAB 2021a
- MATLAB 2021b

The Image Processing Toolbox is required

## Installation
1. **Download the software**  
You can download the software: 
    - manually, by clicking the green button in the top right corner of the repo and select the *Download ZIP* button,
    - automatically, by cloning this repo in a location of your choice. To do this you will need to have [git](https://git-scm.com/) installed.  
    Navigate to the folder where you want to install the software. For example to install it in the MATLAB folder in my computer:

            cd C:\Users\Leonardo\Documents\MATLAB

        Clone the repository:

            git clone https://github.com/LeonardoLupori/pLabeler.git

2. **Add the folder to your MATLAB path**  
You can do this in one of three ways:  

    1. Inside MATLAB, just navigate inside the folder where you downloaded the software. In this way, you will be able to launch the labeler, however, you need to be in the pLabeler folder in order for the software to keep working.

    2. Inside MATLAB, right click on the folder where you downloaded the software and select: *Add to path* > *Selected Folders and Subfolders*.  
    This will allow the software to work from indipendently from your *Current Folder*, however you will need to re-add the folder to your path every time you re-start MATLAB. To permanently add the folder to the MATLAB path use option 3.

    3. Inside MATLAB, under th *Home* tab, click on the *Set Path* button. Click *Add with Subfolder* and select the folder where you downloaded pLabeler. Then *Save* your changes.

## Usage
To run the application, type in the command window:

    pLabeler;

A detailed user guide on how the software works and how to use it can be found in the [pLabeler wiki](https://github.com/LeonardoLupori/pLabeler/wiki)

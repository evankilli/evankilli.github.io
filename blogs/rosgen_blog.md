---
layout: page
title: Replication of Rosgen Stream Classification Analysis
---

## Background

This analysis is a replication of two analyses. [The original, performed by David Rosgen](https://linkinghub.elsevier.com/retrieve/pii/0341816294900019), took information from studies of multiple river systems to devise a classification scheme based on a number of factors, including the width of the valley and of the river when full, slope, and even particle size of material (e.g. pebbles, sand) on the riverbed. The second was [a study conducted by Alan Kasprak, et. al.](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0150293), which applied Rosgen's framework to Oregon's John Day River.

In conducting this analysis, students like myself were assigned points from Kasprak's study at random to study. Through open source GIS and analytical tools like R/RStudio and GRASS GIS, we attempted to use data from the [Columbia Habitat Monitoring Program](https://www.champmonitoring.org/) - a project aiming to generate a standard set of fish habitat monitoring methods in and around the Columbia River, LIDAR DEMs at 1m resolution, and models developed from these data to gather sufficient data for analysis.

## Sampling Plan and Data Description

As stated earlier, each student conducting this analysis was assigned a data point from Kasprak's analysis in the CHaMPs data. My designated location was at loc_id=4, and two sampled points existed, from which I chose at random.

## Materials and Procedure  

In performing this analysis, we followed workflows pre-prepared by ASU Geography PhD candidate Zach Hilgendorf in collaboration with Middlebury College assistant professor Joseph Holler, working in both GRASS GIS and RStudio. The workflow followed in grass is linked [here](https://github.com/evankilli/RE-rosgen/blob/main/procedure/protocols/1-Research_Protocol_GRASS.pdf), the code run in RStudio is linked [here](https://github.com/evankilli/RE-rosgen/blob/main/procedure/code/2-ProfileViewer.Rmd), and the instructions for running the code in RStudio and eventually classify the stream at the assigned point are provided [here](https://github.com/evankilli/RE-rosgen/blob/main/procedure/protocols/3-Classifying.pdf).

Unfortunately, in working with Prof. Holler and other students enrolled in this course, we discovered that we were unable to properly unzip the DEM data, requiring the use of a tool like [Unarchiver](https://theunarchiver.com/), and issues arose installing tools within RStudio, requiring the installation of [XCode](https://developer.apple.com/download/more/?=for%20Xcode) within Apples developer tools.

Some tools created by Prof. Holler used in this analysis are included here:
- [Centerlines tool](procedure/code/center_line_length_no_clip.gxm)
  - note: due to strange geography of the river at the assigned study site, a center line tool that *does not clip* is used here, requiring extra attention to ensure comparable lengths for the valley and stream centerlines. An additional tool that *does clip* can be found [here](procedure/code/center_line_length.gxm)

## Replication Results

STILL MUST FINISH

---
Title: Spatial Twiiter Analysis
Layout: Page
---

In their study of Twitter activity surrounding wildfires, Wang et al (2016) queried a significant amount of twitter data, both a set directly related to some keywords related to the 2014 Southern California wildfires, and a generalized set of tweets used to normalize and account for baseline Twitter activity for the given time period and region. The authors found two significant patterns in the spatial and temporal distributions of tweets: 1) tweet times closely corresponded to event times, with peaks often slightly after an event to accounted for by the time needed to disseminate information and take any necessary precautions (e.g. evacuations), and 2) that tweets largely corresponded spatially with event locations, with higher densities of tweets generally found around fire locations. The authors did an effective job overall of communicating their findings graphically, with a number of clear, concise graphics detailing the spatial, temporal, and content-based characteristics of the queried tweets. Especially effective was a graphic showing the links between user "nodes" and "opinion leader" cores, with these links representing retweets of original tweets by users. This graphic clearly and efficiently showcased the importance of a relatively small collection of sources of information - a small handful of local new sources and the San Diego County government - in providing information during this crisis.

Given a fairly clear description of the methods used, I'd bet that this would not be incredibly difficult to replicate, with this model being easily altered to fit different contexts based on different queries in Twitter's API. Unfortunately, however, I'm unsure about the reproducibility of this study. While the methodology was generally clearly written, important uncertainties are still present. Concerning the textual analysis, "stop words" - a seemingly important part of filtering tweet content for analysis - are never fully explained or defined, and it would be hard to reproduce this study without knowing how exactly to apply this step in the analysis.

## Reference

Wang, Z., X. Ye, and M. H. Tsou. 2016. Spatial, temporal, and content analysis of Twitter for wildfire hazards. Natural Hazards 83 (1):523–540.

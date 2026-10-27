---
layout: page
title: Network Analysis of the Connectict Pizza Trail
description: An R-based network analysis of CT Pizza Trail locations
# img: assets/img/12.jpg
# importance: 1
category: personal
# related_publications: true
---

## The Introduction

As many, if not all, of my friends will gladly let you know, I've always considered myself a particularly proud Nutmegger, our colloquial term for someone from the state of Connecticut (and much easier to say and spell than *Connecticuter* or *Connecticutian*). Like all of my maternal family going back many generations, I was born in the silk-producing Central Connecticut mill town of Manchester and grew up a short few miles away in Tolland. We're nerdier than we'd like to admit about local history, avid watchers and runners of our local Manchester Road Race, religious fans of UConn women's basketball, and - important to this proejct - pizza fiends. 

Connecticut may often get stuck with the impressions of Interstate 84 travellers and those exposed to our plentiful lax bro exports, but the state is a remarkably pleasant one, with a beautiful shoreline, a central valley ringed with rolling hills and the outskirts of the Appalachian Mountains, and dotted with quaint towns and mill cities with their respective greens and industrial era main streets. We're often divided by our allegiances (cultural and athletic) to Boston and New York, but one thing we do share is our love for the queen of Italian American imports. Brought across the Atlantic in the tail end of the 19th century, [pizza in the US](https://en.wikipedia.org/wiki/Pizza_in_the_United_States) quickly gained a foothold in cities up and down the Eastern Seaboard and the many other cities and towns Italian immigrants found themselves calling their homes and went on to develop into nearly as many varieties as there were centers of the community. With its significant Italian American population, centered in the Southeastern part of the state and larger as a share of the population than in any other state <sup>[\*](https://en.wikipedia.org/wiki/Italian_Americans#Demographics)</sup>, Connecticut developed its own distinct varieties of the dish, and has become an underrated pizza Mecca, going so far as to develop and implement and [tourism and marketing campaign](https://portal.ct.gov/governor/news/press-releases/2025/02-2025/governor-lamont-connecticut-doubles-down-on-its-title-as-pizza-capital-of-the-united-states?language=en_US) around its self-anointed (and well-deserved) status as the country's *Pizza Capital*.

## The Pizza Trail

[![Official CT Pizza Trail Map](/assets/img/CTPizzaTrailMap.png)](https://ctvisit.com/articles/connecticut-pizza-trail)
<div class="caption">
    An official map of the Connecticut Pizza Trail developed by the Connecticut Office of Tourism.
</div>

One element of this initiative was the creation of the [Connecticut Pizza Trail](https://ctvisit.com/articles/connecticut-pizza-trail), with locations selected with the help of an "expert panel" and public voting. In the end, 121 pizzerias across the state were selected, representing five distinct styles of slice and polka-dotted across the state. These were:
- [Apizza](https://en.wikipedia.org/wiki/New_Haven%E2%80%93style_pizza): pronounced "uh-beetz" by the most die-hard traditionalists (something I've seen on signs but never really heard), this style is the creme de la creme of Connecticut pizza and characteristic of New Haven, but now found across the state. Hallmarks of this style include a deeply charred crust, pecorino cheese, and an often irregular shape. White clam pie (with fresh chopped clams, garlic, herbs, oil, and pecorino) is a particular local favorite
- [Greek pizza](https://en.wikipedia.org/wiki/Greek_pizza): a style most prevalent in inland southern New England (CT, RI, and MA), now found in many of its cities, and particularly identified with Greek-owned "Houses of Pizza" in the region's many small towns. Hallmarks of this style include a thick, spongy crust, grease, and plentiful gooey cheese 
- [Neapolitan pizza](https://en.wikipedia.org/wiki/Neapolitan_pizza): admittedly not a style particular to the state, this style is the OG, developed in Naples, Italy (the origin, along with Sicily, of many Italian Americans), and experiencing somewhat of a boom in the 21st century. Hallmarks include buffalo mozzarela and a very thin crust which becomes airy and bubbly around its edges
- Tavern style pizza: found in subvarieties across the country (MA's South Shore bar pie and New Jersey and Chicago's local thin-crust pizzas), with Connecticut in particular home to the "[hot oil pizza](https://www.foodigenous.com/post/stamford-hot-oil-pizza)". Hallmarks of this style include an exceedingly thin, sometimes crackery, crust with a lighter dusting of cheese and spread of sauce compared to other varieties and, for hot oil pizza, a drizzle of spicy-pepper infused oil for an extra oomph
- Thick crust pizza: less so a specific style, this is an umbrella which could include styles like [deep dish](https://en.wikipedia.org/wiki/Deep-dish_pizza), [Detroit](https://en.wikipedia.org/wiki/Detroit-style_pizza), [pan pizza](https://en.wikipedia.org/wiki/Pan_pizza), and [tomato pie/RI-style pizza strips](https://en.wikipedia.org/wiki/Italian_tomato_pie). Hallmarks include, well, a thick crust (and often a heavy helping of toppings and cheese)

As a GIS nerd and lover of lover of open-source data analysis, I decided to take it upon myself to develop maps of the closest official Pizza Trail joints to locations across the state. Trying to distill a plan from the thoughts running around my head, I came up with the following goals: a) the maps would be created with network analysis, showing the closest shop by travel time and not just the closest as the crow flies; b) I wanted to create web maps that my friends, family, and anyone else reading this could scroll around to locate themselves; c) I wanted an overall map **and** specific maps for the individual styles from the official map; and d) I wanted to venture beyond my comfort zone and try my hand at geospatial analysis in R and not just my usual QGIS. 

## The Map

If you're so inclined, you can read a bit more about the data I used, my methodology, and more musings towards the bottom of the page, but for the more casual viewer, the map below includes the location of the pizza joints officially designated as part of the Pizza Trail and the zone for which they are the closest location by driving. Click on the buttons in the top right corner to select whether you want to see all locations or just a specific style, and click on the icons to show the name and address (and style, if looking at all locations).

<iframe src="/assets/html/pizza_map/Pizza Trail Leaflet Map.html"
        width="100%" height="650"
        style="border:0;" loading="lazy"
        title="Connecticut Pizza Trail Map"></iframe>

## The Deeper Stuff

Coming soon, watch out for updates!


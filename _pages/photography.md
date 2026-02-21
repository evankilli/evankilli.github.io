---
layout: page
title: photography
permalink: /photography/
description: A small portfolio of film and other photography.
nav: true
nav_order: 5
display_categories: [2023, 2024, 2025]
horizontal: false
---

I first picked up a "real" camera - a Pentax K1000 - one summer many many years ago at Camp Calumet on the shores of Lake Ossippee up in New Hampshire. I don't remember much about any specific summer, just the general vibes, but I do know that after that, I almost *always* had a photography class filling one of my three daily activity slots. Eventually, I saved up enough money and BestBuy giftcards to grab myself a basic DSLR, and the rest is history!

I've gone through ebbs and flows, but I've tried to collect some of my work below. I've unfortunately lost a fair amount of my high school portfolio, but I've redeiscovered my love for taking pictures with the help of some old film cameras collected from various family members and the encouragement of one of my favorite cousins. I've tried my best to catalog photos by location and (if at a place I call "home") time of year. 

I try my best to not try too hard and just let myself take picture of whatever catches my eye in the moment - I have a particular penchant for interesting *texture*, transit and urban life, sharp lighting, juxtaposition, and the occasional item I just find silly.

<!-- pages/projects.md -->
<div class="projects">
{% if site.enable_project_categories and page.display_categories %}
  <!-- Display categorized projects -->
  {% for category in page.display_categories %}
  <a id="{{ category }}" href=".#{{ category }}">
    <h2 class="category">{{ category }}</h2>
  </a>
  {% assign categorized_photography = site.photography | where: "category", category %}
  {% assign sorted_photography = categorized_photography | sort: "importance" %}
  <!-- Generate cards for each project -->
  {% if page.horizontal %}
  <div class="container">
    <div class="row row-cols-1 row-cols-md-2">
    {% for project in sorted_photography %}
      {% include projects_horizontal.liquid %}
    {% endfor %}
    </div>
  </div>
  {% else %}
  <div class="row row-cols-1 row-cols-md-3">
    {% for project in sorted_photography %}
      {% include projects.liquid %}
    {% endfor %}
  </div>
  {% endif %}
  {% endfor %}

{% else %}

<!-- Display projects without categories -->

{% assign sorted_photography = site.photography | sort: "importance" %}

  <!-- Generate cards for each project -->

{% if page.horizontal %}

  <div class="container">
    <div class="row row-cols-1 row-cols-md-2">
    {% for project in sorted_photography %}
      {% include projects_horizontal.liquid %}
    {% endfor %}
    </div>
  </div>
  {% else %}
  <div class="row row-cols-1 row-cols-md-3">
    {% for project in sorted_photography %}
      {% include projects.liquid %}
    {% endfor %}
  </div>
  {% endif %}
{% endif %}
</div>

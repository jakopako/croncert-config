# Croncert config

This repository contains the configuration for [CrONCERT](https://croncert.ch). CrONCERT is a website that helps you find concerts worldwide. The data is gathered with [goskyr](https://github.com/jakopako/goskyr), a configurable
scraper written in go. Once a week goskyr runs through a Github action using `croncert-config.yml` as configuration file.

Despite the fact that there are other websites that offer an overview about concerts and events (such as <https://www.songkick.com/>, <https://www.jambase.com/>, etc.) I found none that are complete and/or include smaller event locations that might only be known to locals. That's why I came up with this idea.

## Idea

The idea of making this repository public is to enable others to contribute to the configuration file and hence expand
the data available on <https://croncert.ch>. I might have a good knowledge about concert locations in my home town but there are other poeple that know better about other towns. Everyone that has a basic understanding of programming and html/css should be able to extend the configuration file in order for the scraper to include more concert
locations.

## How to contribute

TODO

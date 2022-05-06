# Croncert configuration

This repository contains the configuration for [CrONCERT](https://croncert.ch). CrONCERT is a website that helps you find concerts worldwide. The data is gathered with [goskyr](https://github.com/jakopako/goskyr), a configurable
scraper written in go. Once a week goskyr runs through a Github action using `croncert-config.yml` as configuration file.

Despite the fact that there are other websites that offer an overview about concerts and events (such as <https://www.songkick.com/>, <https://www.jambase.com/>, etc.) I found none that are complete and/or include smaller event locations that might only be known to locals. That's why I came up with this idea.

## Idea

The idea of making this repository public is to enable others to contribute to the configuration file and hence expand
the data available on <https://croncert.ch>. I might have a good knowledge about concert locations in my home town but there are other poeple (you?) that know better about other towns. Everyone that has a basic understanding of programming and html/css should be able to extend the configuration file in order for the scraper to include more concert locations.

## How to contribute

If you know a concert venue that you'd like to add to [CrONCERT](https://croncert.ch) just fork the repository, add a new config snippet and open a pull request to merge the newly added snippet into the main branch. Have a look at the [README of goskyr](https://github.com/jakopako/goskyr) to make yourself familiar with the configuration syntax. Looking at the existing configurations might also give you some hints about how to write your own.

It is important that at least the fields `title`, `url`, `city`, `location`, `type`, `sourceUrl` and `date` are present. Optionally, a `comment` field can be configured (currently not shown on <https://croncert.ch>). If the mandatory fields are not present or additional new fields are configured then the scraper won't be able to send the data to the api that feeds the website. Also note, that `type` should be a static field with 'concert' as value and `city` should be a static field with the city name in English.

While writing a new config snippet you can continuously test it by running `goskyr -single <name> -config croncert-config.yml -stdout` (`goskyr` must be installed locally). This prints the items in json format to stdout instead of trying to write them to the croncert api. The latter wouldn't work anyways because you'd need to set the correct credentials as environment variables. Also it might be helpful to start with the config snippet provided by the `config-template.yml`.

## Limitations

There are still a few limititions that will be solved in the future and include the following but might not be limited to:

- currently, [goskyr](https://github.com/jakopako/goskyr) only supports static pages. Javascript is not beeing executed.
- a field of type date only supports one layout across all items of one concert location.
- a field (type `text` & `url`) can only have one selector across all items of one concert location.
- if you encounter any other bugs or limitations feel free to open an issue in the [goskyr](https://github.com/jakopako/goskyr) repo.

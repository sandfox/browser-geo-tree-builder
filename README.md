# csv2GeoJSON #

 A still largely unfinished cli tool to help convert CSV spreadsheets into usable KDTREE indexes with records so browsers can have simple geolocation functionality for small datasets without needing any moving parts on the backend.

 This was mostly developed to scratch an itch but feel free to improve.

 And yeah, it uses coffee-script, so get your hate on.

 Pull Request welcome.

## Installation ##

    $ [sudo] npm install -g csv2GeoJSON

## Usage ##

    $ csv2GeoJSON {ARGS}

Run without any arguements to see usage.

When supplied with just an in input file and output folder it will iterate over the CSV file and produce a file containing the KDTree index and then a json file for each record in the dataset.

For a suggestion on how to use these files look at this gist: https://gist.github.com/85f5ab526a9158b2cd30

## Recommendations ##

For small datasets (i.e few hundred records), it is probably worth outputting the data as a single file and loading the entire thing up asynchronously. For larger datasets or instances where each record is large then just load up the index.json and load the individual record files as required.

If you have a very dynamic dataset that changes frequently you may find this module is not so helpful. It was designed with static write-once, read-alot datasets in mind.

## Why ##

Becuase I can't stand the endless amounts of poorly written geospatital search implementations using PHP+Mysql that mostly don't use any kind of vaguely sensible indexing and bring needless complexity to the table. I also find MongoDB's geospatial to be a bit lacking and again has too many moving parts for what such a simple use case.



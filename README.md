Super simple command-line script for downloading a bunch of images from Twitter that match a given search term. This is just a script. It's not a gem, library, or even a class. Take it for what it's worth.

## Usage

```bash
$ gem install twitter
$ git clone REPOURL
$ cd REPONAME
$ ./twitter-image-search.rb seattle snow
```

The parameters are search terms using the Twitter Search API. For example, to get images from tweets with the hashtag `#snowpocalypse2012` that DO NOT include the word "seattle":

```bash
$ ./twitter-image-search.rb "#snowpocalypse2012 -seattle"
```

## Terms of Use

Use at your own risk. Be aware that (Twitter's API Terms of Service)[https://dev.twitter.com/terms/api-terms] prevent many things such as:

Exporting Twitter Content to a datastore as a service or other cloud based service, however, is not permitted.

I absolve myself from all responsibility for how you choose to use this tool.


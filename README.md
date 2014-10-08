
banners - a test application in Ruby
=======

Test live: http://calm-headland-8718.herokuapp.com/campaigns/2

## Requirements

You will be creating a web­application to serve banners for an advertising agency.

The web­app should be smart enough to render banners based on their revenue­performance.

You are given 4 sets of CSV files, each set contains the following files:

File | Content
---------------|--------------------------
impressions.csv | [:banner_id, :campaign_id]
clicks.csv | [:click_id, :banner_id, :campaign_id]
conversions.csv | [:conversion_id, :click_id, :revenue]

Based on these data, you should be able to determine how well a banner performs for a
campaign based on the revenue (which you can find in the conversions.csv)
Then there are a few possible scenarios:

Scenario: x = amount of banners with conversions within a campaign|Requirements:
------------- | -----------------------
x >= 10 | Show the Top 10 banners based on revenue within that campaign
| x.between?(5, 9) | Show the Top x banners based on revenue within that campaign |
| x.between?(0,4) | Your collection of banners should consists of 5 banners, containing: 1. The top x banners based on revenue within that campaign, 2. banners with the most clicks within that campaign to make up a collection of 5 unique banners. |
| x == 0 | Show the top­5 banners based on clicks. If the amount of banners with clicks are less than 5 within that campaign, then you should add random banners to make up a collection of 5 unique banners. |


So when a request hits your Campaign­URL, like
http://yourdomain.com/campaigns/{campaign_id}, it should somehow render or redirect to
one of your top­x banners.

The banners to be served are also attached in the email and you will see that the banner_id
will appear as text.

To avoid saturation, we also believe that the top banners being served should not follow an
order based on its performance, but they should appear in a random sequence.
You should also avoid that a banner will be served twice, before the sequence has finished for
a unique visitor.

And finally, the 4 sets of csv’s represent the 4 quarters of an hour. So when I visit your
website during 00m­15m, I want to see banners being served based on the statistics of the
first dataset, and if i visit your site during 16m­30m, i want to see the banners being served
based on the second dataset etc....

It is completely up to you which tools you will use: such as web­framework, database,
web­server, app­server, background­worker, scheduler, NoSQL, RubyGems ........ But
please provide us explanation why you have chosen a specific tool for your task.

## Prerequisites

You should have ```redis``` installed and running on localhost:6379

## Installation

```
git clone https://github.com/alexkorep/banners.git
cd banners
bundle install
```

### Web application

Web application is used to serve the banners to end users.

#### Development mode:
```
rake devserver
```
Source code changes in this mode are picked up by ```rerun``` and web server is restarted automatically.

#### Production mode
```
rake runserver
```

### Running scheduler
```
rake resque:scheduler

```

### Running background jobs

```
rake resque:work
```

### Running unit tests
```
rake test
```

### Dependencies

* ```rerun``` is used to restart webserver when source code are changed
* ```sinatra``` framework is used to create a simple web application.
* ```resque``` and ```resque-scheduler``` are used to run the background jobs and schedule them.



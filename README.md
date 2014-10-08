
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

## General description

* To avoid serving the same banner before all banners from the sequence are used, the cookie keeps last displayed banners (up to 10).
* ```Redis``` is used to keep the top-performing banners because it's very fast and I have experience working with it.
* ```sinatra``` framework is used to create the web application. It's quite simple and looks like a good fit for such a simple web application.
* ```resque``` and ```resque-scheduler``` are used to run the background jobs and schedule them. It's ligntweight and based on ```Redis``` which makes it a good match.
* ```Rake``` is used to run standard tasks like starting up the web sever, scheduler, background tasks, unit tests and warming up the cache.
* ```Foreman``` is used to manage tasks like web server, scheduler and backgound job. It's been chosen because it's supported by Heroku.
* Heroku hosting was chosen because it has a good support for Ruby application and it's free (unless you are runnig more than 1 task)

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

### Load test

```
$ siege -b -c 100 -t 1m http://calm-headland-8718.herokuapp.com/campaigns/2

Lifting the server siege...      done.
Transactions:		        5475 hits
Availability:		       99.38 %
Elapsed time:		       59.51 secs
Data transferred:	        0.18 MB
Response time:		        0.89 secs
Transaction rate:	       92.00 trans/sec
Throughput:		        0.00 MB/sec
Concurrency:		       82.04
Successful transactions:        5475
Failed transactions:	          34
Longest transaction:	       18.38
Shortest transaction:	        0.35
```

92 transaction per second gives 5520 transaction per minute.


### Further performance optimizations
#### Web
In case of hight web load, web servers could be running undependently on mutiple hosts, load can be balanced through the load balancer. Each of them will access the same Redis which can become a bottleneck in this case.

#### Background jobs
In case when amount of banner displays/clicks/conversion is too high to be handled by a single worker job, it can be distributed among multiple hosts. Each host should be provided with different data: each campaign should be processed on one host only. Each job will access same Redis which, again, can become a bottleneck.

#### Redis
In case when Redis is becoming a botteneck for web or jobs, it can be clustered. However redis clustering is currently in alfa stage and I'm not sure if it can be used in produciton.

As an alternative, we can use multiple Redis instances, each of them will handle its own set of campaigns. This would require some changes to the web and background jobs codebase.

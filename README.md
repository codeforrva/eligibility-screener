# Build a Supplemental Nutrition Assistance Program (SNAP or food stamps) Eligibility Pre-Screener

On February 20-22nd, mRelief (www.mrelief.com) will be part of a national event in partnership with Code For America (CFA) to build upon our work as the first Social Services Delivery SMS application for screening eligibility in the US. mRelief is a midwest based web and SMS application led by an all-woman web development team that helps users check their eligibility for public assistance. CFA organizes a network of people dedicated to making government services simple, effective, and easy to use.

We invite users all across the nation to participate in a challenge to build a food stamps eligibility pre-screeners for a target population.  We also encourage meaningful collaboration with non-technical experts in the field engaged in food policy and advocacy.


Here is a codebase of an SMS pre-screener. Fork this codebase, update it for your target population and then push your branch back up to GitHub!


## Setting up the app

(Note: An easy way to avoid dealing with setting up local dependencies is to use Nitrous.io, which gives you a nice pre-baked box you can use. To use Nitrous with this app, create a new Ruby on Rails box on Nitrous.io https://www.nitrous.io/app#/boxes/new Then all the below steps will be in your Nitrous box.)

Here's how you set up this sample app:

Clone the mRelief sample screening app:

`git clone https://github.com/mRelief/mrelief_snap_screener_example.git`

Go into the app directory:

`cd mrelief_snap_screener_example`

Install dependencies with bundle (this may take a few minutes):

`bundle install`

Create, migrate, and seed the database:

```
rake db:create
rake db:migrate
rake db:seed
```

Run the app:

`rails s`





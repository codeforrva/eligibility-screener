# Code for RVA Eligibility Screener

This app is a platform for SMS-based eligibility screeners similar to [mRelief](http://www.mrelief.com/). It allows people to determine eligibility for assistance programs by answering questions via text message.

SMS integration is through Twilio.

The app is currently running [on Heroku](https://rva-screener.herokuapp.com/), although it only has example screeners and no real functionality. SMS functionality is not connected but the app can be used via the test console.

## Features

* Supports multiple programs through separate screeners. Each screener operates on the same profile (identified by phone number), so they can share info and avoid asking the same question twice.
* Easy to add new screeners. Helper methods to avoid boilerplate and easily define eligibility rules in code.
* Supports multiple languages. The app as a whole, and each individual screener, can be easily translated to multiple languages.
* Test console. The main page of the app is a test console that simulates an SMS conversation via the web.

## Usage

There are a few control commands:

* `hello` - displays a welcome message. Choose a language by saying 'hello' in that language (for instance, `hola`).
* `reset` - clears profile data for the current phone number and resets the language to English.
* `delete` - deletes all profile data for the current phone number.
* `list` - lists all the screeners that are available and how to access them.

A screener is selected using the screener's name (as shown by the `list` command). Once the screener is active, it will begin asking questions until enough information is known to make an eligibility decision; it will then display the resulting message.

If an answer has already been given through a previous screener, it will not be asked again unless the profile is reset.

If a language other than English is active, the user can use the `delete` and `list` commands and the screener names that have been translated in to that language.  For instance, the food stamp screener is accessed by texting `food` in English but `comida` in Spanish.

## Setting up the app

(Note: An easy way to avoid dealing with setting up local dependencies is to use Nitrous.io, which gives you a nice pre-baked box you can use. To use Nitrous with this app, create a new Ruby on Rails box on Nitrous.io https://www.nitrous.io/app#/boxes/new Then all the below steps will be in your Nitrous box.)

Here's how you set up this sample app:

Clone the app:

`git clone https://github.com/codeforrva/eligibility-screener.git`

Go into the app directory:

`cd eligibility-screener`

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

Or to allow it to be accessed from the Internet:

`rails s -b 0.0.0.0`

## Testing with cURL

You can simulate sending a text message to the app using cURL if cookies are enabled. For example:

`curl -X POST http://servername:3000/ -c /tmp/cookies -b /tmp/cookies -d 'Body=hello'`

The test console is also available at http://servername:3000/.

## TODO

* Localize 'Error' and field names
* Tests
* Translations
* Documentation on how to add new screeners, translations, etc

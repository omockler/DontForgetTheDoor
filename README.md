DontForgetTheDoor
=================

Open and close your garage door from anywhere with a text, using some raspberry pi goodness.

I'm too lazy to maintain dynamic DNS and open ports on my router so I split this up into two sections. One that is run on the pi locally and a web component that can be run locally or somewhere like heroku.

Setup
=====
Prerequisites
 * Setup a twilio account for handling text messages.
   * Point the messages handler for your [phone line](https://www.twilio.com/user/account/phone-numbers/incoming) to http://*your_app_url*/twilio/message/recieve
   * Save the account id and token for use in the web portion
 * Setup a facebook developer account and application so that you can use facebook logins.
   * Use the first part of this guide https://developers.facebook.com/docs/facebook-login/getting-started-web/.
   * Like before save the app key and secret for later use

Web
----
If you are using heroku this should be pretty simple. Follow the guide [here](https://devcenter.heroku.com/articles/git) to deploy the app. You also will need to sign up for some mongo database. I'm using the mongo HQ addon and setting that up should be pretty automatic as well.

Pi
---
TBA

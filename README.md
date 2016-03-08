
=======
# IBM-email-sample-data-challange-v1.0

Generate .eml Files
Top Coder challenge - https://www.topcoder.com/challenge-details/30053168/?type=develop&amp;nocache=true

Prerequisites
-----

- Ruby 2.0+
- Bundler (http://bundler.io)

To install Bundler in Mac OS X / Linux, run:
 
    # sudo gem install bundler


Installation
------------

1) Unzip package

2) Go to the unzipped directory in terminal

3) Install gems

To install all used gems, run:

    # bundle install

Usage
-----

To run the script, from the project directory run in terminal:

    # ruby main.rb

If everything is OK, terminal will output "FINISH" and 
folders with .eml wil be generated at the path accorging to config.json file

Optional Parameters
-------------------

Besides configs listed in the challenge description ("numberOfInboxes", "megsPerInbox", etc.), added optional params:
 - "mailsWithAttachmentPerc" - percentage (0 to 100) of .eml files with attachments. Default value - 50
 - "maxAttachmentMegs" - maximum attachment size in Mb. Default value - 20. (attachment size for each .eml with an attachment randomly chosen from 1 to "maxAttachmentMegs")
 - "maxThreadMemberNumber" - maximum amount of email discussion participants. Default value - 10.

These parametrs can be optionally added to config.json file.


Program Logic
-------------

1) Configs loaded  from config.json

2) Until desired number of "inboxes" processed:

  2.1) new account is generated with fake email address and name

  2.2) New RSS Feed is randomly chosen to make discussion thread (If all RSS Feeds used, same RSS Feeds are repeated again)

  2.3)

    a) If items of RSS Feed are not connected, every feed is considered as separate email from separate email account

    b) If items of RSS feed are connected (e.g., forum thread), discussion thread is randomly constructed with random amount of participants (up to "maxThreadMemberNumber", default - 10).
    Every RSS item considered as separate reply email to previous RSS item and every participant has equal probability to be sender of email if he was in the receivers of previous email. 

  2.4) For each incoming message .eml is written and randomly file attached with probability "mailsWithAttachmentPerc" (default - 50%) and random size ranging from 1 Mb to "maxAttachmentMegs" (default - 20 Mb)




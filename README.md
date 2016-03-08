
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






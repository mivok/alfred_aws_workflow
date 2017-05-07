# Alfred AWS instance search workflow

This workflow for alfred lets you quickly search your AWS instances and grab
their IP addresses.

## Installation and setup

First, make sure you have the aws cli tools installed, as well as jq. The
easiest way to do this is with homebrew:

    brew install awscli jq

Next, make sure you have credentials set up in `~/.aws/credentials` for your
AWS account.

Finally, download and open the workflow.

## Commands

* `aws-profile` - set the AWS profile to use for searches. If this isn't set,
  then the default profile is used.
* `aws-clear-cache` - The workflow keep a cache of all instances for use when
  searching, and will update this once an hour (by default). Run
  `aws-clear-cache` to clear the cache before this time if you need the cache
  to update sooner.
* `aws` - the main search command. See below for what search terms to use.


## Searching

By default, searches will be performed on the 'Name' tag of the aws instances,
and partial matches will bring up the instance.

Multiple search terms are ANDed together. So if you wanted to find an instance
called `myapp-frontend-production` (but not `myapp-frontend-development`), you
could search for `aws fron prod`, using as many or few characters as you need
to uniqely match the instances you're looking for.

One exception to this is if your search term begins with `i-`. In this case,
the match will be against the instance ID rather than the name tag.

When you have found a match, pressing Enter will copy the private IP address
of the instance to the clipboard. To get the public address instead, hold down
the option key and press enter. To get the instance ID, hold down the command
key.

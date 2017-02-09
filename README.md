# leeroy [![Gem Version](https://badge.fury.io/rb/leeroy_app.svg)](https://badge.fury.io/rb/leeroy_app) [![Code Climate](https://codeclimate.com/github/FitnessKeeper/leeroy/badges/gpa.svg)](https://codeclimate.com/github/FitnessKeeper/leeroy) [![Build Status](https://travis-ci.org/FitnessKeeper/leeroy.svg?branch=master)](https://travis-ci.org/FitnessKeeper/leeroy.svg?branch=master)

o rly?  ya rly!

## Installation/Configuration

### Development

    $ bundle install
    $ ./bin/leeroy env -d > .env
    $ $EDITOR .env

### Production

    $ gem install leeroy_app
    $ leeroy env -p -d >> ~/.profile
    $ $EDITOR ~/.profile

## Usage

### General

leeroy is a "git-like" application; it takes GNU-style command-line options, global options come before the subcommand, command-specific options come after the subcommand.

    $ leeroy --help

### Jenkins workflow

Create a new gold master image:

    $ leeroy instantiate --phase gold_master | leeroy image | leeroy terminate

Create a new application image:

    $ leeroy instantiate --phase application | leeroy image | leeroy terminate

### Phases
A word about Phases in leeroy.  A phase is a context in which you execute an action.

For example, setting the phase to gold_master sets the context such that we, and leeroy, know that we will be creating a new image - aka AMI, in which can then be used to deploy application against.  

Currently accepted phases
```Yaml
---
  - gold_master
  - application
```
### Docker

docker run --rm -it --env AWS_ACCESS_KEY_ID=<KEY_ID> --env AWS_SECRET_ACCESS_KEY=<SECRET> --env AWS_DEFAULT_REGION=us-east-1 --env LEEROY_AWS_LINUX_AMI=ami-b73b63a0 --env LEEROY_APP_NAME=rk-bastion --env LEEROY_PACKER_TEMPLATE_PREFIX=/data/packer-rk-apps -v /Users/alaric/git/packer-rk-apps:/data/packer-rk-apps fitnesskeeper/leeroy packer -p gold_master

### Packer

Leeroy will look for packer templates named main.json in locations built off LEEROY_PACKER_TEMPLATE_PREFIX + LEEROY_APP_NAME, so for example if `LEEROY_PACKER_TEMPLATE_PREFIX=/home/user/packer-repo` and `LEEROY_APP_NAME=rk-bastion` leeroy will look for main.json in `/home/user/packer-repo/rk-bastion/main.json` leeroy will also attempt to pass packer the PHASE for use by any provisioners as a packer var, e.g -var phase=gold_master will get passed to packer, and can be used by puppet or whatever to configure the image appropriately

### Provisioning workflow


### Instantiate

Leeroy instantiate assumes that you are creating the image, you are then going to exectute some kind of operations on it, then create an image on it. Instances spun up with instantiate are supposed to have a limited life span, and we track there existence with a sepmephore

FIXME not implemented yet

    $ leeroy bootstrap | leeroy provision

### Deploy Static Assets to s3

LEEROY_STATIC_ASSETS_S3_BUCKET # S3 bucket to host static assets
LEEROY_STATIC_ASSETS_S3_PREFIX # Prefix in which to place the static assets
LEEROY_STATIC_ASSETS # Path on local file system to git repo with static static assets

require 'leeroy/task/static_assets'
task = Leeroy::Task::StaticAssets.new(options: { :phase => 'gold_master' })


repo.last_commit.oid

# leeroy [![Gem Version](https://badge.fury.io/rb/leeroy_app.svg)](https://badge.fury.io/rb/leeroy_app) [![Code Climate](https://codeclimate.com/github/FitnessKeeper/leeroy/badges/gpa.svg)](https://codeclimate.com/github/FitnessKeeper/leeroy) [![Build Status](https://travis-ci.org/FitnessKeeper/leeroy.svg?branch=master)](https://travis-ci.org/FitnessKeeper/leeroy.svg?branch=master)

o rly?  ya rly!

## Installation/Configuration

### Development

    $ bundle install
    $ export ENVIRONMENT=development
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

### Packer

Leeroy will look for packer templates named main.json in locations built off LEEROY_PACKER_TEMPLATE_PREFIX + LEEROY_APP_NAME, so for example if `LEEROY_PACKER_TEMPLATE_PREFIX=/home/user/packer-repo` and `LEEROY_APP_NAME=rk-bastion` leeroy will look for main.json in `/home/user/packer-repo/rk-bastion/main.json` leeroy will also attempt to pass packer the PHASE for use by any provisioners as a packer var, e.g -var phase=gold_master will get passed to packer, and can be used by puppet or whatever to configure the image appropriately 

### Provisioning workflow

FIXME not implemented yet

    $ leeroy bootstrap | leeroy provision

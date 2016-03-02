# leeroy [![Gem Version](https://badge.fury.io/rb/leeroy_app.svg)](https://badge.fury.io/rb/leeroy_app) [![Code Climate](https://codeclimate.com/github/FitnessKeeper/leeroy/badges/gpa.svg)](https://codeclimate.com/github/FitnessKeeper/leeroy)
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

### Provisioning workflow

FIXME not implemented yet

    $ leeroy bootstrap | leeroy provision

# Puppet Karaf module

[![Build Status](https://travis-ci.org/fatmcgav/fatmcgav-karaf.svg?branch=develop)](https://travis-ci.org/fatmcgav/fatmcgav-karaf) 
[![Coverage Status](https://coveralls.io/repos/fatmcgav/fatmcgav-karaf/badge.png?branch=develop)](https://coveralls.io/r/fatmcgav/fatmcgav-karaf?branch=develop)

Puppet module to manage installation, configuration and management of Apache Karaf OSGi container.

####Table of Contents
- [Puppet Karaf module](#puppet-karaf-module)
	- [Overview](#overview)
	- [Features](#features)
	- [Requirements](#requirements)
	- [Usage](#usage)
	- [Limitations](#limitations)
	- [Contributors](#contributors)
	- [Development](#development)
	- [Testing](#testing)

## Overview
This module adds support for installing and configuring the Apache Karaf OSGi application server. 

## Features
This module currently supports the following:
 * Install Apache Karaf OSGi Application server, either by downloading a Zip file 
 or installing from a package.
 * Install and configure Java if appropriate. 
 * Manage user accounts if appropriate. 
 * Configure PATH to support Karaf.
 * Create Linux service to run Karaf on system startup using Wrapper.
 * Manage various configuration elements of Karaf, including:
  * Feature repositories
  * Features
  * Kar files

## Requirements
This module requires the `Puppetlabs-Stdlib` module version >= 3.2.0.

## Usage
TBC

## Limitations
Lots currently. 

## Contributors

## Development
If you have any features that you feel are missing or find any bugs for this module, 
feel free to raise an issue on [Github](https://github.com/fatmcgav/fatmcgav-karaf/issues?state=open),
or even better submit a PR and I will review as soon as I can. 

## Testing
This module has been written to support Rspec testing of both the manifests and types/providers.
In order to execute the tests, run the following from the root of the module: 
 `bundle install && bundle exec rake spec` 
# nimr: Run nim programs like scripts

This is a pretty much direct port of the excellent `nimrun` which was
written by Flaviu Tamas.  Unlike `nimrun`, `nimr` is implemented in
nim and can be installed via nimble (for a nice smooth install).

## Requirements

Nim compiler >= 16.0

## Installation

Installation via Nimble is recommended:  `nimble install nimr`

## Use

After installation, simply add `#!/usr/bin/env nimr` as the first line
of your script (just like you would with python/ruby/etc).

## Features

* Caching of compilation results

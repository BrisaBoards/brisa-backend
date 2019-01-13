#!/bin/bash

source ./environment.local
cd $(dirname $0)
~/.rvm/wrappers/default/puma $@

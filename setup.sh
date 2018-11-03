#!/bin/bash

source ./environment

echo "Creating a master.key and credentials.yml.enc file..."
echo ':q' | EDITOR=/bin/true RAILS_ENV=test rails credentials:edit

#!/bin/bash

if [[ $1 == '' ]]; then
  echo "Usage: $0 <email>"
  exit 1;
fi
rails runner 'user = ARGV[0]; STDOUT.write "Enter Temp Admin Pass for #{user}\n> "; \
  pass = STDIN.readline.chomp; \
  u = User.new(alias: user, email: user, confirmed: true, admin: true); \
  u.set_password(pass); \
  u.save!; \
  puts "Created admin user #{user}"' "$1"


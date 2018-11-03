#!/bin/bash

source ./environment

if [[ $1 == '' ]]; then
  echo "Usage: $0 <email> [--admin]"
  exit 1;
fi

rails runner 'user = ARGV[0]; is_admin = ARGV[1] == "--admin"; STDOUT.write "Enter Temp Pass for #{is_admin ? "Admin " : ""}#{user}\n> "; \
  begin; \
    pass = STDIN.readline.chomp; \
  rescue Interrupt; \
    puts "Exiting."; \
    exit 1; \
  end; \
  u = User.new(alias: user, email: user, confirmed: true, admin: is_admin); \
  u.set_password(pass); \
  u.save!; \
  puts "Created user #{user}"' "$1" "$2"


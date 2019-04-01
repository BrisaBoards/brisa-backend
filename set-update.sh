#!/bin/bash

source ./environment.local

if [[ $1 == '' ]]; then
  echo "Usage: $0 \"message\" [--required]"
  exit 1;
fi

rails runner ' \
  message = ARGV[0]; is_required = ARGV[1] == "--required"; \
  update = {m: "sysup", s: Time.now.to_i, message: message, required: is_required}; \
  puts update.to_json' "$1" "$2"

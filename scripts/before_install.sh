#!/bin/bash

# Stop Nginx service
service nginx stop

# Remove existing webpage files
rm -rf /usr/share/nginx/html/*

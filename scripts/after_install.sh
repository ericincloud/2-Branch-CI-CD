#!/bin/bash

# Copy updated webpage files to Nginx document root
cp -r /path/to/updated/html/files/* /usr/share/nginx/html/

# Restart Nginx service
service nginx start

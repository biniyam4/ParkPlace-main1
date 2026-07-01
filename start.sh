#!/bin/bash
echo "Building Flutter web app..."
flutter build web --release 2>&1
echo "Starting web server..."
node serve.js

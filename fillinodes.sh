#!/bin/bash

### This script will create as many files as you have inodes available on your / filesystem

while [ $(df --output=iavail / | tail -n1) -gt 0 ]; do
    touch $((i++));
done

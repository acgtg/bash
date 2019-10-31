#!/bin/sh

#http://concoursetutorial.com/basics/publishing-outputs/

set -e # fail fast
set -x # print commands

git clone resource-gist updated-gist

cd updated-gist
> bumpme
date >> bumpme
pwd >> bumpme
hostname >> bumpme
ls -la >> bumpme
cat bumpme


git config --global user.email "nobody@concourse-ci.org"
git config --global user.name "Concourse"

git add .
git commit -m "Bumped data"

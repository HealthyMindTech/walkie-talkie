#!/usr/bin/env bash

cd $(dirname $0)/../backend

npm run build

rsync -avz --delete dist/ walkietalkie@walkietalkie.tech:walkietalkie
ssh walkietalkie@walkietalkie.tech "sudo systemctl restart walkietalkie"

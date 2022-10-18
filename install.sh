#!/bin/bash -eu

sudo sh -c "$(curl -fsLS https://chezmoi.io/get)" -- -b /usr/local/bin
chezmoi init --apply satsh12st

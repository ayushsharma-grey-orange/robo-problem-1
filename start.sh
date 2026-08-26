#!/bin/bash


clear 
cd robo_nav || exit 1

echo "Compiling robo_nav..."
rebar3 compile || exit 1

echo "Starting Rebar3 shell..."
rebar3 shell
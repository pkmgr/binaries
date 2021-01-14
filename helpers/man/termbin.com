#!/usr/bin/env bash
source ./.functions
printf_help "4" "Usage: command | termbin.com or termbin.com filename"

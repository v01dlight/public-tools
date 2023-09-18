#!/bin/bash

read -p "Input file: " file

while read y
do
  echo "Line contents are : $y "
done < $file

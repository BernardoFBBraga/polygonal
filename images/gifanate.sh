#!/bin/bash

convert -delay 4 -loop 0 *.png $1
rm *.png

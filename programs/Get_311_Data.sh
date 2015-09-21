#!/bin/bash 
cd ~/;

########################################
# Print PDF of the data
########################################
Rnosave Get_311_Data.R -N PRINT \
    -t 1-37 \
    -l mem_free=5G,h_vmem=6G
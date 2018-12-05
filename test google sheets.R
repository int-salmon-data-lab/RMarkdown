# test googlesheets
library(magrittr);library(googlesheets);library(dplyr); library(openssl);
    ss= "https://docs.google.com/spreadsheets/d/1SYDSw4f6EMEZZQ8nKA1k-1AHuixpD54aVQhgPjaogoU/edit?usp=sharing"
    ss1=gs_url(ss);
    positionCode = gs_read(ss1,skip=1); positionCode # "SE-RES - Research Scientist"
# code                                question
# <int>                                   <chr>
#    1             SE-RES - Research Scientist
#    2               SE-REM - Research Manager
#    3                          BI - Biologist
#    4                          EX - Executive
#    5                   CS - Computer Systems
#    6 EG - Engineering and Scientific Support
#    7                     CM - Communications
#    8                                   other

    regionCode =   gs_read(ss1, ws="regionCode", skip=1); regionCode  # second sheet
    locationCode = gs_read(ss1, ws=3, skip=1); locationCode           # 21 rows



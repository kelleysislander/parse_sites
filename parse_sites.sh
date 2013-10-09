#!/bin/bash

shopt -s -o nounset

declare -rx SCRIPT=${0##*/}

printf "***********************************\n\n"
printf $SCRIPT
printf "\n\n"
printf "***********************************\n"

run_date=`date`

printf "Run Date: %s" "$run_date"
printf "\n"


log_date=`date '+%Y%m%d_%H%M_%S'`

url=$1
# http://www.helifreak.com/forumdisplay.php?f=51
# OR
# http://www.rcgroups.com/aircraft-electric-helis-fs-w-44/
printf "url: %s" "$url"
printf "\n"


if [ ${url} == "http://www.helifreak.com/forumdisplay.php?f=51" ]; then
    curl -X GET ${url} | grep -i thread_title_ | awk '{print tolower($0)}' | grep 'ikon\|flybarless\|FBL\|msh\|brain' > ~/Helis/heli_files/helifreak_parse.txt 2>&1
else
    curl -X GET ${url} | grep -i thread_title_ | awk '{print tolower($0)}' | grep 'ikon\|flybarless\|FBL\|msh\|brain' > ~/Helis/heli_files/rcgroups_parse.txt 2>&1
fi

# Now run the ruby script against the *_parse.txt file
ruby /Volumes/MainHD/Users/billy/Helis/heli_files/parse_sites.rb $url

exit 0

# To run this script from the CL:
# /Volumes/MainHD/Users/billy/Helis/heli_files/parse_sites.sh http://www.helifreak.com/forumdisplay.php?f=51
# /Volumes/MainHD/Users/billy/Helis/heli_files/parse_sites.sh http://www.rcgroups.com/aircraft-electric-helis-fs-w-44/

#curl -X GET http://www.helifreak.com/forumdisplay.php?f=51/ | grep -i thread_title_ | awk '{print tolower($0)}' | grep 'ikon\|flybarless\|FBL\|msh\|brain' > ~/Helis/heli_files/helifreak_parse.txt 2>&1

#   *     *     *   *    *        command to be executed
#   -     -     -   -    -
#   |     |     |   |    |
#   |     |     |   |    +----- day of week (0 - 6) (Sunday=0)
#   |     |     |   +------- month (1 - 12)
#   |     |     +--------- day of        month (1 - 31)
#   |     +----------- hour (0 - 23)
#   +------------- min (0 - 59)

# started from cron this way every 2 mins starting at midnight:
# 0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58 * * * * /Volumes/MainHD/Users/billy/Helis/heli_files/parse_sites.sh http://www.helifreak.com/forumdisplay.php?f=51 > /Volumes/MainHD/Users/billy/Helis/heli_files/run_parse_sites_helifreak.log 2>&1
# started from cron this way every 2 mins starting at 1 minute past midnight:
# 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47,49,51,53,55,57,59 * * * * /Volumes/MainHD/Users/billy/Helis/heli_files/parse_sites.sh http://www.rcgroups.com/aircraft-electric-helis-fs-w-44/ > /Volumes/MainHD/Users/billy/Helis/heli_files/run_parse_sites_rcgroups.log 2>&1
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

# every random n mins starting at midnight:
3,7,10,14,17,21,24,28,31,35,39,42,46,49,53,56,59 * * * * cd /Volumes/MainHD/Users/billy/Helis/heli_files && /Volumes/MainHD/Users/billy/Helis/heli_files/parse_sites.sh http://www.helifreak.com/forumdisplay.php?f=51 > /Volumes/MainHD/Users/billy/Helis/heli_files/run_parse_sites_helifreak.log 2>&1

# every random n mins starting at 1 minute past midnight:
1,4,8,11,15,19,22,25,29,32,36,40,43,47,50,54,57 * * * * cd /Volumes/MainHD/Users/billy/Helis/heli_files && /Volumes/MainHD/Users/billy/Helis/heli_files/parse_sites.sh http://www.rcgroups.com/aircraft-electric-helis-fs-w-44/ > /Volumes/MainHD/Users/billy/Helis/heli_files/run_parse_sites_rcgroups.log 2>&1
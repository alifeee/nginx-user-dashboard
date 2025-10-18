#!/bin/bash
# parse a day's nginx logs into an CSV summary

# files
log="${1:-/var/log/nginx/access.log}"
history="${2:-/usr/alifeee/nginx-user-dashboard/history.csv}"

# create blank CSV if not exist
if [[ ! -f "${history}" ]]; then
  awk 'BEGIN {
    printf "date,name"
    for (h=0;h<24;h++) {printf ",%02d", h}
    printf "\n"
  }' \
  > "${history}"
fi

# skip blank log
if [[ $(cat "${log}" | wc -l) == 0 ]]; then
  echo "log empty, printing blank row" >&2
  d=$(date '+%d/%h/%Y')
  echo "${d},EMPTY,,,,,,,,,,,,,,,,,,,,,,,," >> "${history}"
  exit 0
fi

# begin
date >&2
echo "saving nginx summary from ${log}" >&2

# make CSV of accesses by-hour like
# name,…,12,13,14,15,16
# alifeee,…,,15,4,,,
cat "${log}" \
  | awk -F' ' 'BEGIN {
    delete names
    delete dates
    delete t
  } {
    name=$3
    split($4, timeparts, /:|\[/)
    date=timeparts[2]
    hour=timeparts[3]
    # printf "%s %s %s\n", name, $4, $5
    # printf "  date: %s\n", date
    # printf "  hour: %s\n", hour
    # printf "  keying %s\n", name ":" date ":" hour
    names[name] = 1
    dates[date] = 1
    t[name ":" date ":" hour] += 1
  } END {
    for (d in dates) {
      for (n in names) {
        printf "%s,%s", d, n
        for (h=0;h<24;h++) {
          hr = sprintf("%02d", h) # pad 0s
          # printf "accessing key: %s\n", n ":" d ":" hr
          printf ",%s", t[n ":" d ":" hr]
        }
        printf "\n"
      }
    }
  }' \
  | tee -a "${history}" >&2

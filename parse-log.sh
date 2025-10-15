#!/bin/bash
# parse access logs

log="${1:-/var/log/nginx/access.log}"

accesses=$(
  cat "${log}" \
  | awk -F' ' '{print $3, $4, $5}' \
  | sort
)

echo "user,first access,last access" >&2
echo "${accesses}" \
  | awk -F' |\\[|\\]' '{
      name=$1
      if (lastname != name) {
        if (lastline!="") {print lastline}
        print $0
      }
      lastname = name
      lastline = $0
    } END {print lastline}' \
  | awk -F' |\\[|\\]' 'NR%2 == 1{
      printf "%s,%s %s,", $1, $3, $4
    } NR%2 == 0 {
      printf "%s %s\n", $3, $4
    }' >&2

echo "" >&2
echo -e "total\tuser" >&2
echo "${accesses}" \
  | awk -F' ' '{print $1}' \
  | uniq -c \
  >&2

#!/bin/bash
# convert CSV to HTML table

source /usr/alifeee/nginx-user-dashboard/.env

history="${1:-/usr/alifeee/nginx-user-dashboard/history.csv}"
html="${2:-/usr/alifeee/nginx-user-dashboard/history.html}"

echo "writing html" 2>&1

if [[ ! -f "${history}" ]]; then
  echo "history empty, doing nothing…" >&2
  exit 0
fi

cat > "${html}" << EOHTML
<!DOCTYPE html>
<html lang="en">
<head>
<title>pi access logs</title>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/picnic">
<style>
td {
  border: 1px black solid;
}
section {
  margin: 0 1rem 1rem;
}
table {
  text-align: center
}

/* thick borders */
td:nth-child(2) {
  border-right-width: 4px;
}
.first-of-date td {
  border-top-width: 4px;
}
tr:last-child td {
  border-bottom-width: 4px;
}
td:first-child {
  border-left-width: 4px;
}
td:last-child {
  border-right-width: 4px;
}
</style>
</head>
<body>
<section id="logs">
<h1>Access logs</h1>
<p>
  ${PREAMBLE}
</p>
EOHTML

cat "${history}" \
  | awk -F',' 'BEGIN {
    last="date"
    print "<table>"
    print "<tr class=\"first-of-date\">"
    print "<td rowspan=2>date</td><td rowspan=2>name</td>"
    print "<td colspan=24>time of day (hour)</td>"
    print "</tr>"
  } {
    if ($1 != last) {
      print "<tr class=\"first-of-date\">"
    } else {
      print "<tr>"
    }
    for (i=1;i<NF;i++) {
      if (NR==1 && i < 3) continue
      printf "<td>%s</td>", $i
    }
    print "</tr>"
    last = $1
  } END {
    print "</table>"
  }' \
  >> "${html}"

cat >> "${html}" << EOHTML
</section>
</body>
EOHTML

echo "done!" 2>&1

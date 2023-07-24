#!/bin/bash

check_sftp_logs() {
  echo "Enter the start date in YYYY-MM-DD format:"
  read start_date
  echo "Enter the end date in YYYY-MM-DD format:"
  read end_date
  echo "Enter the start time in HH:MM:SS format:"
  read start_time
  echo "Enter the end time in HH:MM:SS format:"
  read end_time

  awk -v start_date="$start_date" -v end_date="$end_date" -v start_time="$start_time" -v end_time="$end_time" '
    BEGIN {
      start_epoch = mktime(gensub(/-/, " ", "g", start_date) " 0 0 0")
      end_epoch = mktime(gensub(/-/, " ", "g", end_date) " 0 0 0")
      split(start_time, st, ":")
      start_sec = st[1] * 3600 + st[2] * 60 + st[3]
      split(end_time, et, ":")
      end_sec = et[1] * 3600 + et[2] * 60 + et[3]
    }
    $1 ~ /-/ && $2 ~ /:/ {
      log_epoch = mktime(gensub(/-/, " ", "g", $1) " 0 0 0")
      split($2, lt, ":")
      log_sec = lt[1] * 3600 + lt[2] * 60 + lt[3]
      if (log_epoch >= start_epoch && log_epoch <= end_epoch && log_sec >= start_sec && log_sec <= end_sec && $0 ~ /sftp-server/) {
        print
      }
    }
  ' /var/log/auth.log
}

check_sftp_logs

#!/usr/bin/env bash
set -euo pipefail

# --- CONFIG (override with env vars if needed) ---
SIGMARK_PATH="${SIGMARK_PATH:-./sigmark.sh}"          # path to your script
REMOTE_ADDRESS="${REMOTE_ADDRESS:-192.168.50.101:8000}" # ip:port of your Mac/PC
MARKER_CHANNEL="${MARKER_CHANNEL:-CH1}"               # CH1 or CH2
# --------------------------------------------------

send_marker_raw() {
  sh "$SIGMARK_PATH" "$REMOTE_ADDRESS" "$MARKER_CHANNEL" "$1" || {
    echo "WARN: failed to send marker: $1" >&2
    return 0
  }
}

send_start() { send_marker_raw "start,sigmark,${1}"; }
send_stop()  { send_marker_raw "stop,sigmark,${1}"; }

# --- all stress-ng commands you want to run sequentially ---
STRESS_CMDS=(

  "stress-ng -l 0  --cpu 1 -t 80s"
  "stress-ng -l 10 --cpu 1 -t 80s"
  "stress-ng -l 20 --cpu 1 -t 80s"
  "stress-ng -l 30 --cpu 1 -t 80s"
  "stress-ng -l 40 --cpu 1 -t 80s"
  "stress-ng -l 50 --cpu 1 -t 80s"
  "stress-ng -l 60 --cpu 1 -t 80s"
  "stress-ng -l 70 --cpu 1 -t 80s"
  "stress-ng -l 80 --cpu 1 -t 80s"
  "stress-ng -l 90 --cpu 1 -t 80s"
  "stress-ng -l 100 --cpu 1 -t 80s"  
)

# index pointer so each call to do_stress_next uses the next stress command
NEXT_STRESS_IDX=0
do_stress_next() {
  if (( NEXT_STRESS_IDX < ${#STRESS_CMDS[@]} )); then
    echo "Running: ${STRESS_CMDS[$NEXT_STRESS_IDX]}"
    eval "${STRESS_CMDS[$NEXT_STRESS_IDX]}"
    ((NEXT_STRESS_IDX++))
  else
    echo "NOTE: no more stress-ng commands left."
  fi
}

# --------------------------
# Seven 81s sequences
# --------------------------

# forløb 0 — no markers (just idle)
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35
do
send_start "0"
sleep 80
send_stop "0"

# forløb 1 — marker every 20s (4)

send_start 0
stress-ng -l 0  --cpu 1 -t 80s
send_stop 0
sleep 20

send_start 10
stress-ng -l 10 --cpu 1 -t 80s
send_stop 10
sleep 20

send_start 20
stress-ng -l 20 --cpu 1 -t 80s
send_stop 20
sleep 20

send_start 30
stress-ng -l 30 --cpu 1 -t 80s
send_stop 30
sleep 20

send_start 40
stress-ng -l 40 --cpu 1 -t 80s
send_stop 40
sleep 20

send_start 50
stress-ng -l 50 --cpu 1 -t 80s
send_stop 50
sleep 20

send_start 60
stress-ng -l 60 --cpu 1 -t 80s
send_stop 60
sleep 20

send_start 70
stress-ng -l 70 --cpu 1 -t 80s
send_stop 70
sleep 20

send_start 80
stress-ng -l 80 --cpu 1 -t 80s
send_stop 80
sleep 20

send_start 90
stress-ng -l 90 --cpu 1 -t 80s
send_stop 90
sleep 20

send_start 100
stress-ng -l 100 --cpu 1 -t 80s
send_stop 100
sleep 20

done
echo "All 35 sequences complete."

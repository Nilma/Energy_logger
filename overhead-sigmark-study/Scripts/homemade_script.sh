
# --- CONFIG (override with env vars if needed) ---
SIGMARK_PATH="${SIGMARK_PATH:-./sigmark.sh}"         # path to your script
REMOTE_ADDRESS="${REMOTE_ADDRESS:-192.168.50.101:8000}" # ip:port of your Mac/PC
MARKER_CHANNEL="${MARKER_CHANNEL:-CH1}"               # CH1 or CH2
# --------------------------------------------------

send_marker_raw() {
  # $1 = message string (e.g. "stop,sigmark,0")
  # Never writes local logs; only sends to remote via sigmark.sh
  sh "$SIGMARK_PATH" "$REMOTE_ADDRESS" "$MARKER_CHANNEL" "$1" || {
    echo "WARN: failed to send marker: $1" >&2
    return 0  # don't kill the run if a single marker fails
  }
}

# Convenience helpers using your 3-field CSV message convention
send_start()  { send_marker_raw "start,sigmark,$1"; } # $1 = elapsed seconds (integer)
send_stop()   { send_marker_raw "stop,sigmark,$1"; } # $1 = elapsed seconds (integer)
send_tick()   { 
  send_marker_raw "sigmark,tick"
}

for j in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35
do

  send_start "1"
  sleep "80" 
  send_stop "1"


  send_start "20"
  for i in 1 2 3 4
  do
      send_tick
      sleep "20" 
  done
  send_stop "20"


  send_start "10"
  for i in 1 2 3 4 5 6 7 8
  do
      send_tick
      sleep "10" 
  done
  send_stop "10"

  send_start "5"
  for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
  do
      send_tick
      sleep "5" 
  done
  send_stop "5"

  send_start "4"
  for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
  do
      send_tick
      sleep "4" 
  done
  send_stop "4"


  send_start "2"
  for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
  do
      send_tick
      sleep "2" 
  done
  send_stop "2"

  send_start "1"
  for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
  do
      send_tick
      sleep "1" 
  done
  send_stop "1"

done 
echo "All 35 sequences complete"

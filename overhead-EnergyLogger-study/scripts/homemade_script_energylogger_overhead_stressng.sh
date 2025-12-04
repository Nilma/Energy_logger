
# --- CONFIG (override with env vars if needed) ---
SIGMARK_PATH="${SIGMARK_PATH:-./sigmark.sh}"         # path to your script
REMOTE_ADDRESS="${REMOTE_ADDRESS:-192.168.50.101:8000}" # ip:port of your Mac/PC
MARKER_CHANNEL="${MARKER_CHANNEL:-CH1}"               # CH1 or CH2
# --------------------------------------------------

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
send_start()  { send_marker_raw "start,sigmark,$1"; } 
send_stop()   { send_marker_raw "stop,sigmark,$1"; } 
send_tick()   { 
  send_marker_raw "sigmark,tick"
}


for load in 0 20 40 60 80 100
do
	for j in 1 2 3 4 5 6 7 8 9 10 #11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35
	do
	
		# --- EnergyLogger config ---
		SAMPLEPERIOD=2               # sample period for pmic_raw_logger
		TS=$(date +"%Y%m%d_%H%M%S")
		OUTFILE="pmic_log_${load}_${SAMPLEPERIOD}s_${TS}.csv"  # CSV output in timestamped filename
	
		# --- start energy logger (inactive) ---
		./pmic_raw_logger "$SAMPLEPERIOD" "$OUTFILE" &
		LOGGER_PID=$!
		echo "Logger started with PID $LOGGER_PID, logging to $OUTFILE"
		sleep 0.5  # let logger start
	
	
		send_start "$SAMPLEPERIOD" # -- start the siglent ---
		kill -USR1 "$LOGGER_PID" # --- mark logger active ---
		stress-ng --cpu 1 -l "$load" -t 80s &
		WORK_PID=$!
		echo "Workload PID: $WORK_PID"
		# wait for workload to finish
		wait "$WORK_PID"
		kill -USR2 "$LOGGER_PID"  # --- mark logger inactive ---
		send_stop "$SAMPLEPERIOD" # -- stop the siglent ---
		sleep "2"
		
		# --- terminate logger and wait for clean exit ---
		kill -TERM "$LOGGER_PID"
		wait "$LOGGER_PID"
		
		echo "Done. EnergyLogger Data in $OUTFILE"
		
		sleep "20"
		
		# --- Ready for new logging ---
		
		# --- EnergyLogger config ---
		SAMPLEPERIOD=1               # sample period for pmic_raw_logger
		TS=$(date +"%Y%m%d_%H%M%S")
		OUTFILE="pmic_log_${load}_${SAMPLEPERIOD}s_${TS}.csv"  # CSV output in timestamped filename
	
		# --- start energy logger (inactive) ---
		./pmic_raw_logger "$SAMPLEPERIOD" "$OUTFILE" &
		LOGGER_PID=$!
		echo "Logger started with PID $LOGGER_PID, logging to $OUTFILE"
		sleep 0.5  # let logger start
	
	
		send_start "$SAMPLEPERIOD" # -- start the siglent ---
		kill -USR1 "$LOGGER_PID" # --- mark logger active ---
		stress-ng --cpu 1 -l "$load" -t 80s &
		WORK_PID=$!
		echo "Workload PID: $WORK_PID"
		
		# wait for workload to finish
		wait "$WORK_PID"
		kill -USR2 "$LOGGER_PID"  # --- mark logger inactive ---
		send_stop "$SAMPLEPERIOD" # -- stop the siglent ---
		
		sleep "2"
		# --- terminate logger and wait for clean exit ---
		kill -TERM "$LOGGER_PID"
		wait "$LOGGER_PID"
		
		echo "Done. EnergyLogger Data in $OUTFILE"
		
		sleep "20"
		
		# --- Ready for new logging ---
		
		# --- EnergyLogger config ---
		SAMPLEPERIOD=0.5               # sample period for pmic_raw_logger
		TS=$(date +"%Y%m%d_%H%M%S")
		OUTFILE="pmic_log_${load}_${SAMPLEPERIOD}s_${TS}.csv"  # CSV output in timestamped filename
		
		# --- start energy logger (inactive) ---
		./pmic_raw_logger "$SAMPLEPERIOD" "$OUTFILE" &
		LOGGER_PID=$!
		echo "Logger started with PID $LOGGER_PID, logging to $OUTFILE"
		sleep 0.5  # let logger start
		
		
		send_start "$SAMPLEPERIOD" # -- start the siglent ---
		kill -USR1 "$LOGGER_PID" # --- mark logger active ---
		stress-ng --cpu 1 -l "$load" -t 80s &
		WORK_PID=$!
		echo "Workload PID: $WORK_PID"
		
		# wait for workload to finish
		wait "$WORK_PID"
		kill -USR2 "$LOGGER_PID"  # --- mark logger inactive ---
		send_stop "$SAMPLEPERIOD" # -- stop the siglent ---
		
		sleep "2"		
		# --- terminate logger and wait for clean exit ---
		kill -TERM "$LOGGER_PID"
		wait "$LOGGER_PID"
		
		echo "Done. EnergyLogger Data in $OUTFILE"
		
		sleep "20"
		
		# --- Ready for new logging ---
		
		
		# --- EnergyLogger config ---
		SAMPLEPERIOD=0.2               # sample period for pmic_raw_logger
		TS=$(date +"%Y%m%d_%H%M%S")
		OUTFILE="pmic_log_${load}_${SAMPLEPERIOD}s_${TS}.csv"  # CSV output in timestamped filename
		
		# --- start energy logger (inactive) ---
		./pmic_raw_logger "$SAMPLEPERIOD" "$OUTFILE" &
		LOGGER_PID=$!
		echo "Logger started with PID $LOGGER_PID, logging to $OUTFILE"
		sleep 0.5  # let logger start
		
		
		send_start "$SAMPLEPERIOD" # -- start the siglent ---
		kill -USR1 "$LOGGER_PID" # --- mark logger active ---
		stress-ng --cpu 1 -l "$load" -t 80s &
		WORK_PID=$!
		echo "Workload PID: $WORK_PID"
		
		# wait for workload to finish
		wait "$WORK_PID"
		kill -USR2 "$LOGGER_PID"  # --- mark logger inactive ---
		send_stop "$SAMPLEPERIOD" # -- stop the siglent ---
		sleep "2"
		# --- terminate logger and wait for clean exit ---
		kill -TERM "$LOGGER_PID"
		wait "$LOGGER_PID"
		
		echo "Done. EnergyLogger Data in $OUTFILE"
		
		sleep "20"
		
		# --- Ready for new logging ---
		
		# --- EnergyLogger config ---
		SAMPLEPERIOD=0.1               # sample period for pmic_raw_logger
		TS=$(date +"%Y%m%d_%H%M%S")
		OUTFILE="pmic_log_${load}_${SAMPLEPERIOD}s_${TS}.csv"  # CSV output in timestamped filename
		
		# --- start energy logger (inactive) ---
		./pmic_raw_logger "$SAMPLEPERIOD" "$OUTFILE" &
		LOGGER_PID=$!
		echo "Logger started with PID $LOGGER_PID, logging to $OUTFILE"
		sleep 0.5  # let logger start
		
		
		send_start "$SAMPLEPERIOD" # -- start the siglent ---
		kill -USR1 "$LOGGER_PID" # --- mark logger active ---
		stress-ng --cpu 1 -l "$load" -t 80s &
		WORK_PID=$!
		echo "Workload PID: $WORK_PID"
		
		# wait for workload to finish
		wait "$WORK_PID"
		kill -USR2 "$LOGGER_PID"  # --- mark logger inactive ---
		send_stop "$SAMPLEPERIOD" # -- stop the siglent ---
		sleep "2"
		# --- terminate logger and wait for clean exit ---
		kill -TERM "$LOGGER_PID"
		wait "$LOGGER_PID"
		
		echo "Done. EnergyLogger Data in $OUTFILE"
		
		sleep "20"
		
		# --- Ready for new logging ---
		
		# --- EnergyLogger config ---
		SAMPLEPERIOD=0.05               # sample period for pmic_raw_logger
		TS=$(date +"%Y%m%d_%H%M%S")
		OUTFILE="pmic_log_${load}_${SAMPLEPERIOD}s_${TS}.csv"  # CSV output in timestamped filename
		
		# --- start energy logger (inactive) ---
		./pmic_raw_logger "$SAMPLEPERIOD" "$OUTFILE" &
		LOGGER_PID=$!
		echo "Logger started with PID $LOGGER_PID, logging to $OUTFILE"
		sleep 0.5  # let logger start
		
		
		send_start "$SAMPLEPERIOD" # -- start the siglent ---
		kill -USR1 "$LOGGER_PID" # --- mark logger active ---
		stress-ng --cpu 1 -l "$load" -t 80s &
		WORK_PID=$!
		echo "Workload PID: $WORK_PID"
		
		# wait for workload to finish
		wait "$WORK_PID"
		kill -USR2 "$LOGGER_PID"  # --- mark logger inactive ---
		send_stop "$SAMPLEPERIOD" # -- stop the siglent ---
		sleep "2"
		# --- terminate logger and wait for clean exit ---
		kill -TERM "$LOGGER_PID"
		wait "$LOGGER_PID"
		
		echo "Done. EnergyLogger Data in $OUTFILE"
		
		sleep "20"
		
		# --- Ready for new logging ---
		
		# --- EnergyLogger config ---
		SAMPLEPERIOD=0.04               # sample period for pmic_raw_logger
		TS=$(date +"%Y%m%d_%H%M%S")
		OUTFILE="pmic_log_${load}_${SAMPLEPERIOD}s_${TS}.csv"  # CSV output in timestamped filename
		
		# --- start energy logger (inactive) ---
		./pmic_raw_logger "$SAMPLEPERIOD" "$OUTFILE" &
		LOGGER_PID=$!
		echo "Logger started with PID $LOGGER_PID, logging to $OUTFILE"
		sleep 0.5  # let logger start
		
		
		send_start "$SAMPLEPERIOD" # -- start the siglent ---
		kill -USR1 "$LOGGER_PID" # --- mark logger active ---
		stress-ng --cpu 1 -l "$load" -t 80s &
		WORK_PID=$!
		echo "Workload PID: $WORK_PID"
		
		# wait for workload to finish
		wait "$WORK_PID"
		kill -USR2 "$LOGGER_PID"  # --- mark logger inactive ---
		send_stop "$SAMPLEPERIOD" # -- stop the siglent ---
		sleep "2"
		# --- terminate logger and wait for clean exit ---
		kill -TERM "$LOGGER_PID"
		wait "$LOGGER_PID"
		
		echo "Done. EnergyLogger Data in $OUTFILE"
		
		sleep "20"
		
	
		# --- Ready for new logging ---
		
		# --- EnergyLogger config ---
		SAMPLEPERIOD=0.03               # sample period for pmic_raw_logger
		TS=$(date +"%Y%m%d_%H%M%S")
		OUTFILE="pmic_log_${load}_${SAMPLEPERIOD}s_${TS}.csv"  # CSV output in timestamped filename
		
		# --- start energy logger (inactive) ---
		./pmic_raw_logger "$SAMPLEPERIOD" "$OUTFILE" &
		LOGGER_PID=$!
		echo "Logger started with PID $LOGGER_PID, logging to $OUTFILE"
		sleep 0.5  # let logger start
		
		
		send_start "$SAMPLEPERIOD" # -- start the siglent ---
		kill -USR1 "$LOGGER_PID" # --- mark logger active ---
		stress-ng --cpu 1 -l "$load" -t 80s &
		WORK_PID=$!
		echo "Workload PID: $WORK_PID"
		
		# wait for workload to finish
		wait "$WORK_PID"
		kill -USR2 "$LOGGER_PID"  # --- mark logger inactive ---
		send_stop "$SAMPLEPERIOD" # -- stop the siglent ---
		sleep "2"
		# --- terminate logger and wait for clean exit ---
		kill -TERM "$LOGGER_PID"
		wait "$LOGGER_PID"
		
		echo "Done. EnergyLogger Data in $OUTFILE"
		
		sleep "20"
		
		# --- Ready for new logging ---	
		# --- EnergyLogger config ---
		SAMPLEPERIOD=0.02               # sample period for pmic_raw_logger
		TS=$(date +"%Y%m%d_%H%M%S")
		OUTFILE="pmic_log_${load}_${SAMPLEPERIOD}s_${TS}.csv"  # CSV output in timestamped filename
		
		# --- start energy logger (inactive) ---
		./pmic_raw_logger "$SAMPLEPERIOD" "$OUTFILE" &
		LOGGER_PID=$!
		echo "Logger started with PID $LOGGER_PID, logging to $OUTFILE"
		sleep 0.5  # let logger start
		
		
		send_start "$SAMPLEPERIOD" # -- start the siglent ---
		kill -USR1 "$LOGGER_PID" # --- mark logger active ---
		stress-ng --cpu 1 -l "$load" -t 80s &
		WORK_PID=$!
		echo "Workload PID: $WORK_PID"
		
		# wait for workload to finish
		wait "$WORK_PID"
		kill -USR2 "$LOGGER_PID"  # --- mark logger inactive ---
		send_stop "$SAMPLEPERIOD" # -- stop the siglent ---
		sleep "2"
		# --- terminate logger and wait for clean exit ---
		kill -TERM "$LOGGER_PID"
		wait "$LOGGER_PID"
		
		echo "Done. EnergyLogger Data in $OUTFILE"
		
		sleep "20"
		
		# --- Ready for new logging ---
		
		# --- EnergyLogger config ---
		SAMPLEPERIOD=0.01               # sample period for pmic_raw_logger
		TS=$(date +"%Y%m%d_%H%M%S")
		OUTFILE="pmic_log_${load}_${SAMPLEPERIOD}s_${TS}.csv"  # CSV output in timestamped filename
		
		# --- start energy logger (inactive) ---
		./pmic_raw_logger "$SAMPLEPERIOD" "$OUTFILE" &
		LOGGER_PID=$!
		echo "Logger started with PID $LOGGER_PID, logging to $OUTFILE"
		sleep 0.5  # let logger start
		
		
		send_start "$SAMPLEPERIOD" # -- start the siglent ---
		kill -USR1 "$LOGGER_PID" # --- mark logger active ---
		stress-ng --cpu 1 -l "$load" -t 80s &
		WORK_PID=$!
		echo "Workload PID: $WORK_PID"
		
		# wait for workload to finish
		wait "$WORK_PID"
		kill -USR2 "$LOGGER_PID"  # --- mark logger inactive ---
		send_stop "$SAMPLEPERIOD" # -- stop the siglent ---
		sleep "2"
		# --- terminate logger and wait for clean exit ---
		kill -TERM "$LOGGER_PID"
		wait "$LOGGER_PID"
		
		echo "Done. EnergyLogger Data in $OUTFILE"
		
		sleep "20"
		
		# --- Ready for new logging ---
	
	done 
done


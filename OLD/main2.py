# cleaned version of the main script for 2 Hz logging to CSV

import pyvisa
import subprocess
import time
import csv
from datetime import datetime

# Set up the connection to the Siglent power supply
rm = pyvisa.ResourceManager()
sig = rm.open_resource('USB0::0xF4EC::0xEE38::SPD3XABC123456::INSTR')  # Update with your actual ID

# CSV output file
output_file = 'power_log.csv'

# Open CSV file for writing
with open(output_file, 'w', newline='') as csvfile:
    fieldnames = ['Timestamp', 'Pi_Temp_C', 'Pi_Voltage_V', 'Sig_Voltage_V', 'Sig_Current_A', 'Power_W']
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()

    print("Starting measurement loop (2 Hz)... Press Ctrl+C to stop.")
    try:
        while True:
            timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')[:-3]

            # Pi temperature
            temp_raw = subprocess.check_output(['vcgencmd', 'measure_temp']).decode('utf-8')
            temp_c = float(temp_raw.replace("temp=", "").replace("'C\n", ""))

            # Pi voltage
            volt_raw = subprocess.check_output(['vcgencmd', 'measure_volts']).decode('utf-8')
            pi_volt = float(volt_raw.replace("volt=", "").replace("V\n", ""))

            # Siglent SCPI measurements
            sig.write('MEAS:VOLT?')
            sig_volt = float(sig.read())

            sig.write('MEAS:CURR?')
            sig_curr = float(sig.read())

            power = sig_volt * sig_curr

            # Write to CSV
            writer.writerow({
                'Timestamp': timestamp,
                'Pi_Temp_C': temp_c,
                'Pi_Voltage_V': pi_volt,
                'Sig_Voltage_V': sig_volt,
                'Sig_Current_A': sig_curr,
                'Power_W': power
            })

            print(f"[{timestamp}] Temp: {temp_c:.2f}°C | Pi Volt: {pi_volt:.3f}V | Sig Volt: {sig_volt:.2f}V | Curr: {sig_curr:.3f}A | Power: {power:.2f}W")

            time.sleep(0.5)  # 2 Hz
    except KeyboardInterrupt:
        print("Measurement stopped by user.")
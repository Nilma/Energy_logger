import subprocess
import time
import csv
from datetime import datetime

def read_voltage_current():
    """Reads voltage and current from PMIC using vcgencmd."""
    voltage_cmd = ["vcgencmd", "pmic_read_adc", "vbus"]
    current_cmd = ["vcgencmd", "pmic_read_adc", "ibus"]

    voltage_output = subprocess.run(voltage_cmd, capture_output=True, text=True).stdout.strip()
    current_output = subprocess.run(current_cmd, capture_output=True, text=True).stdout.strip()

    try:
        voltage = int(voltage_output, 0) / 1000.0  # Convert mV to V
        current = int(current_output, 0) / 1000.0  # Convert mA to A
        return voltage, current
    except Exception as e:
        print(f"Error reading values: {e}")
        return None, None

def measure_energy_to_csv(duration_minutes=5, interval_seconds=1):
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"energy_log_{timestamp}.csv"

    print(f"Measuring energy for {duration_minutes} minutes...")
    print(f"Logging to {filename}")

    total_energy_joules = 0.0
    start_time = time.time()
    end_time = start_time + duration_minutes * 60

    with open(filename, mode='w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["Timestamp", "Voltage (V)", "Current (A)", "Power (W)", "Energy So Far (Joules)"])

        while time.time() < end_time:
            voltage, current = read_voltage_current()
            if voltage is not None and current is not None:
                power = voltage * current
                total_energy_joules += power * interval_seconds
                writer.writerow([
                    datetime.now().isoformat(timespec='seconds'),
                    f"{voltage:.3f}",
                    f"{current:.3f}",
                    f"{power:.3f}",
                    f"{total_energy_joules:.2f}"
                ])
            time.sleep(interval_seconds)

    print(f"Done! Total energy used: {total_energy_joules:.2f} J = {total_energy_joules / 3600:.6f} Wh")

# Run a 5-minute measurement
measure_energy_to_csv(duration_minutes=5)
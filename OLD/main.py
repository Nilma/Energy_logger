import subprocess
import time
import csv
from datetime import datetime

def read_voltage_current():
    """
    Reads core voltage and current from vcgencmd pmic_read_adc output.
    Specifically looks for VDD_CORE_V and VDD_CORE_A lines.
    """
    result = subprocess.run(["vcgencmd", "pmic_read_adc"], capture_output=True, text=True).stdout

    voltage = None
    current = None

    for line in result.splitlines():
        if "VDD_CORE_V" in line:
            try:
                voltage = float(line.split('=')[1].replace('V', '').strip())
            except ValueError:
                pass
        if "VDD_CORE_A" in line:
            try:
                current = float(line.split('=')[1].replace('A', '').strip())
            except ValueError:
                pass

    return voltage, current

def measure_energy_to_csv(duration_minutes=6, interval_seconds=0.1):
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")[:-3] 
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
                    f"{voltage:.6f}",
                    f"{current:.6f}",
                    f"{power:.6f}",
                    f"{total_energy_joules:.4f}"
                ])
            else:
                print("Warning: Voltage or current not available at this moment.")
            time.sleep(interval_seconds)

    print(f"Done! Total energy used: {total_energy_joules:.2f} J = {total_energy_joules / 3600:.6f} Wh")

# Run a 5-minute measurement
if __name__ == "__main__":
    measure_energy_to_csv(duration_minutes=6)
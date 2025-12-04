import subprocess
import time
import csv
from datetime import datetime
from math import isnan

def read_voltage_current():
    """
    Reads core voltage and current from `vcgencmd pmic_read_adc`.
    Looks for VDD_CORE_V and VDD_CORE_A lines.
    """
    result = subprocess.run(
        ["vcgencmd", "pmic_read_adc"],
        capture_output=True, text=True
    ).stdout

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

def measure_energy_to_csv(duration_minutes=6, interval_seconds=0.1):  # 10 Hz
    # Timestamp with milliseconds
    ts = datetime.now().strftime("%Y%m%d_%H%M%S_%f")[:-3]
    filename = f"energy_log_{ts}.csv"

    print(f"Measuring energy for {duration_minutes} minutes at {1/interval_seconds:.1f} Hz...")
    print(f"Logging to {filename}")

    total_energy_joules = 0.0

    # Use a monotonic clock for scheduling & delta times
    t_start = time.perf_counter()
    t_end   = t_start + duration_minutes * 60
    t_prev  = t_start
    next_tick = t_start  # target time for next sample

    with open(filename, mode='w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow([
            "Timestamp (ISO ms)",
            "Voltage (V)",
            "Current (A)",
            "Power (W)",
            "dt (s)",
            "Energy So Far (J)"
        ])

        sample_idx = 0
        while True:
            now_perf = time.perf_counter()
            if now_perf >= t_end:
                break

            # Read sensor
            voltage, current = read_voltage_current()
            timestamp_iso_ms = datetime.now().isoformat(timespec='milliseconds')

            # Compute dt from last sample (first sample uses small dt=0)
            dt = now_perf - t_prev if sample_idx > 0 else 0.0

            if (voltage is not None) and (current is not None):
                power = voltage * current  # Watts
                # Integrate using actual dt to avoid error from jitter
                total_energy_joules += power * dt
                v_str = f"{voltage:.6f}"
                c_str = f"{current:.6f}"
                p_str = f"{power:.6f}"
            else:
                # If a reading failed, log blanks for V/I/P and do not add energy
                v_str = ""
                c_str = ""
                p_str = ""
                print("Warning: Voltage or current not available at this moment.")

            writer.writerow([
                timestamp_iso_ms,
                v_str,
                c_str,
                p_str,
                f"{dt:.6f}",
                f"{total_energy_joules:.6f}"
            ])

            # Schedule next tick exactly interval_seconds ahead to minimize drift
            sample_idx += 1
            t_prev = now_perf
            next_tick += interval_seconds
            # If we fell behind, catch up without sleeping negative time
            sleep_for = max(0.0, next_tick - time.perf_counter())
            if sleep_for:
                time.sleep(sleep_for)

    print(f"Done! Total energy used: {total_energy_joules:.3f} J = {total_energy_joules / 3600:.6f} Wh")

# Run a 5-minute measurement at 10 Hz when executed directly
if __name__ == "__main__":
    measure_energy_to_csv(duration_minutes=6, interval_seconds=0.1)
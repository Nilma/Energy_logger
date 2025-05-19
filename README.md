# Raspberry Pi 5 Power Measurement Logger

This project provides a simple Python script to measure voltage, current, power, and energy consumption on a Raspberry Pi 5 using the `vcgencmd pmic_read_adc` command. Results are logged in real-time to a CSV file.

## Requirements

### Hardware
- Raspberry Pi 5 (or compatible model with onboard PMIC)
- Internet connection (for installing packages)
- PMIC support via `vcgencmd` (typically pre-installed on Raspberry Pi OS)

### Software

#### Python 3
Make sure Python 3 is installed:

```bash
python3 --version
```

If not installed:

```bash
sudo apt update
sudo apt install python3 python3-pip -y
```

#### vcgencmd
This should already be available on Raspberry Pi OS. You can test it with:

```bash
vcgencmd pmic_read_adc vbus
```

You should get output like: `0x000003b3` (hexadecimal, which the script converts automatically).

## What the Script Does

- Reads voltage and current from the Raspberry Pi’s power rails using:
  - `vcgencmd pmic_read_adc vbus` (voltage in mV)
  - `vcgencmd pmic_read_adc ibus` (current in mA)
- Calculates power = voltage × current
- Accumulates energy over time: energy = power × time (in seconds)
- Logs readings at regular intervals to a CSV file

## How to Use

1. Save the script below as `energy_logger.py` on your Raspberry Pi.
2. Run the script:

```bash
python3 energy_logger.py
```

This will:
- Measure energy usage for 5 minutes
- Log results to a file like `energy_log_YYYYMMDD_HHMMSS.csv`

## Output Format

The CSV file contains:

| Timestamp           | Voltage (V) | Current (A) | Power (W) | Energy So Far (Joules) |
|---------------------|-------------|-------------|-----------|--------------------------|
| 2025-05-19T10:30:01 | 5.124       | 1.203       | 6.168     | 6.17                     |

## Customization

You can change:

```python
measure_energy_to_csv(duration_minutes=5, interval_seconds=1)
```

to adjust the measurement duration or frequency.

## Copyright

© 2025 Nilma. All rights reserved.
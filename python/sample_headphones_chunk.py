from neurosdk.scanner import Scanner
from neurosdk.cmn_types import *

from pylsl import StreamInfo, StreamOutlet
from time import sleep

# --------------------------------------------------
# LSL SETUP
# --------------------------------------------------

info = StreamInfo(
    'BrainBit',
    'EEG',
    4,
    250,
    'float32',
    'brainbit001'
)

outlet = StreamOutlet(info)

print("LSL Outlet Created Successfully")

# --------------------------------------------------
# CHUNK SETTINGS
# --------------------------------------------------

CHUNK_SIZE = 50
buffer = []

# --------------------------------------------------
# CALLBACKS
# --------------------------------------------------

def sensor_found(scanner, sensors):
    for sensor in sensors:
        print("Sensor found:", sensor)


def on_sensor_state_changed(sensor, state):
    print(f"Sensor {sensor.name} is {state}")


def on_battery_changed(sensor, battery):
    print("Battery:", battery)


def on_signal_received(sensor, data):

    global buffer

    for sample in data:

        buffer.append([
            sample.Ch1,
            sample.Ch2,
            sample.Ch3,
            sample.Ch4
        ])

        if len(buffer) >= CHUNK_SIZE:

            outlet.push_chunk(buffer)

            print(f"Sent chunk of {len(buffer)} samples")

            buffer = []


def on_resist_received(sensor, data):
    print("Resistance:", data)


def on_amp_received(sensor, data):
    print("Amplifier mode:", data)


# --------------------------------------------------
# MAIN
# --------------------------------------------------

try:

    scanner = Scanner([SensorFamily.LEHeadPhones2])

    scanner.sensorsChanged = sensor_found

    print("Searching for BrainBit...")

    scanner.start()

    sleep(5)

    scanner.stop()

    sensors = scanner.sensors()

    if len(sensors) == 0:
        print("No BrainBit found.")
        exit()

    sensor = scanner.create_sensor(sensors[0])

    print("Device connected")

    sensor.sensorStateChanged = on_sensor_state_changed
    sensor.batteryChanged = on_battery_changed
    sensor.sensorAmpModeChanged = on_amp_received

    if sensor.is_supported_feature(SensorFeature.Signal):
        sensor.signalDataReceived = on_signal_received

    if sensor.is_supported_feature(SensorFeature.Resist):
        sensor.resistDataReceived = on_resist_received

    print("Name:", sensor.name)
    print("Battery:", sensor.batt_power)
    print("Serial:", sensor.serial_number)

    # --------------------------------------------------
    # START EEG STREAM
    # --------------------------------------------------

    if sensor.is_supported_command(SensorCommand.StartSignal):

        sensor.exec_command(SensorCommand.StartSignal)

        print("Streaming EEG in chunks...")
        print("Recording for 10 seconds...\n")

        sleep(10)

        sensor.exec_command(SensorCommand.StopSignal)

        print("EEG streaming stopped.")

    # --------------------------------------------------
    # SEND ANY REMAINING SAMPLES
    # --------------------------------------------------

    if len(buffer) > 0:

        outlet.push_chunk(buffer)

        print(f"Sent final chunk of {len(buffer)} samples")

        buffer = []

    # --------------------------------------------------
    # OPTIONAL RESISTANCE
    # --------------------------------------------------

    if sensor.is_supported_command(SensorCommand.StartResist):

        sensor.exec_command(SensorCommand.StartResist)

        print("Reading resistance...")

        sleep(5)

        sensor.exec_command(SensorCommand.StopResist)

        print("Resistance measurement stopped.")

    sensor.disconnect()

    print("Disconnected from BrainBit.")

    del sensor
    del scanner

    print("Finished.")

except Exception as err:

    print(err)

from neurosdk.scanner import Scanner
from neurosdk.cmn_types import *

from pylsl import StreamInfo, StreamOutlet
from time import sleep

# ==========================================================
# LSL STREAM SETUP
# ==========================================================

info = StreamInfo(
    name='BrainBit',
    type='EEG',
    channel_count=4,
    nominal_srate=250,
    channel_format='float32',
    source_id='BrainBit_EEG_001'
)

# Send chunks instead of single samples
outlet = StreamOutlet(
    info,
    chunk_size=8,      # LSL may package data efficiently; actual callback size may vary
    max_buffered=360
)

print("===================================================")
print("BrainBit LSL Chunk Stream Created")
print("===================================================")

chunk_count = 0
sample_count = 0

# ==========================================================
# CALLBACKS
# ==========================================================

def sensor_found(scanner, sensors):
    for sensor in sensors:
        print("Sensor Found:", sensor)


def on_sensor_state_changed(sensor, state):
    print("Sensor State:", state)


def on_battery_changed(sensor, battery):
    print("Battery:", battery, "%")


def on_amp_changed(sensor, mode):
    print("Amplifier Mode:", mode)


def on_resist(sensor, data):
    # Only for checking electrode contact.
    # Do NOT stream resistance values.
    pass


def on_signal(sensor, data):
    first = data[0]
    last = data[-1]
        # -------- EEG SIGNAL QUALITY CHECK --------
    channels = [
        [x.Ch1 for x in data],
        [x.Ch2 for x in data],
        [x.Ch3 for x in data],
        [x.Ch4 for x in data]
    ]

    print("\n--- EEG Quality Check ---")

    for i, ch in enumerate(channels, start=1):
        minimum = min(ch)
        maximum = max(ch)
        mean = sum(ch) / len(ch)

        print(
            f"Ch{i}: "
            f"Min={minimum:.6f}, "
            f"Max={maximum:.6f}, "
            f"Mean={mean:.6f}"
        )

    print("------------------------")

    print("\nFirst Sample")
    print(first)

    print("\nLast Sample")
    print(last)

    global chunk_count
    global sample_count

    # ------------------------------------------
    # Convert BrainBit buffer into LSL chunk
    # ------------------------------------------

    chunk = []
    callback_size = len(data)

    for sample in data:

        chunk.append([
            float(sample.Ch1),
            float(sample.Ch2),
            float(sample.Ch3),
            float(sample.Ch4)
        ])

    # Push the entire buffer as ONE chunk
    if chunk_count == 0:

     print("\n========== FIRST CALLBACK ==========")
     print("Callback Size :", callback_size)
     print("Chunk Size    :", len(chunk))
     print("First Sample  :", chunk[0])
     print("Last Sample   :", chunk[-1])
     print("====================================")
    outlet.push_chunk(chunk)

    chunk_count += 1
    sample_count += len(chunk)

    # Print every 10 chunks
    if chunk_count % 10 == 0:

        last = data[-1]

        print("\n======================================")
        print(f"Chunk Number : {chunk_count}")
        print(f"Samples Sent : {sample_count}")
        print(f"Chunk Size   : {len(chunk)}")

        print("\nLast Sample in Chunk")

        print(f"Ch1 : {last.Ch1:.6f}")
        print(f"Ch2 : {last.Ch2:.6f}")
        print(f"Ch3 : {last.Ch3:.6f}")
        print(f"Ch4 : {last.Ch4:.6f}")

        print("======================================")

# ==========================================================
# MAIN
# ==========================================================

scanner = None
sensor = None

try:

    scanner = Scanner([SensorFamily.LEHeadPhones2])

    scanner.sensorsChanged = sensor_found

    print("\nSearching for BrainBit...")

    scanner.start()

    sleep(5)

    scanner.stop()

    sensors = scanner.sensors()

    if len(sensors) == 0:
        raise Exception("No BrainBit Found.")

    sensor = scanner.create_sensor(sensors[0])

    print("\nConnected Successfully")

    sensor.sensorStateChanged = on_sensor_state_changed
    sensor.batteryChanged = on_battery_changed
    sensor.sensorAmpModeChanged = on_amp_changed

    if sensor.is_supported_feature(SensorFeature.Signal):
        sensor.signalDataReceived = on_signal

    if sensor.is_supported_feature(SensorFeature.Resist):
        sensor.resistDataReceived = on_resist

    print("\n================ DEVICE ================")
    print("Name    :", sensor.name)
    print("Battery :", sensor.batt_power)
    print("Serial  :", sensor.serial_number)
    print("========================================")

    if sensor.is_supported_command(SensorCommand.StartSignal):

        sensor.exec_command(SensorCommand.StartSignal)

        print("\n========================================")
        print("Continuous EEG Chunk Streaming Started")
        print("LSL Stream Name : BrainBit_EEG")
        print("Stream Type     : EEG")
        print("Channels        : 4")
        print("Sampling Rate   : 250 Hz")
        print("Transmission    : CHUNKS")
        print("")
        print("Waiting for MATLAB / Android / LSL...")
        print("Press Ctrl+C to stop.")
        print("========================================")

        while True:
            sleep(1)

except KeyboardInterrupt:

    print("\nStopping EEG Stream...")

    try:
        sensor.exec_command(SensorCommand.StopSignal)
    except:
        pass

    print("EEG Stream Stopped")

except Exception as err:

    print("\nERROR")
    print(err)

finally:

    print("\nCleaning up...")

    try:
        sensor.disconnect()
    except:
        pass

    try:
        del sensor
    except:
        pass

    try:
        del scanner
    except:
        pass

    try:
        del outlet
    except:
        pass

    print("BrainBit disconnected")
    print("LSL Outlet deleted")
    print("Program finished")

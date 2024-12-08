import os
import time
import json
import board
import busio
import wifi
import ssl
import socketpool
import adafruit_requests
import adafruit_drv2605

# Initialize DRV2605 for haptic motor control
i2c = busio.I2C(board.SCL, board.SDA)
drv = adafruit_drv2605.DRV2605(i2c)

# Connect to Wi-Fi
def connect_to_wifi():
    print("Connecting to Wi-Fi...")
    wifi.radio.connect(os.getenv("CIRCUITPY_WIFI_SSID"), os.getenv("CIRCUITPY_WIFI_PASSWORD"))
    print("Connected! IP address:", wifi.radio.ipv4_address)

# Firebase RTDB REST URL
FIREBASE_PROJECT_ID = os.getenv("FIREBASE_PROJECT_ID")
FIREBASE_API_KEY = os.getenv("FIREBASE_API_KEY")
SCHOOL_ID = os.getenv("SCHOOL_ID")
TEACHER_ID = os.getenv("TEACHER_ID")
FIREBASE_URL = f"https://{FIREBASE_PROJECT_ID}-default-rtdb.firebaseio.com/schools/{SCHOOL_ID}/{TEACHER_ID}.json"
HEADERS = {"Content-Type": "application/json"}

# Initialize socket and requests
pool = socketpool.SocketPool(wifi.radio)
requests = adafruit_requests.Session(pool, ssl.create_default_context())

# Trigger haptic motor
def trigger_haptic():
    print("Triggering haptic motor...")
    # drv.sequence[0] = adafruit_drv2605.Effect(1)  # Example effect
    # drv.play()
    # time.sleep(0.5)
    # drv.stop()

    # Define a sequence of strong effects
    drv.sequence[0] = adafruit_drv2605.Effect(7)  # Strong click effect
    drv.sequence[1] = adafruit_drv2605.Effect(7)  # Strong click effect
    drv.sequence[2] = adafruit_drv2605.Effect(7)  # Strong click effect
    
    # Play the sequence multiple times for emphasis
    for _ in range(3):  # Repeat the sequence 3 times
        drv.play()
        time.sleep(0.5)  # Pause between sequences
        drv.stop()

# Poll Firebase RTDB for updates
def poll_firebase():
    print("Polling Firebase RTDB...")
    while True:
        try:
            # Send GET request to Firebase
            response = requests.get(FIREBASE_URL + "?auth=" + FIREBASE_API_KEY, headers=HEADERS)
            if response.status_code == 200:
                data = response.json()
                print("Firebase data:", data)
                if data and data["trigger"]:
                    trigger_haptic()
                    print("Haptic feedback triggered!")
                    
                    # # Optional: Reset the trigger (requires write permissions in Firebase)
                    # reset_payload = {"trigger": False}
                    # requests.patch(FIREBASE_URL, json=reset_payload, headers=HEADERS)
            else:
                print("Failed to fetch Firebase data:", response.status_code)
        except Exception as e:
            print("Error polling Firebase:", e)
        
        # Adjust polling interval as needed
        time.sleep(5)

# Main loop
try:
    connect_to_wifi()
    poll_firebase()  # Blocking call to listen for changes
except Exception as e:
    print("Error:", e)

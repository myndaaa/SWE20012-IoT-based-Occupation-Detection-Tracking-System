# if camera detects someone during booking duration it will publish 1 in 'detection' topic
# ===> in arduino if received something in detection it will turn on buzzer, buzzer turns off when rfid scanned
# if rfid has been scanned it will send uid to rfid topic, if rfid scanned then human detection would not be published in mqtt
#whenever theres a new entry on the collection Neopixel, the string in attribute "Hexcode" of the collection will be published to Neocolor topic
#If there is any Document in the Bookings collection, and the current timestamp and BookingStart attributes timestamp has less than 15 mins
#duration gap 

# booking =====> 15 min before start -- table goes reduce
#detection =======> buzzer by joseph
#Neocolor =======> Hexcode
# rfid ============> UID

import firebase_admin
from firebase_admin import credentials, firestore
import paho.mqtt.client as mqtt
from datetime import datetime, timedelta
import pytz
import time

# MQTT Broker Setup
BROKER_IP = "172.17.160.137"  # Define the IP address of the MQTT broker
BOOKING_TOPIC = "Booking"  # Define the MQTT topic for booking notifications
RFID_TOPIC = "rfid"  # Define the MQTT topic for RFID scan data
NEOCOLOR_TOPIC = "Neocolor"  # Define the MQTT topic for Neopixel color updates

# Timezone Setup
timezone = pytz.timezone("Singapore")  # Set the timezone to Singapore

# Firebase Initialization
SERVICE_ACCOUNT_PATH = r"/home/pi/Desktop/confidential/swinburne-kch-iot-firebase-adminsdk-wkqg1-4fb0d3345d.json"  # Path to the Firebase service account credentials
cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)  # Load Firebase service account credentials
firebase_admin.initialize_app(cred)  # Initialize the Firebase SDK

db = firestore.client()  # Create a Firestore client instance

# MQTT Client Setup
client = mqtt.Client()  # Initialize the MQTT client

# Callback when a message is published on the "rfid" topic
def on_message(client, userdata, message):
    if message.topic == RFID_TOPIC:
        uid = message.payload.decode()  # Decode the UID from the message payload
        current_time = datetime.now(timezone)  # Get the current time in the specified timezone
        
        # Find the ongoing booking
        bookings_ref = db.collection("Booking")  # Reference the 'Booking' collection in Firestore
        ongoing_booking = bookings_ref.where("BookingStart", "<=", current_time).where("BookingEnd", ">", current_time).stream()  # Query for ongoing bookings
        
        booking_id = None
        for booking in ongoing_booking:
            booking_id = booking.id  # Get the booking ID of the ongoing booking
            break
        
        # Insert new document to RFIDScanned collection
        if booking_id:
            rfid_data = {
                "UID": uid,
                "TimeScanned": current_time,
                "Booking": booking_id
            }
            db.collection("RFIDScanned").add(rfid_data)  # Add a new document to the 'RFIDScanned' collection in Firestore
            print(f"Inserted RFID scan: {rfid_data}")

# Callback when a new document is added to Neopixel collection
def neopixel_listener(doc_snapshot, changes, read_time):
    for change in changes:
        if change.type.name == 'ADDED':
            doc = change.document.to_dict()  # Convert the document snapshot to a dictionary
            hexcode = doc.get("hexcode")  # Get the hex color code from the document
            if hexcode:
                client.publish(NEOCOLOR_TOPIC, hexcode)  # Publish the hex color code to the Neocolor topic
                print(f"Published hexcode {hexcode} to topic {NEOCOLOR_TOPIC}")

# Function to check Booking collection for upcoming bookings
def check_upcoming_bookings():
    current_time = datetime.now(timezone)  # Get the current time in the specified timezone
    upcoming_time = current_time + timedelta(minutes=15)  # Define the upcoming time window (15 minutes from now)
    bookings_ref = db.collection("Booking")  # Reference the 'Booking' collection in Firestore
    upcoming_bookings = bookings_ref.where("BookingStart", "<=", upcoming_time).where("BookingStart", ">", current_time).stream()  # Query for upcoming bookings
    
    for booking in upcoming_bookings:
        client.publish(BOOKING_TOPIC, "1")  # Publish '1' to the booking topic to indicate an upcoming booking
        print(f"Published '1' to topic {BOOKING_TOPIC} for booking ID: {booking.id}")

# MQTT Setup
client.on_message = on_message  # Set the callback function to handle incoming messages
client.connect(BROKER_IP, 1883, 60)  # Connect to the MQTT broker at the specified IP and port
client.subscribe(RFID_TOPIC)  # Subscribe to the RFID topic to receive scan data
client.loop_start()  # Start the MQTT client loop to process messages

# Firestore listener for Neopixel collection
neopixel_ref = db.collection("Neopixel")  # Reference the 'Neopixel' collection in Firestore
neopixel_watch = neopixel_ref.on_snapshot(neopixel_listener)  # Set up a listener for changes in the 'Neopixel' collection

# Periodically check for upcoming bookings
try:
    while True:
        check_upcoming_bookings()  # Check for upcoming bookings every minute
        time.sleep(60)  # Wait for 60 seconds before checking again
except KeyboardInterrupt:
    print("Stopping the script...")
finally:
    client.loop_stop()  # Stop the MQTT client loop

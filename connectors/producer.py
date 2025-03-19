# Simple producer
import requests
import time
import json
import logging
from quixstreams import Application
# From file config.py import objects openweathermap_config, kafka_config
from config import openweathermap_config, kafka_config

def get_weather():
    openweathermap_api_key=openweathermap_config["api_key"]
    location=openweathermap_config["location"]
    response=requests.get(
        "https://api.openweathermap.org/data/2.5/weather", 
        params={
            "q":location,
            "APPID":openweathermap_api_key,
        }
    )

    return response.json()

def main():
    broker_address = kafka_config["broker_address"]
    topic_name = kafka_config["topic_name"]
    app = Application(
        broker_address=broker_address,
        loglevel="DEBUG"
    )

    with app.get_producer() as producer:
        #while True:
        i=1
        while i<2:
            weather = get_weather()
            logging.debug("Got weather %s:", weather)
            producer.produce(
                topic=topic_name,
                key="Sofia",
                value=json.dumps(weather)
            )
            logging.info("Produced. Sleeping...")
            # sleep 10 seconds
            time.sleep(10)
            i=i+1

if __name__ == "__main__":
    logging.basicConfig(level="DEBUG")
    main()


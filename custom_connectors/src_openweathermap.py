import requests
import time
import json
import logging
from quixstreams import Application

def get_weather():
    response = requests.get(
        "https://api.openweathermap.org/data/2.5/weather", 
        params={
            "q": "Sofia,bg",
            "APPID": "3dfe0e61125f9ddba9428d2f77f45faf"
        }
    )

    return response.json()

def main():
    app = Application(
        broker_address="localhost:9092",
        loglevel="DEBUG"
    )

    with app.get_producer() as producer:
        #while True:
        i=1
        while i<4:
            weather = get_weather()
            logging.debug("Got weather %s:", weather)
            producer.produce(
                topic="openweathermap-data-demo",
                key="Sofia",
                value=json.dumps(weather)
            )
            logging.info("Produced. Sleeping...")
            time.sleep(70)
            i=i+1

if __name__ == "__main__":
    logging.basicConfig(level="DEBUG")
    main()


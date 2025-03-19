# This consumer reads from an input_topic, transforms the messages and writes them to an output topic
import logging
import sys
import requests
# From file config.py import object openweathermap_config
from config import kafka_config
from quixstreams import Application

def transform(msg):
    absolute_zero = 273.15
    new_msg = msg
    kelvin = msg["main"]["temp"]
    celcius = kelvin - absolute_zero
    fahrenheit = (celcius * 9/5) + 32

    new_msg = {
        "kelvin": kelvin,
        "celcius": round(celcius, 2),
        "fahrenheit": round(fahrenheit, 2)
    }
    
    logging.debug("Returning: %s", new_msg)

    return new_msg

def main():
    logging.info("START")

    broker_address = kafka_config["broker_address"]
    input_topic_name = kafka_config["input_topic_name"]
    output_topic_name = kafka_config["output_topic_name"]

    app = Application(
        broker_address=broker_address,
        loglevel="DEBUG",
        # start reading topic from the beggining:
        auto_offset_reset="earliest",
        # to read the topic from the beggining on each run the consumer_group should be changed
        consumer_group="weather_processor3",
    )

    input_topic = app.topic(input_topic_name)
    output_topic = app.topic(output_topic_name)
    
    # read the input_topic into a dataframe
    sdf = app.dataframe(input_topic)
    # apply transformations
    sdf = sdf.apply(transform)
    # write transformed data into the output_topic
    sdf = sdf.to_topic(output_topic)
    app.run(sdf)

if __name__ == "__main__":
    logging.basicConfig(level = logging.DEBUG)
    sys.exit(main())
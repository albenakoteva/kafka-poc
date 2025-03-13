import json
from quixstreams import Application

def main():
    app = Application(
            broker_address="localhost:9092",
            loglevel="DEBUG",
            consumer_group="openweathermap_reader",
            # start reading topic from the beggining:
            #auto_offset_reset="earliest",
            # ignore old messages or if you have instructed it to remeber the last consumed offset (see line 31), it will proceed from that offset onwards:
            auto_offset_reset="latest",
        )

    with app.get_consumer() as consumer:
        consumer.subscribe(["openweathermap-data-demo"])

        while True:
            msg = consumer.poll(1)
            if msg is None:
                print("Waiting...")
            elif msg.error() is not None:
                raise Exception(msg.error())
            else:
                key = msg.key().decode("utf8")
                value = json.loads(msg.value())
                offset = msg.offset()

                print(f"{offset} {key} {value}")

                # Remember which is the last consumed message offset
                consumer.store_offsets(msg)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass

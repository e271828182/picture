version: '3.7'

services:
    kafka:
        container_name: kafka
        image: star/kafka:2.5.0
        hostname: kafka
        environment:
            KAFKA_ADVERTISED_HOST_NAME: 192.168.99.100
        ports:
            - 9092:9092
        restart: always
        volumes:
            - ./conf/server.properties:/opt/kafka/config/server.properties
        networks: 
            - default-bridge
networks: 
    default-bridge:
        name: default-bridge
        driver: bridge

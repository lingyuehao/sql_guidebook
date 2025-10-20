DROP TABLE IF EXISTS routes;
DROP TABLE IF EXISTS planes;
DROP TABLE IF EXISTS airports;
DROP TABLE IF EXISTS airlines;

CREATE TABLE airlines (
    airline_id INTEGER PRIMARY KEY,
    name TEXT,
    alias TEXT,
    iata VARCHAR(2),
    icao VARCHAR(3),
    callsign TEXT,
    country TEXT,
    active CHAR(1)  
);

CREATE TABLE airports (
    airport_id INTEGER PRIMARY KEY,
    name TEXT,
    city TEXT,
    country TEXT,
    iata VARCHAR(3),
    icao VARCHAR(4),
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    altitude INTEGER,              
    timezone DOUBLE PRECISION,     
    dst CHAR(1),                   
    tz_database_timezone TEXT,    
    type TEXT,                  
    source TEXT                    
);

CREATE TABLE planes (
    name TEXT,
    iata VARCHAR(3),
    icao VARCHAR(4),
    PRIMARY KEY (name, iata, icao)
);

CREATE TABLE routes (
    airline VARCHAR(3),
    airline_id INTEGER,
    source_airport VARCHAR(4),
    source_airport_id INTEGER,
    destination_airport VARCHAR(4),
    destination_airport_id INTEGER,
    codeshare CHAR(1),      
    stops INTEGER,         
    equipment TEXT          
);

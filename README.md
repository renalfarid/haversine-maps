# Data Source

Menggunakan datasource SMA Sederajat di sulawesi barat. Lokasi file public/data/sekolah.json

## Cara install

Project ini menggunakan google maps API, buat account dan API Key : https://developers.google.com/maps/documentation/javascript

- clone this source
- buat .env file, GOOGLE_MAPS_KEY=<google maps key>
- build images using docker : docker build -t diknas-project .
- run images : docker run -p 80:8080
- open browser : http://localhost:8080
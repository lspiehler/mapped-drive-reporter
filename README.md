## Build Container
docker build -t lspiehler/mapped-drive-reporter:commit .

## Run Container
docker run -it -d --restart=always --name=mapped-drive-reporter -p 3001:3001 lspiehler/mapped-drive-reporter:commit
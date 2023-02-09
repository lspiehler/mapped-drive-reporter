## Build Container
docker build -t lspiehler/mapped-drive-reporter:commit .

## Run Container
docker run -it -d --restart=always --name=mapped-drive-reporter -e "DBHOST=$(ip -4 addr show docker0 | grep -Po 'inet \K[\d.]+')" -e DBUSER='yourdbuser' -e DBPASS='yourdbpassword' -e DBNAME='yourdbname' -e LISTENPORT=3001 -p 3001:3001 lspiehler/mapped-drive-reporter:commit
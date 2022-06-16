FROM docker.io/node:lts-alpine3.16
LABEL maintainer Lyas Spiehler

RUN mkdir -p /var/node/mapped-drive-reporter

ADD . /var/node/mapped-drive-reporter/

WORKDIR /var/node/mapped-drive-reporter

RUN npm install

EXPOSE 3000/tcp

CMD ["node", "index.js"]
const express = require('express');
const app = express();
const routes = require("./routes.js");
const swaggerUi = require('swagger-ui-express');
const YAML = require('yamljs');
const swaggerDocument = YAML.load('swagger.yml');
const requestIp = require('request-ip');
app.use(requestIp.mw())
const config = require('./config');

app.use(express.urlencoded({extended: true})); 
//app.use(express.json());

routes(app);

var server = app.listen(config.LISTENPORT, function () {
    console.log("app running on port.", server.address().port);
});

var options = {
    //customCssUrl: '/custom.css'
};
  
app.use('/', swaggerUi.serve, swaggerUi.setup(swaggerDocument, options));

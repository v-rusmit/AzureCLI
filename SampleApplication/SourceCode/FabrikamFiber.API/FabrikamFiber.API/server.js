'use strict';


var http = require('http');
var express = require('express');
var bodyParser = require('body-parser');

var app = express();
app.use(bodyParser.urlencoded({
    extended: true
}));
app.use(bodyParser.json());

var controllers = require('./controllers');
controllers.init(app);

var repositories = require('./data');
repositories.init(app);


var server = http.createServer(app);

//server.listen(3000);
server.listen(process.env.PORT);

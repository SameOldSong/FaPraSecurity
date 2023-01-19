const express = require('express');
const mariadb = require('mariadb');
const https = require('https');
const fs = require('fs');
const app = express();
const httpsPort = 5000;
const dbCaCert = [fs.readFileSync("/etc/ssl/certs/ca.pem"), "utf8"];
app.use(express.static('/var/www/fapraweb/public'));

const dbClientKey = [fs.readFileSync("/etc/ssl/private/dbclient-key.pem")];
const dbClientCert = [fs.readFileSync("/etc/ssl/certs/dbclient-cert.pem")];

var key = fs.readFileSync("/etc/ssl/private/webkey.pem");
var cert = fs.readFileSync("/etc/ssl/certs/webcert.pem");

var credentials = {
  key: key,
  cert: cert
};

app.get('/', (req, res) => {        
    res.sendFile('index.html', {root: __dirname});     
});

var httpsServer = https.createServer(credentials, app);

httpsServer.listen(httpsPort, () => {
  console.log("Https server listing on port : " + httpsPort)
});


app.get('/clicked', (req, res) => {
  const click = 1 + Math.floor(Math.random() * 6);
  console.log(click);
  var params = [click];
 
mariadb
 .createConnection({
   host: 'database', 
   ssl: {
	//only for TESTING! comment this out for PRODUCTION when using CA signed certificates!!!
	rejectUnauthorized: false,
	
	ca: dbCaCert,
	cert: dbClientCert,
	key: dbClientKey
   }, 
   user: 'fapraweb'
 }).then(conn => {

	 console.log("Works");
  
	 var sql = "SELECT quote FROM fapraweb.quotes WHERE item_id = ?";
	 conn.query(sql, params).then((result) => {
	   console.log(result);
	   res.send(result); conn.end();

	 }).catch(error => { 
		 console.log("something wrong with query"); 
		 console.log(error);
	 });
 }).catch(error => { 
	console.log(error); 
	console.log("something wrong with connection");});
});


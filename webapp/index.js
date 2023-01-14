const express = require('express');
const mariadb = require('mariadb');
const fs = require('fs');
const app = express();
const port = 5000;
const serverCert = [fs.readFileSync("/var/www/fapraweb/server-cert.pem"), "utf8"];
app.use(express.static('/var/www/fapraweb/webapp/public'));

const clientKey = [fs.readFileSync("/var/www/fapraweb/client-key.pem")];
const clientCert = [fs.readFileSync("/var/www/fapraweb/client-cert.pem")];

//Idiomatic expression in express to route and respond to a client request
app.get('/', (req, res) => {        
    res.sendFile('index.html', {root: __dirname});     
});

app.listen(port, () => {            
    console.log(`Now listening on port ${port}`); 
});


app.get('/clicked', (req, res) => {
  const click = 1 + Math.floor(Math.random() * 6);
  console.log(click);
  var params = [click];
 
mariadb
 .createConnection({
   host: 'database', 
   ssl: {
	//only for TESTING, not for PRODUCTION!!!
	rejectUnauthorized: false,
	
	ca: serverCert,
	cert: clientCert,
	key: clientKey
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
 }).catch(error => { console.log(error); console.log("something wrong with connection");});


});


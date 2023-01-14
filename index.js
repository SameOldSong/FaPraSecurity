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
app.get('/', (req, res) => {        //get requests to the root ("/") will route here
    res.sendFile('index.html', {root: __dirname});      //server responds by sending the index.html file to the client's browser
                                                        //the .sendFile method needs the absolute path to the file, see: https://expressjs.com/en/4x/api.html#res.sendFile 
});

app.listen(port, () => {            //server starts listening for any attempts from a client to connect at port: {port}
    console.log(`Now listening on port ${port}`); 
});


app.get('/clicked', (req, res) => {
  const click = 1 + Math.floor(Math.random() * 6);
  console.log(click);
  var params = [1];
 
mariadb
 .createConnection({
   host: 'database', 
   ssl: {
	//rejectUnauthorized: false,
	
	ca: serverCert,
	cert: clientCert,
	key: clientKey
   }, 
   user: '510',
	 debug: true
 }).then(conn => {

	 console.log("Works");
  
	 var sql = "SELECT quote FROM fapraweb.quotes WHERE item_id = ?";
	 conn.query(sql, params).then(
		 (result) => {console.log(result);
	res.send(result); conn.end();

	 }).catch(error => { console.log("query!!!!"); console.log(error);});
 }).catch(error => { console.log(error); console.log("conn!!!");});
//const pool = mariadb.createPool({
  //     host: "192.168.1.13",
    //   user: "ssl",
     //  debug: true,
     //  password: "a",
     //  ssl: {}
     //host: process.env.DB_HOST,
     //user: process.env.DB_USER,
     //password: process.env.DB_PWD,
     //connectionLimit: 5
//});

//  pool.getConnection()
  //  .then(conn => {
    //  var sql = "SELECT quote FROM fapraweb.quotes WHERE item_id = ?";  
     // conn.query(sql, params)
      //  .then((result) => {
        //  console.log(result);
 //res.send(result);
   //       conn.end();
     //   })
       // .catch(err => {
          //handle error
         // console.log("First");
         // console.log(err);
         // conn.end();
       // })
       
//    }).catch(err => {
//	    console.log("Second");
 //     console.log(err);
  //  });


  
});


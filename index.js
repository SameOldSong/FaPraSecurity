const express = require('express');
const mariadb = require('mariadb');

const app = express();
const port = 5000;

app.use(express.static('public'));

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
  var params = [click];
 
  const pool = mariadb.createPool({
     host: '192.168.1.13',
     user:'fapraweb',
     password: '%gQ-22Fa?Wh5',
     connectionLimit: 5
});

  pool.getConnection()
    .then(conn => {
      var sql = "SELECT quote FROM fapraweb.quotes WHERE item_id = ?";  
      conn.query(sql, params)
        .then((result) => {
          console.log(result);
 res.send(result);
          conn.end();
        })
        .catch(err => {
          //handle error
          console.log(err);
          conn.end();
        })
       
    }).catch(err => {
      //not connected
    });


  
});


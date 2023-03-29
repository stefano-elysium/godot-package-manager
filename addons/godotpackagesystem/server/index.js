import sqlite3 from 'sqlite3'
import { open } from 'sqlite'

import express from 'express'


import { createRequire } from 'module';
const require = createRequire(import.meta.url);
const path = require('path');
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

var fs = require('fs');
var bodyParser = require('body-parser')

var app = express()
app.use(bodyParser.json({limit: '256mb'}))

var db = await open({
  filename: './database.db',
  driver: sqlite3.Database
});
db.exec(`CREATE TABLE IF NOT EXISTS PACKAGES (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  author TEXT NOT NULL,
  version INTEGER NOT NULL
);`)
//db.exec(`INSERT INTO PACKAGES (name,description,author,version) VALUES ('TestPackage', 'TestDesc','me',1)`)

//very very basic security
const key = "bc6e3a0af8a9481c2f57e80435becbf922f15fbeedc756dafce7c7ecb33296a2"
const port = 3000

let base64ToBuffer = (str)=>{
    str = atob(str); // creates a ASCII string
    var buffer = new ArrayBuffer(str.length),
        view = new Uint8Array(buffer);
    for(var i = 0; i < str.length; i++){
        view[i] = str.charCodeAt(i);
    }
    return Buffer.from( new Uint8Array(buffer) );
}

let check_headers = (headers)=>{
  if(headers.key != key) return true;
  if(!headers["user-agent"].includes("GodotEngine")) return true;
  return false;
}

app.get('/packages', (req, res) => {
  if(check_headers(req.headers)) return res.send("empty");

  db.all('SELECT name FROM PACKAGES').then(
    (data)=>{ res.send(data); }
  );
});

app.get('/package_info', (req, res) => {
  if(check_headers(req.headers)) return res.send("empty");
  console.log(req.query);
  let name = req.query.name;
  let version = req.query.version;
  if(name){
    db.all('SELECT * FROM PACKAGES WHERE name=\''+name+'\'').then(
      (data)=>{res.send(data); }
    );
  } else {
    res.send("empty")
  }
});

app.get('/download_package', (req, res) => {
  if(check_headers(req.headers)) return res.send("empty");

  let name = req.query.name;
  if(name){
    const options = {
        root: path.join(__dirname)
    };

    const fileName =  "Packages/"+name+".zip";
    res.sendFile(fileName, options, function (err) {
        if (err) { 
          console.error(err);
        } else { 
          console.log('Sent:', fileName);
        }
    });
  } else {
    res.send("empty")
  }
});



app.post('/upload_package', (req, res) => {
  console.log("Uploading...");
  if(check_headers(req.headers)) return res.send("empty");
  //console.log(req.body);
  var body = req.body;
  var data = base64ToBuffer(body.data);
  fs.writeFileSync(body.name, data, "binary");
  res.send("success")
  console.log("uploaded!");
});

app.listen(port, () => {
  console.log(`GPM Server listening on port ${port}`)
})

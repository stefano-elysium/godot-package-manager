import sqlite3 from 'sqlite3'
import { open } from 'sqlite'

import express from 'express'

var app = express()
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

    const fileName = name+".7z";
    res.sendFile(fileName, options, function (err) {
        if (err) { 
          next(err);
        } else { 
          console.log('Sent:', fileName);
        }
    });
  } else {
    res.send("empty")
  }
});

app.post('/upload_package', (req, res) => {
  if(check_headers(req.headers)) return res.send("empty");
  
  res.send('Unfinished')
});

app.listen(port, () => {
  console.log(`GPM Server listening on port ${port}`)
})



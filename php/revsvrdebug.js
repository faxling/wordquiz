const http = require('http');

const hostname = 'localhost';
const port = 3001;


const Reverso = require('reverso-api')
const reverso = new Reverso()

const server = http.createServer((req, res) => {
  console.log(req.url)
  let ret = req.url.split('?')
  let oc = ret[0].substring(9).split('-')
  console.log(oc)
  reverso.getContext(decodeURI(ret[1]), oc[0], oc[1], (err, response) => {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/json');
    res.setHeader('Access-Control-Allow-Origin','*')
    res.end(String(response));
    res.end(JSON.stringify(response) );
  })

});

server.listen(port, hostname, () => {
  console.log(`Reverso serv running at http://${hostname}:${port}/`);
});

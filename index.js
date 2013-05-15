var App = require("./lib/app"),
    argv = require("optimist").argv,
    cluster = require('cluster');



(function() {
  var i, numCPUs, port;
  port = argv.port || process.env.PORT;
  if(argv.cluster) {
    numCPUs = require('os').cpus().length;

    if (cluster.isMaster) {
      // Fork workers.
      for (i = 0; i < numCPUs; i++) {
        cluster.fork();
      }
      cluster.on("online", function(worker) {
        console.log("worker " + worker.process.pid + " online");
      });
      cluster.on("exit", function(worker, code, signal) {
        console.log("worker" + worker.process.pid + " died");
      });
      console.log("Starting cluster on " + port);
    } else {
      App.bootstrap(port);
    }
  } else {
    App.bootstrap(port);
  }
  
  
}());



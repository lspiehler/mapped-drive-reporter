const database = require('./database');
const util = require('util')

var appRouter = function (app) {
    app.get('/drive_mapping_report_API.vbs', function(req, res){
        const file = `${__dirname}/drive_mapping_report_API.vbs`;
        res.download(file); // Set disposition and send it.
    });
    /*app.get('/:any', function(req, res){
        console.log("routted here");
        res.status(200).send('wildcard route')
    });*/
    app.post("/mappeddrives", function(req, res) {
        var data = [];

        let ip = req.clientIp;
        let splitip = ip.split(",")
        let clientIp = splitip[0];
        if(splitip.length > 1) {
            clientIp = splitip[splitip.length - 1];
        }

        req.on('data', function(chunk) {
            //console.log('here');
            data.push(chunk);
        });

        req.on('error', (e) => {
            console.error(e);
            res.status(200).send('OK')
            //callback(true);
            //return;
        });

        req.on('end', function() {
            let body;
            try {
                body = JSON.parse(data.toString());
                //console.log('Record received ' + Date());
                //console.log(util.inspect(body, false, null, true /* enable colors */))
                //res.status(200).send('OK')
                //return;
            } catch(e) {
                console.log("JSON parse error. Please examine post data from " + clientIp + ":");
                console.log(data.toString());
                res.status(200).send('OK')
                return;
            }
        
            let sqldrivemappings = [];
            let userou = body.userdn.split(',OU=');
            userou.shift();
            //console.log(body.default);
            let computerou = body.computerdn.split(',');
            computerou.shift();
            //console.log(body.mappings)
            for(let i = 0; i <= body.mappings.length - 1; i++) {
                /*if(body.default && body.printers[i].toUpperCase() == body.default.toUpperCase()) {
                    defaultprinter = true;
                    console.log('Default printer match: ' + body.printers[i]);
                } else {
                    defaultprinter = false;
                }
                let splitprinter = body.printers[i].split('\\');
                if(splitprinter.length <= 2) {
                    console.error('Invalid printer sent by ' + body.COMPUTERNAME + ': ' + body.printers[i] )
                    continue;
                }*/
                sqldrivemappings.push([body.COMPUTERNAME, body.USERNAME, body.USERDOMAIN, body.site, 'OU=' + userou.join(',OU='), 'OU=' + computerou.join(',OU='), clientIp, body.mappings[i].Letter, body.mappings[i].VolumeName, body.mappings[i].Server, body.mappings[i].Server.split(".")[0], body.mappings[i].Path, body.mappings[i].FreeSpace, body.mappings[i].Size, body.mappings[i].Access, body.mappings[i].Availability, body.mappings[i].StatusInfo, body.mappings[i].Status]);
            }
            /*console.log(sqldrivemappings)
            res.status(200).send('OK')
            return;*/
            if(sqldrivemappings.length > 0) {
                let params = {}
                if(body.COMPUTERNAME.toUpperCase().indexOf("CTX") == 0) {
                    params.sql = "DELETE FROM `drivemappings` WHERE `computername` LIKE ? AND `username` = ?",
                    params.values = ['CTX%', body.USERNAME]
                } else if(body.COMPUTERNAME.toUpperCase().indexOf("VDI") == 0) {
                    params.sql = "DELETE FROM `drivemappings` WHERE `computername` LIKE ? AND `username` = ?",
                    params.values = ['VDI%', body.USERNAME]
                } else if(body.COMPUTERNAME.toUpperCase().indexOf("CVDI") == 0) {
                    params.sql = "DELETE FROM `drivemappings` WHERE `computername` LIKE ? AND `username` = ?",
                    params.values = ['CVDI%', body.USERNAME]
                } else {
                    params.sql = "DELETE FROM `drivemappings` WHERE `computername` = ? AND `username` = ?",
                    params.values = [body.COMPUTERNAME, body.USERNAME]
                }
                //console.log(params)
                database.query(params, function(err, sql) {
                    //console.log(err);
                    //console.log(sql);
                    if(err) {
                        console.log(err);
                        console.log(body);
                        res.status(500).json({result: "error", message: err});
                    } else {
                        let params = {
                            sql: "INSERT INTO `drivemappings` (`computername`, `username`,  `userdomain`, `site`, `userou`, `computerou`, `ip`, `letter`, `volumename`, `server`, `hostname`, `path`, `freespace`, `size`, `access`, `availability`, `statusinfo`, `status`) VALUES ?",
                            values: [sqldrivemappings]
                        }
                        database.query(params, function(err, sql) {
                            //console.log(err);
                            //console.log(sql);
                            if(err) {
                                console.log(err);
                                console.log(body);
                                res.status(500).json({result: "error", message: err});
                            } else {
                                res.status(200).json({result: "success", message: body});
                            }
                        });
                    }
                });
            } else {
                console.log("Empty list of drive mappings sent. Please examine post data from " + clientIp + ":");
                console.log(data.toString());
            }
        });
    });
}
  
  module.exports = appRouter;

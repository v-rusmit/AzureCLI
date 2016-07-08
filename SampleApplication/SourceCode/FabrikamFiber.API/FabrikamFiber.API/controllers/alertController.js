(function (alertController) {
    
    var alertRepository = require("../data/alertRepository");
    
    alertController.init = function (app) {
        
        app.get("/api/alert",
            function (req, res) {
            alertRepository.listAlerts(
                function (alerts, err) {
                    if (err) {
                        res.send(404, err);
                    } else {
                        res.json(alerts);
                    }
                }
            );
        }
        );
        
        app.get("/api/alert/:id",
            function (req, res) {
            
            var id = req.params.id;
            
            alertRepository.getAlert(id,
                    function (alert, err) {
                if (err) {
                    res.send(400, err);
                } else {
                    res.json(alert);
                }
            }
            );
        }
        );
        
        app.post("/api/alert",
            function (req, res) {
            
            var alert = {
                Created: new Date(req.body.Created),
                Description: req.body.Description
            }
            
            alertRepository.createAlert(alert,
                    function (alertId, err) {
                if (err) {
                    res.send(400, "Failed to create Alert.");
                } else {
                    res.json(201, alertId[0]);
                }
            });
        });
        
        app.put("/api/alert/:id",
            function (req, res) {
            
            var alert = {
                Id: req.params.id,
                Created: new Date(req.body.Created),
                Description: req.body.Description
            }
            
            alertRepository.updateAlert(alert,
                    function (err) {
                if (err) {
                    res.send(400, "Failed to update Alert.");
                } else {
                    res.json(200);
                }
            });
        });
        
        app.delete("/api/alert/:id",
            function (req, res) {
            
            var id = req.params.id;
            
            alertRepository.deleteAlert(id,
                    function (err) {
                if (err) {
                    res.send(400, err);
                } else {
                    res.json(200);
                }
            }
            );
        }
        );
    }
})(module.exports);
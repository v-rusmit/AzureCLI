(function (serviceLogEntryController) {
    
    var serviceLogEntryRepository = require("../data/serviceLogEntryRepository");
    var employeeRepository = require("../data/employeeRepository");
    var serviceTicketRepository = require("../data/serviceTicketRepository");
    
    serviceLogEntryController.init = function (app) {
        
        app.get("/api/serviceLogEntry",
            function (req, res) {
            serviceLogEntryRepository.listServiceLogEntrys(
                function (serviceLogEntrys, err) {
                    if (err) {
                        res.send(404, err);
                    } else {
                        serviceLogEntrys.forEach(function (serviceLogEntry) {
                            employeeRepository.getEmployee(serviceLogEntry.CreatedById, function(employee, err) {
                                serviceLogEntry.CreatedBy = employee[0];
                                serviceTicketRepository.getServiceTicket(serviceLogEntry.ServiceTicketId, (function (serviceTicket, err) {
                                    serviceLogEntry.ServiceTicket = serviceTicket[0];
                                    if(serviceLogEntrys[serviceLogEntrys.length-1] === serviceLogEntry) {
                                        res.json(serviceLogEntrys);
                                    }
                                }));
                            });
                        });
                    }
                }
            );
        }
        );
        
        app.get("/api/serviceLogEntry/:id",
            function (req, res) {
            
            var id = req.params.id;
            
            serviceLogEntryRepository.getServiceLogEntry(id,
                    function (serviceLogEntry, err) {
                if (err) {
                    res.send(400, err);
                } else {
                    employeeRepository.getEmployee(serviceLogEntry[0].CreatedById, function(employee, err) {
                        serviceLogEntry[0].CreatedBy = employee[0];
                        serviceTicketRepository.getServiceTicket(serviceLogEntry[0].ServiceTicketId, function(serviceTicket, err) {
                            serviceLogEntry[0].ServiceTicket = serviceTicket[0];
                            res.json(serviceLogEntry[0]);
                        });
                    });
                }
            }
            );
        }
        );
        
        app.post("/api/serviceLogEntry",
            function (req, res) {
            
            var serviceLogEntry = {
                CreatedAt: new Date(req.body.CreatedAt),
                Description: req.body.Description,
                CreatedById: req.body.CreatedById,
                ServiceTicketId: req.body.ServiceTicket.Id
            }
            
            serviceLogEntryRepository.createServiceLogEntry(serviceLogEntry,
                    function (serviceLogEntryId, err) {
                if (err) {
                    res.send(400, "Failed to create Service Log Entry.");
                } else {
                    res.json(201, serviceLogEntryId[0]);
                }
            });
        });
        
        app.put("/api/serviceLogEntry/:id",
            function (req, res) {
            
            var serviceLogEntry = {
                Id: req.params.id,
                CreatedAt: new Date(req.body.CreatedAt),
                Description: req.body.Description,
                CreatedById: req.body.CreatedById,
                ServiceTicketId: req.body.ServiceTicketId
            }
            
            serviceLogEntryRepository.updateServiceLogEntry(serviceLogEntry,
                    function (err) {
                if (err) {
                    res.send(400, "Failed to update ServiceLogEntry.");
                } else {
                    res.send(200);
                }
            });
        });
        
        app.delete("/api/serviceLogEntry/:id",
            function (req, res) {
            
            var id = req.params.id;
            
            serviceLogEntryRepository.deleteServiceLogEntry(id,
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
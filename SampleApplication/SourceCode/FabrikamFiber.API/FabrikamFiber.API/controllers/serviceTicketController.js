(function (serviceTicketController) {
    
    var serviceTicketRepository = require("../data/serviceTicketRepository");
    var employeeRepository = require("../data/employeeRepository");
    var customerRepository = require("../data/customerRepository");
    var serviceLogEntryRepository = require("../data/serviceLogEntryRepository");
    var statusRepository = require("../data/statusRepository");
    var addressRepository = require("../data/addressRepository");
    var scheduleItemRepository = require("../data/scheduleItemRepository");
    
    serviceTicketController.init = function (app) {
        
        app.get("/api/serviceTicket",
            function (req, res) {
            serviceTicketRepository.listServiceTickets(
                function (serviceTickets, err) {
                    if (err) {
                        res.send(404, err);
                    } else {
                        serviceTickets.forEach(function (serviceTicket) {
                            statusRepository.getStatus(serviceTicket.StatusValue, function(status, err) {
                                serviceTicket.Status = status[0].Description;
                                customerRepository.getCustomer(serviceTicket.CustomerId, function(customer, err) {
                                    serviceTicket.Customer = customer[0];
                                    addressRepository.getAddress(serviceTicket.Customer.AddressId, function (address, err) {
                                        serviceTicket.Customer.Address = address[0];
                                        employeeRepository.getEmployee(serviceTicket.CreatedById, function(createdBy, err) {
                                            serviceTicket.CreatedBy = createdBy[0];
                                            employeeRepository.getEmployee(serviceTicket.AssignedToId, function(assignedTo, err) {
                                                serviceTicket.AssignedTo = assignedTo[0];
                                                serviceLogEntryRepository.getServiceLogsByServiceTicketId(serviceTicket.Id, function(serviceLogEntries, err) {
                                                    serviceTicket.Log = serviceLogEntries;
                                                    if(serviceTickets[serviceTickets.length-1] === serviceTicket) {
                                                        res.json(serviceTickets);
                                                    }
                                                });
                                            });
                                        });
                                    });
                                });
                            });
                        });
                    }
                }
            );
        }
        );
        
        app.get("/api/serviceTicket/:id",
            function (req, res) {
            
            var id = req.params.id;
            
            serviceTicketRepository.getServiceTicket(id,
                    function (serviceTicket, err) {
                if (err) {
                    res.send(400, err);
                } else {
                    statusRepository.getStatus(serviceTicket[0].StatusValue, function(status, err) {
                        serviceTicket[0].Status = status[0].Description;
                        customerRepository.getCustomer(serviceTicket[0].CustomerId, function (customer, err) {
                            serviceTicket[0].Customer = customer[0];
                            addressRepository.getAddress(serviceTicket[0].Customer.AddressId, function (address, err) {
                                serviceTicket[0].Customer.Address = address[0];
                                employeeRepository.getEmployee(serviceTicket[0].CreatedById, function(createdBy, err) {
                                    serviceTicket[0].CreatedBy = createdBy[0];
                                    employeeRepository.getEmployee(serviceTicket[0].AssignedToId, function(assignedTo, err) {
                                        serviceTicket[0].AssignedTo = assignedTo[0];
                                        serviceLogEntryRepository.getServiceLogsByServiceTicketId(serviceTicket[0].Id, function(serviceLogEntries, err) {
                                            serviceTicket[0].Log = serviceLogEntries;
                                            res.json(serviceTicket[0]);
                                        });
                                    });
                                });
                            });
                        });
                    });
                }
            }
            );
        }
        );
        
        app.post("/api/serviceTicket",
            function (req, res) {
            
            var serviceTicket = {
                Title: req.body.Title,
                Description: req.body.Description,
                StatusValue: req.body.StatusValue,
                EscalationLevel: req.body.EscalationLevel,
                Opened: new Date(req.body.Opened),
                Closed: new Date(req.body.Closed),
                CustomerId: req.body.CustomerId,
                CreatedById: req.body.CreatedById,
                AssignedToId: req.body.AssignedToId
            }
            
            serviceTicketRepository.createServiceTicket(serviceTicket,
                    function (serviceTicketId, err) {
                if (err) {
                    res.send(400, "Failed to create Service Ticket.");
                } else {
                    res.set("Content-Type", "application/json");
                    res.send(201, serviceTicketId[0].ID);
                }
            });
        });
        
        app.put("/api/serviceTicket/:id",
            function (req, res) {
            
            var serviceTicket = {
                Id: req.params.id,
                Title: req.body.Title,
                Description: req.body.Description,
                StatusValue: req.body.StatusValue,
                EscalationLevel: req.body.EscalationLevel,
                Opened: new Date(req.body.Opened),
                Closed: new Date(req.body.Closed),
                CustomerId: req.body.CustomerId,
                CreatedById: req.body.CreatedById,
                AssignedToId: req.body.AssignedToId
            }
            
            serviceTicketRepository.updateServiceTicket(serviceTicket,
                    function (err) {
                if (err) {
                    res.send(400, "Failed to update ServiceTicket.");
                } else {
                    res.json(200);
                }
            });
        });
        
        app.delete("/api/serviceTicket/:id",
            function (req, res) {
            
            var id = req.params.id;
            
            serviceLogEntryRepository.deleteByServiceTicketId(id, function (err) {
                scheduleItemRepository.deleteByServiceTicketId(id, function (err) {
                    serviceTicketRepository.deleteServiceTicket(id,
                        function (err) {
                        if (err) {
                            res.send(400, err);
                        } else {
                            res.json(200);
                        }
                    });
                });
            });
        });
    }
})(module.exports);
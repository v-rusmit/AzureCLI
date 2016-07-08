(function (scheduleItemController) {
    
    var scheduleItemRepository = require("../data/scheduleItemRepository");
    var employeeRepository = require("../data/employeeRepository");
    var serviceTicketRepository = require("../data/serviceTicketRepository");
    
    scheduleItemController.init = function (app) {
        
        app.get("/api/scheduleItem",
            function (req, res) {
            scheduleItemRepository.listScheduleItems(
                function (scheduleItems, err) {
                    if (err) {
                        res.send(404, err);
                    } else {
                        scheduleItems.forEach(function (scheduleItem) {
                            employeeRepository.getEmployee(scheduleItem.EmployeeId, function(employee, err) {
                                scheduleItem.Employee = employee[0];
                                serviceTicketRepository.getServiceTicket(scheduleItem.ServiceTicketId, function(serviceTicket, err) {
                                    scheduleItem.ServiceTicket = serviceTicket[0];
                                    if(scheduleItems[scheduleItems.length-1] === scheduleItem) {
                                        res.json(scheduleItems);
                                    }
                                });
                            });
                        });
                    }
                }
            );
        }
        );
        
        app.get("/api/scheduleItem/:id",
            function (req, res) {
            
            var id = req.params.id;
            
            scheduleItemRepository.getScheduleItem(id,
                    function (scheduleItem, err) {
                if (err) {
                    res.send(400, err);
                } else {
                    employeeRepository.getEmployee(scheduleItem[0].EmployeeId, function(employee, err) {
                        scheduleItem[0].Employee = employee[0];
                        serviceTicketRepository.getServiceTicket(scheduleItem[0].ServiceTicketId, function (serviceTicket, err) {
                            scheduleItem[0].ServiceTicket = serviceTicket[0];
                            res.json(scheduleItem[0]);
                        });
                    });
                }
            }
            );
        }
        );
        
        app.post("/api/scheduleItem",
            function (req, res) {
            
            var scheduleItem = {
                EmployeeId: req.body.EmployeeId,
                ServiceTicketId: req.body.ServiceTicketId,
                Start: new Date(req.body.Start),
                WorkHours: req.body.WorkHours,
                AssignedOn: new Date(req.body.AssignedOn)
            }
            
            scheduleItemRepository.createScheduleItem(scheduleItem,
                    function (scheduleItemId, err) {
                if (err) {
                    res.json(400, "Failed to create Schedule Item.");
                } else {
                    res.json(201, scheduleItemId[0]);
                }
            });
        });
        
        app.put("/api/scheduleItem/:id",
            function (req, res) {
            
            var scheduleItem = {
                Id: req.params.id,
                EmployeeId: req.body.EmployeeId,
                ServiceTicketId: req.body.ServiceTicketId,
                Start: new Date(req.body.Start),
                WorkHours: req.body.WorkHours,
                AssignedOn: new Date(req.body.AssignedOn)
            }
            
            scheduleItemRepository.updateScheduleItem(scheduleItem,
                    function (err) {
                if (err) {
                    res.send(400, "Failed to update ScheduleItem.");
                } else {
                    res.json(200);
                }
            });
        });
        
        app.delete("/api/scheduleItem/:id",
            function (req, res) {
            
            var id = req.params.id;
            
            scheduleItemRepository.deleteScheduleItem(id,
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
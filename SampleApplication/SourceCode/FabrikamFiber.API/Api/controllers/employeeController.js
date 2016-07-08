(function (employeeController) {
    
    var employeeRepository = require("../data/employeeRepository");
    var addressRepository = require("../data/addressRepository");
    var phoneRepository = require("../data/phoneRepository");
    var scheduleItemRepository = require("../data/scheduleItemRepository");
    var serviceLogEntryRepository = require("../data/serviceLogEntryRepository");
    var serviceTicketRepository = require("../data/serviceTicketRepository");
    
    employeeController.init = function (app) {
        
        app.get("/api/employee",
            function (req, res) {
            employeeRepository.listEmployees(function (employees, err) {
                    if (err) {
                        res.send(404, err);
                    } else {
                        employees.forEach(function (employee) {
                            addressRepository.getAddress(employee.AddressId, function(address, err) {
                                employee.Address = address[0];
                                phoneRepository.getPhonesByEmployeeId(employee.Id, function(phones, err) {
                                    employee.Phone = phones;
                                    if(employees[employees.length-1] === employee) {
                                        res.json(employees);
                                    }
                                });
                            });
                        });
                    }
                }
            );
        });
        
        app.get("/api/employee/:id",
            function (req, res) {
            
            var id = req.params.id;
            
            employeeRepository.getEmployee(id, function (employee, err) {
                if (err) {
                    res.send(400, err);
                } else {
                    addressRepository.getAddress(employee[0].AddressId, function(address, err) {
                        employee[0].Address = address[0];
                        phoneRepository.getPhonesByEmployeeId(employee[0].Id, function (phones, err) {
                            employee[0].Phone = phones;
                            res.json(employee[0]);
                        });
                    });
                }
            });
        });
        
        app.post("/api/employee",
            function (req, res) {
            
            var employee = {
                FirstName: req.body.FirstName,
                LastName: req.body.LastName,
                Address: req.body.Address,
                Phone: req.body.Phone,
                Identity: req.body.Identity,
                ServiceAreas: req.body.ServiceAreas
            }
            addressRepository.createAddress(employee.Address, function(addressId, err) {
                employee.AddressId = addressId[0].Id;
                if(!employee.Identity) {
                    employee.Identity = "";
                }
                employeeRepository.createEmployee(employee,
                    function (employeeId, err) {
                    if (err) {
                        res.send(400, "Failed to create Employee.");
                    } else {
                        if (employee.Phone) {
                            employee.Phone.forEach(function (phone) {
                                phone.EmployeeId = employeeId;
                                phone.CustomerId = null;
                                phoneRepository.createPhone(phone);
                            });
                        }
                        res.json(201, employeeId[0]);
                    }
                });
            });
        });
        
        app.put("/api/employee/:id",
            function (req, res) {
            
            var employee = {
                Id: req.params.id,
                FirstName: req.body.FirstName,
                LastName: req.body.LastName,
                Identity: req.body.Identity,
                ServiceAreas: req.body.ServiceAreas,
                Address: req.body.Address
            }
            if (!employee.Identity) {
                employee.Identity = "";
            }
            addressRepository.updateAddress(employee.Address, function (address, err) {
                employeeRepository.updateEmployee(employee,
                function (employeeId, err) {
                    if (err) {
                        res.send(400, "Failed to update Employee.");
                    } else {
                        res.json(200);
                    }
                });
            });
        });
        
        app.delete("/api/employee/:id",
            function (req, res) {
            
            var id = req.params.id;
            
            phoneRepository.deleteEmployeePhone(id, function (err) {
                scheduleItemRepository.deleteByEmployeeId(id, function (err) {
                    serviceTicketRepository.getServiceTicketsByEmployeeId(id, function (serviceTickets, err) {
                        serviceTickets.forEach(function (ticket) {
                            serviceLogEntryRepository.deleteByServiceTicketId(ticket.Id, function (err) {
                                scheduleItemRepository.deleteByServiceTicketId(ticket.Id, function (err) {
                                    if (serviceTickets[serviceTickets.length - 1] === ticket) {
                                        serviceLogEntryRepository.deleteByEmployeeId(id, function (err) {
                                            serviceTicketRepository.deleteByEmployeeId(id, function (err) {
                                                employeeRepository.deleteEmployee(id,
                                                function (err) {
                                                    if (err) {
                                                        res.send(400, err);
                                                    }
                                                    else {
                                                        res.json(200);
                                                    }
                                                });
                                            });
                                        });
                                    }
                                });
                            });
                        });
                        if (serviceTickets.length == 0) {
                            serviceLogEntryRepository.deleteByEmployeeId(id, function (err) {
                                employeeRepository.deleteEmployee(id,
                                        function (err) {
                                    if (err) {
                                        res.send(400, err);
                                    }
                                    else {
                                        res.json(200);
                                    }
                                });
                            });
                        }
                    });
                });
            });
        });
    }
})(module.exports);
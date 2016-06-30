(function (customerController) {
    
    var customerRepository = require("../data/customerRepository");
    var addressRepository = require("../data/addressRepository");
    var phoneRepository = require("../data/phoneRepository");
    var serviceTicketRepository = require("../data/serviceTicketRepository");
    var scheduleItemRepository = require("../data/scheduleItemRepository");
    var serviceLogEntryRepository = require("../data/serviceLogEntryRepository");
    

    customerController.init = function (app) {
        
        app.get("/api/customer",
            function (req, res) {

                customerRepository.listCustomers(
                    function (customers, err) {
                        if (err) {
                            res.send(404, err);
                    } else {
                        customers.forEach(function (customer) {
                            addressRepository.getAddress(customer.AddressId, function(address, err) {
                                customer.Address = address[0];
                                phoneRepository.getPhonesByCustomerId(customer.Id, function (phones, err) {
                                    customer.Phone = phones;
                                    serviceTicketRepository.getServiceTicketsByCustomerId(customer.Id, function (requestedTickets, err) {
                                        customer.RequestedTickets = requestedTickets;
                                        if(customers[customers.length-1] === customer) {
                                            res.json(customers);
                                        }
                                    });
                                });
                            });
                        });
                        }
                    }
                );
            }
        );

        app.get("/api/customer/:id",
            function (req, res) {
            
                var id = req.params.id;

                customerRepository.getCustomer(id, function (customer, err) {
                        if (err) {
                            res.json(400, err);
                        } else {
                            addressRepository.getAddress(customer[0].AddressId, function (address, err) {
                                customer[0].Address = address[0];
                                if(err) {
                                    
                                } else {
                                    phoneRepository.getPhonesByCustomerId(customer[0].Id, function (phones, err) {
                                        customer[0].Phone = phones;
                                        if(err) {
                                            
                                        }else{
                                            serviceTicketRepository.getServiceTicketsByCustomerId(customer[0].Id, function(requestedTickets, err) {
                                                customer[0].RequestedTickets = requestedTickets;
                                                if (err) {
                                                    
                                                }else {
                                                    res.json(customer[0]);
                                                }
                                            });
                                        }
                                    });
                                }
                            });
                        }
                    }
                );
            }
        );
        
        app.post("/api/customer",
            function (req, res) {

                var customer = {
                    FirstName: req.body.FirstName,
                    LastName: req.body.LastName,
                    Address: req.body.Address,
                    Phone: req.body.Phone
                }
            addressRepository.createAddress(customer.Address, function(addressId, err) {
                customer.AddressId = addressId[0].Id;
                customerRepository.createCustomer(customer,
                function (customerId, err) {
                    if (err) {
                        res.send(400, "Failed to create Customer.");
                    } else {
                        if (customer.Phone) {
                            customer.Phone.forEach(function (phone) {
                                phone.CustomerId = customerId;
                                phone.EmployeeId = null;
                                phoneRepository.createPhone(phone);
                            });
                        }
                        res.json(201, customerId[0]);
                    }
                });
            });
        });
        
        app.put("/api/customer/:id",
            function (req, res) {
            
            var customer = {
                Id: req.params.id,
                FirstName: req.body.FirstName,
                LastName: req.body.LastName,
                Address: req.body.Address
            }
            
            addressRepository.updateAddress(customer.Address, function (address, err) {
                customerRepository.updateCustomer(customer,
                function (customerId, err) {
                    if (err) {
                        res.send(400, "Failed to update Customer.");
                    } else {
                        res.json(200);
                    }
                });
            });
        });

        app.delete("/api/customer/:id",
            function (req, res) {
            
                var id = req.params.id;
            
            phoneRepository.deleteCustomerPhone(id, function (err) {
                serviceTicketRepository.getServiceTicketsByCustomerId(id, function (serviceTickets, err) {
                    serviceTickets.forEach(function (ticket) {
                        serviceLogEntryRepository.deleteByServiceTicketId(ticket.Id, function (err) { 
                            scheduleItemRepository.deleteByServiceTicketId(ticket.Id, function (err) {
                                if (serviceTickets[serviceTickets.length - 1] === ticket) {
                                    serviceTicketRepository.deleteByCustomerId(id, function (err) {
                                        customerRepository.deleteCustomer(id,
                                        function (err) {
                                            if (err) {
                                                res.send(400, err);
                                            } else {
                                                res.json(200);
                                            }
                                        });
                                    });
                                }
                            });
                        });
                    });
                    if (serviceTickets.length == 0) {
                        customerRepository.deleteCustomer(id,
                                        function (err) {
                            if (err) {
                                res.send(400, err);
                            } else {
                                res.json(200);
                            }
                        });
                    }
                });
            });
            }
        );
    }
})(module.exports);
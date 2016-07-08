(function (serviceTicketRepository) {
    
    var mssql = require("mssql");
    var dbConfig = require('./dbConfig');
    
    serviceTicketRepository.listServiceTickets = function (callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request.query("SELECT * FROM ServiceTicket", function (err, serviceTickets) {
                if (err) {
                    return err;
                }
                else {
                    callback(serviceTickets);
                    return serviceTickets;
                }
            });
            return null;
        });
        return null;
    }
    
    serviceTicketRepository.getServiceTicket = function (id, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request.query("SELECT * FROM ServiceTicket WHERE Id = " + id, function (err, serviceTicket) {
                if (err) {
                    return err;
                }
                else {
                    callback(serviceTicket);
                    return serviceTicket;
                }
            });
            return null;
        });
        return null;
    }
    
    serviceTicketRepository.getServiceTicketsByCustomerId = function (customerId, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request.input('customerId', mssql.Int, customerId).query("SELECT * FROM ServiceTicket WHERE CustomerId = @customerId", function (err, serviceTickets) {
                if (err) {
                    return err;
                }
                else {
                    callback(serviceTickets);
                    return serviceTickets;
                }
            });
            return null;
        });
        return null;
    }
    
    serviceTicketRepository.getServiceTicketsByEmployeeId = function (employeeId, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('employeeId', mssql.Int, employeeId)
            .query("SELECT * FROM ServiceTicket WHERE AssignedToId = @employeeId OR CreatedById = @employeeId", function (err, serviceTickets) {
                if (err) {
                    return err;
                }
                else {
                    callback(serviceTickets);
                    return serviceTickets;
                }
            });
            return null;
        });
        return null;
    }
    
    serviceTicketRepository.createServiceTicket = function (serviceTicket, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('title', mssql.VarChar(50), serviceTicket.Title)
            .input('description', mssql.VarChar(300), serviceTicket.Description)
            .input('statusValue', mssql.Int, serviceTicket.StatusValue)
            .input('escalationLevel', mssql.Int, serviceTicket.EscalationLevel)
            .input('opened', mssql.DateTime, serviceTicket.Opened)
            .input('closed', mssql.DateTime, serviceTicket.Closed)
            .input('customerId', mssql.Int, serviceTicket.CustomerId)
            .input('createdById', mssql.Int, serviceTicket.CreatedById)
            .input('assignedToId', mssql.Int, serviceTicket.AssignedToId)
            .query("INSERT INTO ServiceTicket OUTPUT Inserted.ID VALUES(@title, @description, @statusValue, @escalationLevel, @opened, @closed, @customerId, @createdById, @assignedToId)", function (err, serviceTicketId) {
                if (err) {
                    return err;
                }
                else {
                    callback(serviceTicketId);
                    return serviceTicketId;
                }
            });
            return null;
        });
        return null;
    }
    
    serviceTicketRepository.updateServiceTicket = function (serviceTicket, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('serviceTicketId', mssql.Int, serviceTicket.Id)
            .input('title', mssql.VarChar(50), serviceTicket.Title)
            .input('description', mssql.VarChar(300), serviceTicket.Description)
            .input('statusValue', mssql.Int, serviceTicket.StatusValue)
            .input('escalationLevel', mssql.Int, serviceTicket.EscalationLevel)
            .input('opened', mssql.DateTime, serviceTicket.Opened)
            .input('closed', mssql.DateTime, serviceTicket.Closed)
            .input('customerId', mssql.Int, serviceTicket.CustomerId)
            .input('createdById', mssql.Int, serviceTicket.CreatedById)
            .input('assignedToId', mssql.Int, serviceTicket.AssignedToId)
            .query("UPDATE ServiceTicket SET Title = @title, Description = @description, StatusValue = @statusValue, EscalationLevel = @escalationLevel, Opened = @opened, Closed = @closed, CustomerId = @customerId, CreatedById = @createdById, AssignedToId = @assignedToId WHERE Id = @serviceTicketId", function (err, serviceTicket) {
                if (err) {
                    return err;
                }
                else {
                    callback(serviceTicket);
                    return serviceTicket;
                }
            });
            return null;
        });
        return null;
    }
    
    serviceTicketRepository.deleteServiceTicket = function (id, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('serviceTicketId', mssql.Int, id)
            .query("DELETE FROM ServiceTicket WHERE Id = @serviceTicketId", function (err, serviceTicket) {
                if (err) {
                    return err;
                }
                else {
                    callback();
                    return serviceTicket;
                }
            });
            return null;
        });
        return null;
    }

    serviceTicketRepository.deleteByEmployeeId = function (employeeId, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('employeeId', mssql.Int, employeeId)
            .query("DELETE FROM ServiceTicket WHERE CreatedById = @employeeId OR AssignedToId = @employeeId", function (err, serviceTicket) {
                if (err) {
                    callback(err);
                    return err;
                }
                else {
                    callback();
                    return serviceTicket;
                }
            });
            return null;
        });
        return null;
    }

    serviceTicketRepository.deleteByCustomerId = function (customerId, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('customerId', mssql.Int, customerId)
            .query("DELETE FROM ServiceTicket WHERE CustomerId = @customerId", function (err, serviceTicket) {
                if (err) {
                    callback(err);
                    return err;
                }
                else {
                    callback();
                    return serviceTicket;
                }
            });
            return null;
        });
        return null;
    }

})(module.exports);
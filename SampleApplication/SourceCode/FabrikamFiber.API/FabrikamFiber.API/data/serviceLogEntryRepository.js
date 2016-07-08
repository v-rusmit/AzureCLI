(function (serviceLogEntryRepository) {
    
    var mssql = require("mssql");
    var dbConfig = require('./dbConfig');
    
    serviceLogEntryRepository.listServiceLogEntrys = function (callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request.query("SELECT * FROM ServiceLogEntry", function (err, serviceLogEntrys) {
                if (err) {
                    return err;
                }
                else {
                    callback(serviceLogEntrys);
                    return serviceLogEntrys;
                }
            });
            return null;
        });
        return null;
    }
    
    serviceLogEntryRepository.getServiceLogEntry = function (id, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('id', mssql.Int, id)
            .query("SELECT * FROM ServiceLogEntry WHERE Id = @id", function (err, serviceLogEntry) {
                if (err) {
                    return err;
                }
                else {
                    callback(serviceLogEntry);
                    return serviceLogEntry;
                }
            });
            return null;
        });
        return null;
    }
    
    serviceLogEntryRepository.getServiceLogsByServiceTicketId = function (serviceTicketId, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('serviceTicketId', mssql.Int, serviceTicketId)
            .query("SELECT * FROM ServiceLogEntry WHERE ServiceTicketId = @serviceTicketId", function (err, serviceLogEntries) {
                if (err) {
                    return err;
                }
                else {
                    callback(serviceLogEntries);
                    return serviceLogEntries;
                }
            });
            return null;
        });
        return null;
    }
    
    serviceLogEntryRepository.createServiceLogEntry = function (serviceLogEntry, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('createdAt', mssql.DateTime, serviceLogEntry.CreatedAt)
            .input('description', mssql.NVarChar(300), serviceLogEntry.Description)
            .input('createdById', mssql.Int, serviceLogEntry.CreatedById)
            .input('serviceTicketId', mssql.Int, serviceLogEntry.ServiceTicketId)
            .query("INSERT INTO ServiceLogEntry OUTPUT Inserted.ID VALUES(@createdAt, @description, @createdById, @serviceTicketId)", function (err, serviceLogEntryId) {
                if (err) {
                    return err;
                }
                else {
                    callback(serviceLogEntryId);
                    return serviceLogEntryId;
                }
            });
            return null;
        });
        return null;
    }
    
    serviceLogEntryRepository.updateServiceLogEntry = function (serviceLogEntry, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('serviceLogEntryId', mssql.Int, serviceLogEntry.Id)
            .input('createdAt', mssql.DateTime, serviceLogEntry.CreatedAt)
            .input('description', mssql.NVarChar(300), serviceLogEntry.Description)
            .input('createdById', mssql.Int, serviceLogEntry.CreatedById)
            .input('serviceTicketId', mssql.Int, serviceLogEntry.ServiceTicketId)
            .query("UPDATE ServiceLogEntry SET CreatedAt = @createdAt, Description = @description, CreatedById = @createdById, ServiceTicketId = @serviceTicketId WHERE Id = @serviceLogEntryId", function (err, serviceLogEntry) {
                if (err) {
                    return err;
                }
                else {
                    callback();
                    return serviceLogEntry;
                }
            });
            return null;
        });
        return null;
    }

    serviceLogEntryRepository.deleteServiceLogEntry = function (id, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('serviceLogEntryId', mssql.Int, id)
            .query("DELETE FROM ServiceLogEntry WHERE Id = @serviceLogEntryId", function (err, serviceLogEntry) {
                if (err) {
                    return err;
                }
                else {
                    callback();
                    return serviceLogEntry;
                }
            });
            return null;
        });
        return null;
    }

    serviceLogEntryRepository.deleteByEmployeeId = function (employeeId, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('employeeId', mssql.Int, employeeId)
            .query("DELETE FROM ServiceLogEntry WHERE CreatedById = @employeeId", function (err, serviceLogEntry) {
                if (err) {
                    callback(err);
                    return err;
                }
                else {
                    callback();
                    return serviceLogEntry;
                }
            });
            return null;
        });
        return null;
    }

    serviceLogEntryRepository.deleteByServiceTicketId = function (serviceTicketId, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('serviceTicketId', mssql.Int, serviceTicketId)
            .query("DELETE FROM ServiceLogEntry WHERE ServiceTicketId = @serviceTicketId", function (err, serviceLogEntry) {
                if (err) {
                    callback(err);
                    return err;
                }
                else {
                    callback();
                    return serviceLogEntry;
                }
            });
            return null;
        });
        return null;
    }

})(module.exports);
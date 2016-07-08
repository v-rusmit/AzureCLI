(function (scheduleItemRepository) {
    
    var mssql = require("mssql");
    var dbConfig = require('./dbConfig');
    
    scheduleItemRepository.listScheduleItems = function (callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request.query("SELECT * FROM ScheduleItem", function (err, scheduleItems) {
                if (err) {
                    return err;
                }
                else {
                    callback(scheduleItems);
                    return scheduleItems;
                }
            });
            return null;
        });
        return null;
    }
    
    scheduleItemRepository.getScheduleItem = function (id, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('id', mssql.Int, id)
            .query("SELECT * FROM ScheduleItem WHERE Id = @id", function (err, scheduleItem) {
                if (err) {
                    return err;
                }
                else {
                    callback(scheduleItem);
                    return scheduleItem;
                }
            });
            return null;
        });
        return null;
    }
    
    scheduleItemRepository.createScheduleItem = function (scheduleItem, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('employeeId', mssql.Int, scheduleItem.EmployeeId)
            .input('serviceTicketId', mssql.Int, scheduleItem.ServiceTicketId)
            .input('start', mssql.DateTime, scheduleItem.Start)
            .input('workHours', mssql.Int, scheduleItem.WorkHours)
            .input('assignedOn', mssql.DateTime, scheduleItem.AssignedOn)
            .query("INSERT INTO ScheduleItem  OUTPUT Inserted.ID VALUES(@employeeId, @serviceTicketId, @start, @workHours, @assignedOn)", function (err, scheduleItemId) {
                if (err) {
                    return err;
                }
                else {
                    callback(scheduleItemId);
                    return scheduleItemId;
                }
            });
            return null;
        });
        return null;
    }
    
    scheduleItemRepository.updateScheduleItem = function (scheduleItem, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('id', mssql.Int, scheduleItem.Id)
            .input('employeeId', mssql.Int, scheduleItem.EmployeeId)
            .input('serviceTicketId', mssql.Int, scheduleItem.ServiceTicketId)
            .input('start', mssql.DateTime, scheduleItem.Start)
            .input('workHours', mssql.Int, scheduleItem.WorkHours)
            .input('assignedOn', mssql.DateTime, scheduleItem.AssignedOn)
            .query("UPDATE ScheduleItem SET EmployeeId = @employeeId, ServiceTicketId = @serviceTicketId, start = @start, WorkHours = @workHours, AssignedOn = @assignedOn WHERE Id = @id", function (err, scheduleItem) {
                if (err) {
                    return err;
                }
                else {
                    callback();
                    return scheduleItem;
                }
            });
            return null;
        });
        return null;
    }
    
    scheduleItemRepository.deleteScheduleItem = function (id, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('id', mssql.Int, id)
            .query("DELETE FROM ScheduleItem WHERE Id = @id", function (err, scheduleItem) {
                if (err) {
                    callback(err);
                    return err;
                }
                else {
                    callback();
                    return scheduleItem;
                }
            });
            return null;
        });
        return null;
    }

    scheduleItemRepository.deleteByEmployeeId = function (employeeId, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('employeeId', mssql.Int, employeeId)
            .query("DELETE FROM ScheduleItem WHERE EmployeeId = @employeeId", function (err, scheduleItem) {
                if (err) {
                    callback(err);
                    return err;
                }
                else {
                    callback();
                    return scheduleItem;
                }
            });
            return null;
        });
        return null;
    }

    scheduleItemRepository.deleteByServiceTicketId = function (serviceTicketId, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('serviceTicketId', mssql.Int, serviceTicketId)
            .query("DELETE FROM ScheduleItem WHERE ServiceTicketId = @serviceTicketId", function (err, scheduleItem) {
                if (err) {
                    callback(err);
                    return err;
                }
                else {
                    callback();
                    return scheduleItem;
                }
            });
            return null;
        });
        return null;
    }

})(module.exports);
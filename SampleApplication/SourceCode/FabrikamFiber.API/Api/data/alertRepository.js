(function (alertRepository) {
    
    var mssql = require("mssql");
    var dbConfig = require('./dbConfig');
    
    alertRepository.listAlerts = function (callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request.query("SELECT * FROM Alert", function (err, alerts) {
                if (err) {
                    return err;
                }
                else {
                    callback(alerts);
                    return alerts;
                }
            });
            return null;
        });
        return null;
    }
    
    alertRepository.getAlert = function (id, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('id', mssql.Int, id)
            .query("SELECT * FROM Alert WHERE Id = @id", function (err, alert) {
                if (err) {
                    return err;
                }
                else {
                    callback(alert);
                    return alert;
                }
            });
            return null;
        });
        return null;
    }
    
    alertRepository.createAlert = function (alert, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('created', mssql.DateTime, alert.Created)
            .input('description', mssql.NVarChar(100), alert.Description)
            .query("INSERT INTO Alert OUTPUT Inserted.ID VALUES(@created, @description)", function (err, alertId) {
                if (err) {
                    return err;
                }
                else {
                    callback(alertId);
                    return alert;
                }
            });
            return null;
        });
        return null;
    }
    
    alertRepository.updateAlert = function (alert, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('alertId', mssql.Int, alert.Id)
            .input('created', mssql.DateTime, alert.Created)
            .input('description', mssql.NVarChar(100), alert.Description)
            .query("UPDATE Alert SET Created = @created, Description = @description WHERE Id = @alertId", function (err, alert) {
                if (err) {
                    return err;
                }
                else {
                    callback();
                    return alert;
                }
            });
            return null;
        });
        return null;
    }

    alertRepository.deleteAlert = function (id, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('alertId', mssql.Int, id)
            .query("DELETE FROM Alert WHERE Id = @alertId", function (err, alert) {
                if (err) {
                    return err;
                }
                else {
                    callback();
                    return alert;
                }
            });
            return null;
        });
        return null;
    }

})(module.exports);
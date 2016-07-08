(function (statusRepository) {
    
    var mssql = require("mssql");
    var dbConfig = require('./dbConfig');
    
    statusRepository.listStatuses = function (callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request.query("SELECT * FROM Status", function (err, statuses) {
                if (err) {
                    return err;
                }
                else {
                    callback(statuses);
                    return statuses;
                }
            });
            return null;
        });
        return null;
    }
    
    statusRepository.getStatus = function (id, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('id', mssql.Int, id)
            .query("SELECT * FROM Status WHERE Id = @id", function (err, status) {
                if (err) {
                    return err;
                }
                else {
                    callback(status);
                    return status;
                }
            });
            return null;
        });
        return null;
    }
    
    statusRepository.createStatus = function (status, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('description', mssql.NVarChar(20), status.Description)
            .query("INSERT INTO Status OUTPUT Inserted.ID VALUES(@description)", function (err, statusId) {
                if (err) {
                    return err;
                }
                else {
                    callback(statusId);
                    return statusId;
                }
            });
            return null;
        });
        return null;
    }
    
    statusRepository.deleteStatus = function (id) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request.query("DELETE FROM Status WHERE Id = " + id, function (err, results) {
                if (err) {
                    return err;
                }
                else {
                    return results;
                }
            });
            return null;
        });
        return null;
    }

})(module.exports);
(function (phoneRepository) {
    
    var mssql = require("mssql");
    var dbConfig = require('./dbConfig');
    
    phoneRepository.listPhones = function (callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request.query("SELECT * FROM Phone", function (err, phones) {
                if (err) {
                    return err;
                }
                else {
                    callback(phones);
                    return phones;
                }
            });
            return null;
        });
        return null;
    }
    
    phoneRepository.getPhone = function (id, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request.query("SELECT * FROM Phone WHERE Id = " + id, function (err, phone) {
                if (err) {
                    return err;
                }
                else {
                    callback(phone);
                    return phone;
                }
            });
            return null;
        });
        return null;
    }
    
    phoneRepository.getPhonesByCustomerId = function (customerId, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('customerId', mssql.Int, customerId)
            .query("SELECT * FROM Phone WHERE CustomerId = @customerId", function (err, phones) {
                if (err) {
                    return err;
                }
                else {
                    callback(phones);
                    return phones;
                }
            });
            return null;
        });
        return null;
    }
    

    
    phoneRepository.getPhonesByEmployeeId = function (employeeId, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('employeeId', mssql.Int, employeeId)
            .query("SELECT * FROM Phone WHERE EmployeeId = @employeeId", function (err, phones) {
                if (err) {
                    return err;
                }
                else {
                    callback(phones);
                    return phones;
                }
            });
            return null;
        });
        return null;
    }
    
    phoneRepository.createPhone = function (phone, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('label', mssql.VarChar(50), phone.Label)
            .input('number', mssql.VarChar(20), phone.Number)
            .input('customerId', mssql.Int, phone.CustomerId)
            .input('employeeId', mssql.Int, phone.EmployeeId)
            .query("INSERT INTO Phone Values(@label, @number, @customerId, @employeeId)", function (err, phone) {
                if (err) {
                    return err;
                }
                else {
                    return phone;
                }
            });
            return null;
        });
        return null;
    }
    

    
    phoneRepository.deletePhone = function (id, callback) {
            
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
            
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request.query("DELETE FROM Phone WHERE Id = " + id, function (err, phone) {
                if (err) {
                    return err;
                }
                else {
                    callback(phone);
                    return phone;
                }
            });
            return null;
        });
        return null;
    }

    phoneRepository.deleteEmployeePhone = function (employeeId, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('employeeId', mssql.Int, employeeId)
            .query("DELETE FROM Phone WHERE EmployeeId = @employeeId", function (err, phone) {
                if (err) {
                    callback(err);
                    return err;
                }
                else {
                    callback();
                    return phone;
                }
            });
            return null;
        });
        return null;
    }

    phoneRepository.deleteCustomerPhone = function (customerId, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('customerId', mssql.Int, customerId)
            .query("DELETE FROM Phone WHERE CustomerId = @customerId", function (err, phone) {
                if (err) {
                    callback(err);
                    return err;
                }
                else {
                    callback();
                    return phone;
                }
            });
            return null;
        });
        return null;
    }

})(module.exports);
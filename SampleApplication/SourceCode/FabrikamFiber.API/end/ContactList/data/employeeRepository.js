(function (employeeRepository) {
    
    var mssql = require("mssql");
    var dbConfig = require('./dbConfig');
    
    employeeRepository.listEmployees = function (callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request.query("SELECT * FROM Employee", function (err, employees) {
                if (err) {
                    return err;
                }
                else {
                    callback(employees);
                    return employees;
                }
            });
            return null;
        });
        return null;
    }
    
    employeeRepository.getEmployee = function (id, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('employeeId', mssql.Int, id)
            .query("SELECT * FROM Employee WHERE Id = @employeeId", function (err, employee) {
                if (err) {
                    return err;
                }
                else {
                    callback(employee);
                    return employee;
                }
            });
            return null;
        });
        return null;
    }
    
    employeeRepository.createEmployee = function (employee, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('firstName', mssql.NVarChar(20), employee.FirstName)
            .input('lastName', mssql.NVarChar(20), employee.LastName)
            .input('addressId', mssql.Int, employee.AddressId)
            .input('identity', mssql.NVarChar(50), employee.Identity)
            .input('serviceAreas', mssql.NVarChar(150), employee.ServiceAreas)
            .query("INSERT INTO Employee OUTPUT Inserted.ID VALUES(@firstName, @lastName, @addressId, @identity, @serviceAreas)", function (err, employeeId) {
                if (err) {
                    callback(null,err);
                    return err;
                }
                else {
                    callback(employeeId);
                    return employeeId;
                }
            });
            return null;
        });
        return null;
    }
    
    employeeRepository.updateEmployee = function (employee, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('employeeId', mssql.Int, employee.Id)
            .input('firstName', mssql.NVarChar(20), employee.FirstName)
            .input('lastName', mssql.NVarChar(20), employee.LastName)
            .input('identity', mssql.NVarChar(50), employee.Identity)
            .input('serviceAreas', mssql.NVarChar(150), employee.ServiceAreas)
            .query("UPDATE Employee SET FirstName = @firstName, LastName = @lastName, [Identity] = @identity, ServiceAreas = @serviceAreas WHERE Id = @employeeId", function (err, employee) {
                if (err) {
                    return err;
                }
                else {
                    callback();
                    return employee;
                }
            });
            return null;
        });
        return null;
    }
    
    employeeRepository.deleteEmployee = function (id, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('employeeId', mssql.Int, id)
            .query("DELETE FROM Employee WHERE Id = @employeeId", function (err, employee) {
                if (err) {
                    return err;
                }
                else {
                    callback();
                    return employee;
                }
            });
            return null;
        });
        return null;
    }

})(module.exports);
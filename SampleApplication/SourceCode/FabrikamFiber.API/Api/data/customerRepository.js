(function (customerRepository) {
    
    var mssql = require("mssql");
    var dbConfig = require('./dbConfig');

    customerRepository.listCustomers = function (callback){
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request.query("SELECT * FROM Customer", function (err, customers) {
                if (err) {
                    return err;
                }
                else {
                    callback(customers);
                    return customers;
                }
            });
            return null;
        });
        return null;
    }

    customerRepository.getCustomer = function (id, callback){
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);

        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('id', mssql.Int, id)
            .query("SELECT * FROM Customer where Id = @id", function (err, customer) {
                if (err) {
                    return err;
                }
                else {
                    callback(customer);
                    return customer;
                }
            });
            return null;
        });
        return null;
    }
    
    customerRepository.createCustomer = function (customer, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('firstName', mssql.VarChar(20), customer.FirstName)
            .input('lastName', mssql.VarChar(20), customer.LastName)
            .input('addressId', mssql.Int, customer.AddressId)
            .query("INSERT INTO Customer OUTPUT Inserted.ID Values(@firstName, @lastName, @addressId)", function (err, customerId) {
                if (err) {
                    return err;
                }
                else {
                    callback(customerId);
                    return customerId;
                }
            });
            return null;
        });
        return null;
    }
    
    customerRepository.updateCustomer = function (customer, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('customerId', mssql.Int, customer.Id)
            .input('firstName', mssql.VarChar(20), customer.FirstName)
            .input('lastName', mssql.VarChar(20), customer.LastName)
            .query("UPDATE Customer SET FirstName = @firstName, LastName = @lastName WHERE Id = @customerId", function (err, customer) {
                if (err) {
                    return err;
                }
                else {
                    callback();
                    return customer;
                }
            });
            return null;
        });
        return null;
    }
    
    customerRepository.deleteCustomer = function (id, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('customerId', mssql.Int, id)
            .query("DELETE FROM Customer WHERE Id = @customerId", function (err, customer) {
                if (err) {
                    return err;
                }
                else {
                    callback();
                    return customer;
                }
            });
            return null;
        });
        return null;
    }

})(module.exports);
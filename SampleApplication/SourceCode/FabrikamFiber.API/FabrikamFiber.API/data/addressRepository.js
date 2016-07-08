(function (addressRepository) {
    
    var mssql = require("mssql");
    var dbConfig = require('./dbConfig');
    
    addressRepository.listAddresses = function (callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request.query("SELECT * FROM Address", function (err, addresses) {
                if (err) {
                    return err;
                }
                else {
                    return addresses;
                }
            });
            return null;
        });
        return null;
    }
    
    addressRepository.getAddress = function (id, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request.input('id', mssql.Int, id)
            .query("SELECT * FROM Address WHERE Id = @id", function (err, address) {
                if (err) {
                    return err;
                }
                else {
                    callback(address);
                    return address;
                }
            });
            return null;
        });
        return null;
    }
    
    addressRepository.createAddress = function (address, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('street', mssql.VarChar(50), address.Street)
            .input('city', mssql.VarChar(50), address.City)
            .input('state', mssql.VarChar(50), address.State)
            .input('zip', mssql.VarChar(10), address.Zip)
            .query("INSERT INTO Address OUTPUT Inserted.Id Values(@street, @city, @state, @zip)", function (err, addressId) {
                if (err) {
                    return err;
                }
                else {
                    callback(addressId);
                    return addressId;
                }
            });
            return null;
        });
        return null;
    }
    
    addressRepository.updateAddress = function (address, callback){
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('addressId', mssql.Int, address.Id)
            .input('street', mssql.VarChar(50), address.Street)
            .input('city', mssql.VarChar(50), address.City)
            .input('state', mssql.VarChar(50), address.State)
            .input('zip', mssql.VarChar(10), address.Zip)
            .query("UPDATE Address SET Street = @Street, City = @City, State = @State, Zip = @Zip WHERE Id = @addressId", function (err, address) {
                if (err) {
                    callback(err);
                    return err;
                }
                else {
                    callback();
                    return address;
                }
            });
            return null;
        });
        return null;
    }
    
    addressRepository.deleteAddress = function (id, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request.query("DELETE FROM Address WHERE Id = " + id, function (err, address) {
                if (err) {
                    return err;
                }
                else {
                    return address;
                }
            });
            return null;
        });
        return null;
    }

})(module.exports);
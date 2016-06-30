(function (messageRepository) {
    
    var mssql = require("mssql");
    var dbConfig = require('./dbConfig');
    
    messageRepository.listMessages = function (callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request.query("SELECT * FROM Message", function (err, messages) {
                if (err) {
                    return err;
                }
                else {
                    callback(messages);
                    return messages;
                }
            });
            return null;
        });
        return null;
    }
    
    messageRepository.getMessage = function (id, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('id', mssql.Int, id)
            .query("SELECT * FROM Message WHERE Id = @id", function (err, message) {
                if (err) {
                    return err;
                }
                else {
                    callback(message);
                    return message;
                }
            });
            return null;
        });
        return null;
    }
    
    messageRepository.createMessage = function (message, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('sent', mssql.DateTime, message.Sent)
            .input('description', mssql.NVarChar(300), message.Description)
            .query("INSERT INTO Message OUTPUT Inserted.ID Values(@sent, @description)", function (err, messageId) {
                if (err) {
                    return err;
                }
                else {
                    callback(messageId);
                    return messageId;
                }
            });
            return null;
        });
        return null;
    }
    
    messageRepository.updateMessage = function (message, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('messageId', mssql.Int, message.Id)
            .input('sent', mssql.DateTime, message.Sent)
            .input('description', mssql.NVarChar(300), message.Description)
            .query("UPDATE Message SET Sent = @sent, Description = @description WHERE Id = @messageId", function (err, message) {
                if (err) {
                    return err;
                }
                else {
                    callback();
                    return message;
                }
            });
            return null;
        });
        return null;
    }

    
    messageRepository.deleteMessage = function (id, callback) {
        
        var conn = new mssql.Connection(dbConfig.config);
        var request = new mssql.Request(conn);
        
        conn.connect(function (err) {
            if (err) {
                return err;
            }
            request
            .input('messageId', mssql.Int, id)
            .query("DELETE FROM Message WHERE Id = @messageId", function (err, message) {
                if (err) {
                    return err;
                }
                else {
                    callback();
                    return message;
                }
            });
            return null;
        });
        return null;
    }

})(module.exports);
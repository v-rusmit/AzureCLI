(function (messageController) {
    
    var messageRepository = require("../data/messageRepository");
    
    messageController.init = function (app) {
        
        app.get("/api/message",
            function (req, res) {
            messageRepository.listMessages(
                function (messages, err) {
                    if (err) {
                        res.send(404, err);
                    } else {
                        res.json(messages);
                    }
                }
            );
        }
        );
        
        app.get("/api/message/:id",
            function (req, res) {
            
            var id = req.params.id;
            
            messageRepository.getMessage(id,
                    function (message, err) {
                if (err) {
                    res.send(400, err);
                } else {
                    res.json(message[0]);
                }
            }
            );
        }
        );
        
        app.post("/api/message",
            function (req, res) {
            
            var message = {
                Sent: new Date(req.body.Sent),
                Description: req.body.Description
            }
            
            messageRepository.createMessage(message,
                    function (messageId, err) {
                if (err) {
                    res.send(400, "Failed to create Message.");
                } else {
                    res.json(201, messageId[0]);
                }
            });
        });
        
        app.put("/api/message/:id",
            function (req, res) {
            
            var message = {
                Id: req.params.id,
                Sent: new Date(req.body.Sent),
                Description: req.body.Description
            }
            
            messageRepository.updateMessage(message,
                    function (messageId, err) {
                if (err) {
                    res.send(400, "Failed to update Message.");
                } else {
                    res.send(200);
                }
            });
        });
        
        app.delete("/api/message/:id",
            function (req, res) {
            
            var id = req.params.id;
            
            messageRepository.deleteMessage(id,
                    function (err) {
                if (err) {
                    res.send(400, err);
                } else {
                    res.json(200);
                }
            }
            );
        }
        );
    }
})(module.exports);
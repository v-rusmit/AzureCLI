(function(controllers) {

    var alertController = require('./alertController');
    var customerController = require('./customerController');
    var employeeController = require('./employeeController');
    var messageController = require('./messageController');
    var scheduleItemController = require('./scheduleItemController');
    var serviceLogEntryController = require('./serviceLogEntryController');
    var serviceTicketController = require('./serviceTicketController');

    controllers.init = function (app) {
        alertController.init(app);
        customerController.init(app);
        employeeController.init(app);
        messageController.init(app);
        scheduleItemController.init(app);
        serviceLogEntryController.init(app);
        serviceTicketController.init(app);
    };
})(module.exports);
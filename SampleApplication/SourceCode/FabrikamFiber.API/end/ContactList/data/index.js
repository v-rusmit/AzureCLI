(function (repositories) {
    
    var alertRepository = require('./alertRepository');
    var customerRepository = require('./customerRepository');
    var employeeRepository = require('./employeeRepository');
    var messageRepository = require('./messageRepository');
    var scheduleItemRepository = require('./scheduleItemRepository');
    var serviceLogEntryRepository = require('./serviceLogEntryRepository');
    var serviceTicketRepository = require('./serviceTicketRepository');
    var statusRepository = require('./statusRepository');
    
    repositories.init = function (app) {
        //alertRepository.init(app);
        //customerRepository.init(app);
        //employeeRepository.init(app);
        //messageRepository.init(app);
        //scheduleItemRepository.init(app);
        //serviceLogEntryRepository.init(app);
        //serviceTicketRepository.init(app);
    };
})(module.exports);
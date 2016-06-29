namespace FabrikamFiber.DAL.Models
{
    using System;

    public class ScheduleItem
    {
        public int Id { get; set; }

        public int EmployeeId { get; set; }

        public Employee Employee { get; set; }

        public int ServiceTicketId { get; set; }

        public ServiceTicket ServiceTicket { get; set; }

        public DateTime Start { get; set; }

        public int WorkHours { get; set; }

        public DateTime? AssignedOn { get; set; }
    }
}
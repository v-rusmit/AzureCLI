namespace FabrikamFiber.DAL.Models
{
    using System;

    public class ServiceLogEntry
    {
        public int Id { get; set; }

        public DateTime CreatedAt { get; set; }

        public string Description { get; set; }

        public Employee CreatedBy { get; set; }

        public int? CreatedById { get; set; }

        public ServiceTicket ServiceTicket { get; set; }

        public int ServiceTicketId { get; set; }
    }
}

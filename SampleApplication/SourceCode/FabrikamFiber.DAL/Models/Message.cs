namespace FabrikamFiber.DAL.Models
{
    using System;

    public class Message
    {
        public int Id { get; set; }

        public DateTime Sent { get; set; }

        public string Description { get; set; }
    }
}
namespace FabrikamFiber.DAL.Models
{
    using System;

    public class Alert
    {
        public int Id { get; set; }

        public DateTime Created { get; set; }

        public string Description { get; set; }
    }
}
namespace FabrikamFiber.DAL.Models
{
    public class Phone
    {
        public int Id { get; set; }

        public string Label { get; set; }

        public string Number { get; set; }

        public int? CustomerId { get; set; }
    }
}

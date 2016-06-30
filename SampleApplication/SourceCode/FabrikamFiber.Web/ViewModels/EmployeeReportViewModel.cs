using System;

namespace FabrikamFiber.Web.ViewModels
{
    using System.Collections.Generic;
    using System.Web.Mvc;
    using FabrikamFiber.DAL.Models;

    public class EmployeeReportViewModel : Controller
    {
        public IEnumerable<EmployeeSummary> Employees { get; set; }

        public string GetCustomerSummary(Customer customer)
        {
            if(customer != null){
                return string.Format("{0}, {1}", customer.FullName, customer.Address.City);
            }
            return String.Empty;
        }
    }
}

namespace FabrikamFiber.Web.Controllers
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Web.Mvc;

    using FabrikamFiber.DAL.Data;
    using FabrikamFiber.DAL.Models;
    using FabrikamFiber.Web.ViewModels;

    public class ServiceTicketsController : Controller
    {
        private readonly ICustomerRepository customerRepository;
        private readonly IEmployeeRepository employeeRepository;
        private readonly IServiceTicketRepository serviceTicketRepository;
        private readonly IServiceLogEntryRepository serviceLogEntryRepository;
        private readonly IScheduleItemRepository scheduleItemRepository;

        public ServiceTicketsController(
                                        ICustomerRepository customerRepository,
                                        IEmployeeRepository employeeRepository,
                                        IServiceTicketRepository serviceTicketRepository,
                                        IServiceLogEntryRepository serviceLogEntryRepository,
                                        IScheduleItemRepository scheduleItemRepository)
        {
            this.customerRepository = customerRepository;
            this.employeeRepository = employeeRepository;
            this.serviceTicketRepository = serviceTicketRepository;
            this.serviceLogEntryRepository = serviceLogEntryRepository;
            this.scheduleItemRepository = scheduleItemRepository;
        }

        public ViewResult Index()
        {
            return View(this.serviceTicketRepository.AllIncluding(serviceticket => serviceticket.Customer, serviceticket => serviceticket.CreatedBy, serviceticket => serviceticket.AssignedTo));
        }

        public ViewResult Details(int id)
        {
            return View(this.serviceTicketRepository.FindIncluding(id, serviceticket => serviceticket.Customer, serviceticket => serviceticket.CreatedBy, serviceticket => serviceticket.AssignedTo));
        }

        public ViewResult Assign(int id)
        {
            var viewModel = new AssignViewModel
            {
                ServiceTicket = this.serviceTicketRepository.FindIncluding(id, serviceticket => serviceticket.Customer, serviceticket => serviceticket.CreatedBy, serviceticket => serviceticket.AssignedTo),
                AvailableEmployees = this.employeeRepository.All,
                ScheduleItems = this.scheduleItemRepository.AllIncluding(p => p.ServiceTicket)
            };

            return View(viewModel);
        }

        public ViewResult Schedule(int serviceTicketId, int employeeId, float startTime)
        {
            var viewModel = new ScheduleViewModel
            {
                ServiceTicket = this.serviceTicketRepository.FindIncluding(serviceTicketId, serviceticket => serviceticket.Customer, serviceticket => serviceticket.CreatedBy, serviceticket => serviceticket.AssignedTo),
                Employee = this.employeeRepository.Find(employeeId),
                ScheduleItems = this.scheduleItemRepository.AllIncluding(e => e.ServiceTicket).Where(item => item.EmployeeId == employeeId),
            };

            ViewBag.StartTime = startTime;

            return View(viewModel);
        }

        [HttpPost]
        [ActionName("Schedule")]
        public ActionResult AssignSchedule(int serviceTicketId, int employeeId, float startTime)
        {
            this.scheduleItemRepository.All.Where(e => e.ServiceTicketId == serviceTicketId)
                                           .ToList()
                                           .ForEach(e => this.scheduleItemRepository.Delete(e.Id));

            var serviceTicket = this.serviceTicketRepository.Find(serviceTicketId);
            var time = string.Format("Mon 16 May {0:d2}:{1:d2} {2} 2011", ((int)startTime > 12 ? (int)startTime - 12 : (int)startTime) / 1, startTime % 1 == 0.5 ? 30 : 0, startTime < 12 ? "AM" : "PM");
            var startAt = DateTime.ParseExact(time, "ddd dd MMM h:mm tt yyyy", System.Globalization.CultureInfo.InvariantCulture);
            var scheduleItem = new ScheduleItem { EmployeeId = employeeId, ServiceTicketId = serviceTicketId, Start = startAt, WorkHours = 1, AssignedOn = DateTime.Now };
            this.scheduleItemRepository.InsertOrUpdate(scheduleItem);
            serviceTicket.AssignedToId = employeeId;
            serviceTicket.Status = Status.Assigned;

            this.serviceTicketRepository.Save();
            this.scheduleItemRepository.Save();

            return RedirectToAction("Details", new { ID = serviceTicket.Id });
        }

        public ActionResult Create()
        {
            ViewBag.PossibleCustomers = this.customerRepository.All;
            ViewBag.PossibleCreatedBies = this.employeeRepository.All;
            ViewBag.PossibleAssignedToes = this.employeeRepository.All;
            ViewBag.PossibleEscalationLevels = new Dictionary<string, string> { { "1", "Level 1" }, { "2", "Level 2" }, { "3", "Level 3" } };

            var newTicket = new ServiceTicket
            {
                CreatedBy = this.employeeRepository.All.Where(e => e.Identity == "NORTHAMERICA\\drobbins").FirstOrDefault(),
            };

            return View(newTicket);
        }

        [HttpPost]
        [ValidateInput(false)]
        public ActionResult Create(ServiceTicket serviceticket)
        {
            if (ModelState.IsValid)
            {
                serviceticket.Opened = DateTime.Now;
                serviceticket.StatusValue = 4;
                serviceticket.Id = this.serviceTicketRepository.InsertOrUpdate(serviceticket);

                var createdBy = this.employeeRepository.All.Where(e => e.Identity.Equals("NORTHAMERICA\\drobbins")).FirstOrDefault();

                if (createdBy != null)
                    serviceticket.CreatedById = createdBy.Id;

                var serviceLogEntry = new ServiceLogEntry
                {
                    ServiceTicket = serviceticket,
                    CreatedAt = DateTime.Now,
                    CreatedBy = serviceticket.CreatedBy,
                    CreatedById = serviceticket.CreatedById,
                    Description = "Created",
                };

                this.serviceLogEntryRepository.InsertOrUpdate(serviceLogEntry);
                this.serviceLogEntryRepository.Save();

                return RedirectToAction("Details", new { ID = serviceticket.Id });
            }
            else
            {
                ViewBag.PossibleCustomers = this.customerRepository.All;
                ViewBag.PossibleCreatedBies = this.employeeRepository.All;
                ViewBag.PossibleAssignedToes = this.employeeRepository.All;
                ViewBag.PossibleEscalationLevels = new Dictionary<string, string> { { "1", "Level 1" }, { "2", "Level 2" }, { "3", "Level 3" } };

                var newTicket = new ServiceTicket
                {
                    CreatedBy = this.employeeRepository.All.Where(e => e.Identity == "NORTHAMERICA\\drobbins").FirstOrDefault(),
                };

                return View(newTicket);
            }
        }

        public ActionResult Edit(int id)
        {
            ViewBag.PossibleCustomers = this.customerRepository.All;
            ViewBag.PossibleCreatedBies = this.employeeRepository.All;
            ViewBag.PossibleAssignedToes = this.employeeRepository.All;
            ViewBag.PossibleEscalationLevels = new Dictionary<string, string> { { "1", "Level 1" }, { "2", "Level 2" }, { "3", "Level 3" } };

            return View(this.serviceTicketRepository.FindIncluding(id, serviceticket => serviceticket.Customer, serviceticket => serviceticket.CreatedBy, serviceticket => serviceticket.AssignedTo));
        }

        [HttpPost]
        [ValidateInput(false)]
        public ActionResult Edit(ServiceTicket serviceticket)
        {
            if (ModelState.IsValid)
            {
                this.serviceTicketRepository.InsertOrUpdate(serviceticket);
                this.serviceTicketRepository.Save();
                return RedirectToAction("Details", new { id = serviceticket.Id });
            }

            this.ViewBag.PossibleCustomers = this.customerRepository.All;
            this.ViewBag.PossibleCreatedBies = this.employeeRepository.All;
            this.ViewBag.PossibleAssignedToes = this.employeeRepository.All;
            this.ViewBag.PossibleEscalationLevels = new Dictionary<string, string> { { "1", "Level 1" }, { "2", "Level 2" }, { "3", "Level 3" } };

            return this.View();
        }

        public ActionResult Delete(int id)
        {
            return View(this.serviceTicketRepository.Find(id));
        }

        [HttpPost, ActionName("Delete")]
        public ActionResult DeleteConfirmed(int id)
        {
            this.serviceTicketRepository.Delete(id);
            this.serviceTicketRepository.Save();

            return RedirectToAction("Index");
        }

        public JsonResult GetLogEntries(int id)
        {
            var result = this.serviceLogEntryRepository.All.Where(entry => entry.ServiceTicketId == id);
            return Json(new { entries = result.ToList() }, JsonRequestBehavior.AllowGet);
        }
    }
}


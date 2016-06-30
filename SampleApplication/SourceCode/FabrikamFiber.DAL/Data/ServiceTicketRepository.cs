using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using Newtonsoft.Json;

namespace FabrikamFiber.DAL.Data
{
    using System;
    using System.Data;
    using System.Data.Entity;
    using System.Linq;
    using System.Linq.Expressions;

    using FabrikamFiber.DAL.Models;

    public interface IServiceTicketRepository
    {
        IQueryable<ServiceTicket> All { get; }

        IQueryable<ServiceTicket> AllIncluding(params Expression<Func<ServiceTicket, object>>[] includeProperties);

        ServiceTicket Find(int id);

        ServiceTicket FindIncluding(int id, params Expression<Func<ServiceTicket, object>>[] includeProperties);

        int InsertOrUpdate(ServiceTicket serviceTicket);

        void Delete(int id);

        void Save();

        IQueryable<ServiceTicket> AllForReport(params Expression<Func<ServiceTicket, object>>[] includeProperties);
    }

    public class ServiceTicketRepository : IServiceTicketRepository
    {
        private readonly Uri _baseAddress = new Uri("http://localhost:3000/api/");

        public IQueryable<ServiceTicket> All
        {
            get
            {
                var client = new HttpClient();
                client.BaseAddress = _baseAddress;
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                HttpResponseMessage response = client.GetAsync("serviceTicket/").Result;

                if (response.IsSuccessStatusCode)
                {
                    IEnumerable<ServiceTicket> serviceTickets = response.Content.ReadAsAsync<IEnumerable<ServiceTicket>>().Result;
                    return serviceTickets.AsQueryable();
                }

                return null;
            }
        }

        public IQueryable<ServiceTicket> AllIncluding(params Expression<Func<ServiceTicket, object>>[] includeProperties)
        {
            IQueryable<ServiceTicket> query = All;

            foreach (var includeProperty in includeProperties)
            {
                query = query.Include(includeProperty);
            }

            return query;
        }

        public ServiceTicket Find(int id)
        {
            var client = new HttpClient();
            client.BaseAddress = _baseAddress;
            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            HttpResponseMessage response = client.GetAsync("serviceTicket/" + id).Result;

            if (response.IsSuccessStatusCode)
            {
                ServiceTicket serviceTicket = response.Content.ReadAsAsync<ServiceTicket>().Result;
                return serviceTicket;
            }

            return null;
        }

        public ServiceTicket FindIncluding(int id, params Expression<Func<ServiceTicket, object>>[] includeProperties)
        {
            IQueryable<ServiceTicket> query = All.AsQueryable();

            foreach (var includeProperty in includeProperties)
            {
                query = query.Include(includeProperty);
            }

            return query.Where(t => t.Id == id).FirstOrDefault();
        }

        public int InsertOrUpdate(ServiceTicket serviceTicket)
        {
            if (serviceTicket.Id == default(int))
            {
                var client = new HttpClient();
                client.BaseAddress = _baseAddress;
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                string postBody = JsonConvert.SerializeObject(serviceTicket);
                HttpResponseMessage response = client.PostAsync("serviceTicket/", new StringContent(postBody, Encoding.UTF8, "application/json")).Result;

                if (response.IsSuccessStatusCode)
                {
                    int result = response.Content.ReadAsAsync<int>().Result;
                    return result;
                }
                return 0;
            }
            else
            {
                var client = new HttpClient();
                client.BaseAddress = _baseAddress;
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                string postBody = JsonConvert.SerializeObject(serviceTicket);
                HttpResponseMessage response = client.PutAsync("serviceTicket/" + serviceTicket.Id, new StringContent(postBody, Encoding.UTF8, "application/json")).Result;

                if (response.IsSuccessStatusCode)
                {
                    return 0;
                }

                return 0;
            }
        }

        public void Delete(int id)
        {
            var client = new HttpClient();
            client.BaseAddress = _baseAddress;
            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            HttpResponseMessage response = client.DeleteAsync("serviceTicket/" + id).Result;

            if (response.IsSuccessStatusCode)
            {
                return;
            }

        }

        public void Save()
        {
        }

        public IQueryable<ServiceTicket> AllForReport(params Expression<Func<ServiceTicket, object>>[] includeProperties)
        {
            var warehouseContext = new FabrikamFiberWebContext("FabrikamFiber-DataWarehouse");
            IQueryable<ServiceTicket> query = warehouseContext.ServiceTickets;

            foreach (var includeProperty in includeProperties)
            {
                query = query.Include(includeProperty);
            }

            return query;
        }
    }
}
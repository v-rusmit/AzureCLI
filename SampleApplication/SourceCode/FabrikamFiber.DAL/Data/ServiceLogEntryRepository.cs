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

    public interface IServiceLogEntryRepository
    {
        IEnumerable<ServiceLogEntry> All { get; }

        IQueryable<ServiceLogEntry> AllIncluding(params Expression<Func<ServiceLogEntry, object>>[] includeProperties);

        ServiceLogEntry Find(int id);

        void InsertOrUpdate(ServiceLogEntry serviceLogEntry);

        void Delete(int id);

        void Save();
    }

    public class ServiceLogEntryRepository : IServiceLogEntryRepository
    {

        public IEnumerable<ServiceLogEntry> All
        {
            get
            {
                var client = new HttpClient();
                client.BaseAddress = new Uri("http://localhost:3000/api/");
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                HttpResponseMessage response = client.GetAsync("serviceLogEntry/").Result;

                if (response.IsSuccessStatusCode)
                {
                    IEnumerable<ServiceLogEntry> serviceLogEntries = response.Content.ReadAsAsync<IEnumerable<ServiceLogEntry>>().Result;
                    return serviceLogEntries;
                }
                
                return null;
            }
        }

        public IQueryable<ServiceLogEntry> AllIncluding(params Expression<Func<ServiceLogEntry, object>>[] includeProperties)
        {
            IQueryable<ServiceLogEntry> query = All.AsQueryable();

            foreach (var includeProperty in includeProperties)
            {
                query = query.Include(includeProperty);
            }

            return query;
        }

        public ServiceLogEntry Find(int id)
        {
            var client = new HttpClient();
            client.BaseAddress = new Uri("http://localhost:3000/api/");
            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            HttpResponseMessage response = client.GetAsync("serviceLogEntry/" + id).Result;

            if (response.IsSuccessStatusCode)
            {
                ServiceLogEntry serviceLogEntry = response.Content.ReadAsAsync<ServiceLogEntry>().Result;
                return serviceLogEntry;
            }

            return null;
            //return this.context.ServiceLogEntries.Find(id);
        }

        public void InsertOrUpdate(ServiceLogEntry serviceLogEntry)
        {
            if (serviceLogEntry.Id == default(int))
            {
                var client = new HttpClient();
                client.BaseAddress = new Uri("http://localhost:3000/api/");
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                string postBody = JsonConvert.SerializeObject(serviceLogEntry);
                HttpResponseMessage response = client.PostAsync("serviceLogEntry/", new StringContent(postBody, Encoding.UTF8, "application/json")).Result;

                if (response.IsSuccessStatusCode)
                {
                    return;
                }

                //this.context.ServiceLogEntries.Add(serviceLogEntry);
            }
            else
            {
                var client = new HttpClient();
                client.BaseAddress = new Uri("http://localhost:3000/api/");
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                string postBody = JsonConvert.SerializeObject(serviceLogEntry);
                HttpResponseMessage response = client.PutAsync("serviceLogEntry/" + serviceLogEntry.Id, new StringContent(postBody, Encoding.UTF8, "application/json")).Result;

                if (response.IsSuccessStatusCode)
                {
                    return;
                }

                //this.context.Entry(serviceLogEntry).State = EntityState.Modified;
            }
        }

        public void Delete(int id)
        {
            var client = new HttpClient();
            client.BaseAddress = new Uri("http://localhost:3000/api/");
            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            HttpResponseMessage response = client.DeleteAsync("serviceLogEntry/" + id).Result;

            if (response.IsSuccessStatusCode)
            {
                return;
            }

            //var serviceLogEntry = this.context.ServiceLogEntries.Find(id);
            //this.context.ServiceLogEntries.Remove(serviceLogEntry);
        }

        public void Save()
        {
        }
    }
}
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using Newtonsoft.Json;
using System.Runtime.Serialization;
using System.Text;

namespace FabrikamFiber.DAL.Data
{
    using System;
    using System.Data;
    using System.Data.Entity;
    using System.Linq;
    using System.Linq.Expressions;

    using FabrikamFiber.DAL.Models;

    public interface IAlertRepository
    {
        IQueryable<Alert> All { get; }

        IQueryable<Alert> AllIncluding(params Expression<Func<Alert, object>>[] includeProperties);

        Alert Find(int id);

        void InsertOrUpdate(Alert alert);

        void Delete(int id);

        void Save();
    }

    public class AlertRepository : IAlertRepository
    {

        private readonly Uri _baseAddress = new Uri("http://localhost:3000/api/");

        public IQueryable<Alert> All
        {
            get
            {
                var client = new HttpClient();
                client.BaseAddress = _baseAddress;
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                HttpResponseMessage response = client.GetAsync("alert/").Result;

                if (response.IsSuccessStatusCode)
                {
                    IEnumerable<Alert> alerts = response.Content.ReadAsAsync<IEnumerable<Alert>>().Result;
                    return alerts.AsQueryable();
                }

                return null;
            }
        }

        public IQueryable<Alert> AllIncluding(params Expression<Func<Alert, object>>[] includeProperties)
        {
            IQueryable<Alert> query = All;

            foreach (var includeProperty in includeProperties)
            {
                query = query.Include(includeProperty);
            }

            return query;
        }

        public Alert Find(int id)
        {
            var client = new HttpClient();
            client.BaseAddress = _baseAddress;
            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            HttpResponseMessage response = client.GetAsync("alert/" + id).Result;

            if (response.IsSuccessStatusCode)
            {
                Alert alert = response.Content.ReadAsAsync<Alert>().Result;
                return alert;
            }
            return null;
        }

        public void InsertOrUpdate(Alert alert)
        {
            if (alert.Id == default(int))
            {
                //Insert
                var client = new HttpClient();
                client.BaseAddress = _baseAddress;
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                string postBody = JsonConvert.SerializeObject(alert);
                HttpResponseMessage response = client.PostAsync("alert/", new StringContent(postBody, Encoding.UTF8, "application/json")).Result;

                if (response.IsSuccessStatusCode)
                {
                    
                }

            }
            else
            {
                //Update
                var client = new HttpClient();
                client.BaseAddress = _baseAddress;
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                string postBody = JsonConvert.SerializeObject(alert);
                HttpResponseMessage response = client.PutAsync("alert/" + alert.Id, new StringContent(postBody, Encoding.UTF8, "application/json")).Result;

                if (response.IsSuccessStatusCode)
                {
                    
                }
            }
        }

        public void Delete(int id)
        {
            //Delete
            var client = new HttpClient();
            client.BaseAddress = _baseAddress;
            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            HttpResponseMessage response = client.DeleteAsync("alert/" + id).Result;

            if (response.IsSuccessStatusCode)
            {
                return;
            }

        }

        public void Save()
        {
        }
    }
}
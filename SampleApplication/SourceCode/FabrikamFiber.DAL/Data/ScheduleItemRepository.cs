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

    public interface IScheduleItemRepository
    {
        IEnumerable<ScheduleItem> All { get; }

        IQueryable<ScheduleItem> AllIncluding(params Expression<Func<ScheduleItem, object>>[] includeProperties);

        ScheduleItem Find(int id);

        void InsertOrUpdate(ScheduleItem scheduleItem);

        void Delete(int id);

        void Save();
    }

    public class ScheduleItemRepository : IScheduleItemRepository
    {
        private readonly Uri _baseAddress = new Uri("http://localhost:3000/api/");

        public IEnumerable<ScheduleItem> All
        {
            get
            {
                var client = new HttpClient();
                client.BaseAddress = _baseAddress;
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                HttpResponseMessage response = client.GetAsync("scheduleItem").Result;

                if (response.IsSuccessStatusCode)
                {
                    IEnumerable<ScheduleItem> scheduleItems = response.Content.ReadAsAsync<IEnumerable<ScheduleItem>>().Result;
                    return scheduleItems;
                }

                return null;
                //return this.context.ScheduleItems;
            }
        }

        public IQueryable<ScheduleItem> AllIncluding(params Expression<Func<ScheduleItem, object>>[] includeProperties)
        {
            IQueryable<ScheduleItem> query = All.AsQueryable();
            foreach (var includeProperty in includeProperties)
            {
                query = query.Include(includeProperty);
            }

            return query;
        }

        public ScheduleItem Find(int id)
        {
            var client = new HttpClient();
            client.BaseAddress = _baseAddress;
            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            HttpResponseMessage response = client.GetAsync("scheduleItem/" + id).Result;

            if (response.IsSuccessStatusCode)
            {
                ScheduleItem scheduleItem = response.Content.ReadAsAsync<ScheduleItem>().Result;
                return scheduleItem;
            }

            return null;
            //return this.context.ScheduleItems.Find(id);
        }

        public void InsertOrUpdate(ScheduleItem scheduleItem)
        {
            if (scheduleItem.Id == default(int))
            {
                var client = new HttpClient();
                client.BaseAddress = _baseAddress;
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                string postBody = JsonConvert.SerializeObject(scheduleItem);
                HttpResponseMessage response = client.PostAsync("scheduleItem/", new StringContent(postBody, Encoding.UTF8, "application/json")).Result;

                if (response.IsSuccessStatusCode)
                {
                    return;
                }

                // New entity
                //this.context.ScheduleItems.Add(scheduleItem);
            }
            else
            {
                var client = new HttpClient();
                client.BaseAddress = _baseAddress;
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                string postBody = JsonConvert.SerializeObject(scheduleItem);
                HttpResponseMessage response = client.PutAsync("scheduleItem/" + scheduleItem.Id, new StringContent(postBody, Encoding.UTF8, "application/json")).Result;

                if (response.IsSuccessStatusCode)
                {
                    return;
                }

                // Existing entity
                //this.context.Entry(scheduleItem).State = EntityState.Modified;
            }
        }

        public void Delete(int id)
        {
            var client = new HttpClient();
            client.BaseAddress = _baseAddress;
            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            HttpResponseMessage response = client.DeleteAsync("scheduleItem/" + id).Result;

            if (response.IsSuccessStatusCode)
            {
                return;
            }

            //var scheduleItem = this.context.ScheduleItems.Find(id);
            //this.context.ScheduleItems.Remove(scheduleItem);
        }

        public void Save()
        {
        }
    }
}
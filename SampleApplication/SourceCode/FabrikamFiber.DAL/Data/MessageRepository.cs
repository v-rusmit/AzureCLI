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

    public interface IMessageRepository
    {
        IQueryable<Message> All { get; }

        IQueryable<Message> AllIncluding(params Expression<Func<Message, object>>[] includeProperties);

        Message Find(int id);

        void InsertOrUpdate(Message message);

        void Delete(int id);

        void Save();
    }

    public class MessageRepository : IMessageRepository
    {

        public IQueryable<Message> All
        {
            get
            {
                var client = new HttpClient();
                client.BaseAddress = new Uri("http://localhost:3000/api/");
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                HttpResponseMessage response = client.GetAsync("message/").Result;

                if (response.IsSuccessStatusCode)
                {
                    IEnumerable<Message> messages = response.Content.ReadAsAsync<IEnumerable<Message>>().Result;
                    return messages.AsQueryable();
                }

                return null;
            }
        }

        public IQueryable<Message> AllIncluding(params Expression<Func<Message, object>>[] includeProperties)
        {
            IQueryable<Message> query = All;

            foreach (var includeProperty in includeProperties)
            {
                query = query.Include(includeProperty);
            }

            return query;
        }

        public Message Find(int id)
        {
            var client = new HttpClient();
            client.BaseAddress = new Uri("http://localhost:3000/api/");
            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            HttpResponseMessage response = client.GetAsync("message/" + id).Result;

            if (response.IsSuccessStatusCode)
            {
                Message message = response.Content.ReadAsAsync<Message>().Result;
                return message;
            }

            return null;
            //return this.context.Messages.Find(id);
        }

        public void InsertOrUpdate(Message message)
        {
            if (message.Id == default(int))
            {
                var client = new HttpClient();
                client.BaseAddress = new Uri("http://localhost:3000/api/");
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                string postBody = JsonConvert.SerializeObject(message);
                HttpResponseMessage response = client.PostAsync("message/", new StringContent(postBody, Encoding.UTF8, "application/json")).Result;

                if (response.IsSuccessStatusCode)
                {
                    return;
                }

                //this.context.Messages.Add(message);
            }
            else
            {
                var client = new HttpClient();
                client.BaseAddress = new Uri("http://localhost:3000/api/");
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                string postBody = JsonConvert.SerializeObject(message);
                HttpResponseMessage response = client.PutAsync("message/" + message.Id, new StringContent(postBody, Encoding.UTF8, "application/json")).Result;

                if (response.IsSuccessStatusCode)
                {
                    return;
                }

                //this.context.Entry(message).State = EntityState.Modified;
            }
        }

        public void Delete(int id)
        {
            var client = new HttpClient();
            client.BaseAddress = new Uri("http://localhost:3000/api/");
            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            HttpResponseMessage response = client.DeleteAsync("message/" + id).Result;

            if (response.IsSuccessStatusCode)
            {
                return;
            }

            //var message = this.context.Messages.Find(id);
            //this.context.Messages.Remove(message);
        }

        public void Save()
        {
            //this.context.SaveChanges();
        }
    }
}
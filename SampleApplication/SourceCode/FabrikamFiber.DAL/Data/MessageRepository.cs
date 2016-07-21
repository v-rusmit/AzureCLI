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

        private readonly Uri _baseAddress = new Uri(System.Configuration.ConfigurationManager.AppSettings["ApiBaseUrl"]);

        public IQueryable<Message> All
        {
            get
            {
                var client = new HttpClient();
                client.BaseAddress = _baseAddress;
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
            client.BaseAddress = _baseAddress;
            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            HttpResponseMessage response = client.GetAsync("message/" + id).Result;

            if (response.IsSuccessStatusCode)
            {
                Message message = response.Content.ReadAsAsync<Message>().Result;
                return message;
            }

            return null;
        }

        public void InsertOrUpdate(Message message)
        {
            if (message.Id == default(int))
            {
                var client = new HttpClient();
                client.BaseAddress = _baseAddress;
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                string postBody = JsonConvert.SerializeObject(message);
                HttpResponseMessage response = client.PostAsync("message/", new StringContent(postBody, Encoding.UTF8, "application/json")).Result;

                if (response.IsSuccessStatusCode)
                {
                    return;
                }
                
            }
            else
            {
                var client = new HttpClient();
                client.BaseAddress = _baseAddress;
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                string postBody = JsonConvert.SerializeObject(message);
                HttpResponseMessage response = client.PutAsync("message/" + message.Id, new StringContent(postBody, Encoding.UTF8, "application/json")).Result;

                if (response.IsSuccessStatusCode)
                {
                    return;
                }
                
            }
        }

        public void Delete(int id)
        {
            var client = new HttpClient();
            client.BaseAddress = _baseAddress;
            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            HttpResponseMessage response = client.DeleteAsync("message/" + id).Result;

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
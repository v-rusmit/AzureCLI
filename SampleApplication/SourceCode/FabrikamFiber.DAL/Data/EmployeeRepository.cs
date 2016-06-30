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

    public interface IEmployeeRepository
    {
        IQueryable<Employee> All { get; }

        IQueryable<Employee> AllIncluding(params Expression<Func<Employee, object>>[] includeProperties);

        Employee Find(int id);

        void InsertOrUpdate(Employee employee);

        void Delete(int id);

        void Save();

        Employee ReportFind(int id);
    }

    public class EmployeeRepository : IEmployeeRepository
    {

        public IQueryable<Employee> All
        {
            get
            {
                var client = new HttpClient();
                client.BaseAddress = new Uri("http://localhost:3000/api/");
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                HttpResponseMessage response = client.GetAsync("employee/").Result;

                if (response.IsSuccessStatusCode)
                {
                    IEnumerable<Employee> employees = response.Content.ReadAsAsync<IEnumerable<Employee>>().Result;
                    return employees.AsQueryable();
                }
                return null;
            }
        }

        public IQueryable<Employee> AllIncluding(params Expression<Func<Employee, object>>[] includeProperties)
        {
            IQueryable<Employee> query = All;
            foreach (var includeProperty in includeProperties)
            {
                query = query.Include(includeProperty);
            }

            return query;
        }

        public Employee Find(int id)
        {
            var client = new HttpClient();
            client.BaseAddress = new Uri("http://localhost:3000/api/");
            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            HttpResponseMessage response = client.GetAsync("employee/" + id).Result;

            if (response.IsSuccessStatusCode)
            {
                Employee employee = response.Content.ReadAsAsync<Employee>().Result;
                return employee;
            }

            return null;
        }

        public void InsertOrUpdate(Employee employee)
        {
            if (employee.Id == default(int))
            {
                var client = new HttpClient();
                client.BaseAddress = new Uri("http://localhost:3000/api/");
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                string postBody = JsonConvert.SerializeObject(employee);
                HttpResponseMessage response = client.PostAsync("employee/", new StringContent(postBody, Encoding.UTF8, "application/json")).Result;

                if (response.IsSuccessStatusCode)
                {
                    return;
                }

            }
            else
            {
                var client = new HttpClient();
                client.BaseAddress = new Uri("http://localhost:3000/api/");
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                string postBody = JsonConvert.SerializeObject(employee);
                HttpResponseMessage response = client.PutAsync("employee/" + employee.Id, new StringContent(postBody, Encoding.UTF8, "application/json")).Result;

                if (response.IsSuccessStatusCode)
                {
                    return;
                }

            }
        }

        public void Delete(int id)
        {
            var client = new HttpClient();
            client.BaseAddress = new Uri("http://localhost:3000/api/");
            client.DefaultRequestHeaders.Accept.Clear();
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            HttpResponseMessage response = client.DeleteAsync("employee/" + id).Result;

            if (response.IsSuccessStatusCode)
            {
                return;
            }

        }

        public void Save()
        {
        }

        public Employee ReportFind(int id)
        {
            // if (id == 2) return null;
            return Find(id);
        }
    }
}
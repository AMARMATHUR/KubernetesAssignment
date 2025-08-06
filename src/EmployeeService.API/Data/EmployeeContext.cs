using Microsoft.EntityFrameworkCore;
using EmployeeService.API.Models;

namespace EmployeeService.API.Data
{
    public class EmployeeContext : DbContext
    {
        public EmployeeContext(DbContextOptions<EmployeeContext> options) : base(options)
        {
        }

        public DbSet<Employee> Employees { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Employee>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
                entity.Property(e => e.Email).IsRequired().HasMaxLength(150);
                entity.Property(e => e.Department).IsRequired().HasMaxLength(50);
                entity.Property(e => e.Salary).HasColumnType("decimal(10,2)");
            });

            // Seed data
            modelBuilder.Entity<Employee>().HasData(
                new Employee { Id = 1, Name = "John Doe", Email = "john.doe@company.com", Department = "Engineering", Salary = 75000, HireDate = new DateTime(2022, 1, 15, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new Employee { Id = 2, Name = "Jane Smith", Email = "jane.smith@company.com", Department = "Marketing", Salary = 65000, HireDate = new DateTime(2022, 3, 22, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new Employee { Id = 3, Name = "Mike Johnson", Email = "mike.johnson@company.com", Department = "Engineering", Salary = 82000, HireDate = new DateTime(2021, 11, 8, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new Employee { Id = 4, Name = "Sarah Wilson", Email = "sarah.wilson@company.com", Department = "HR", Salary = 58000, HireDate = new DateTime(2023, 2, 14, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new Employee { Id = 5, Name = "David Brown", Email = "david.brown@company.com", Department = "Finance", Salary = 70000, HireDate = new DateTime(2022, 7, 30, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new Employee { Id = 6, Name = "Lisa Garcia", Email = "lisa.garcia@company.com", Department = "Engineering", Salary = 78000, HireDate = new DateTime(2023, 1, 10, 0, 0, 0, DateTimeKind.Utc), IsActive = true },
                new Employee { Id = 7, Name = "Robert Taylor", Email = "robert.taylor@company.com", Department = "Sales", Salary = 62000, HireDate = new DateTime(2022, 9, 5, 0, 0, 0, DateTimeKind.Utc), IsActive = false },
                new Employee { Id = 8, Name = "Emily Davis", Email = "emily.davis@company.com", Department = "Marketing", Salary = 67000, HireDate = new DateTime(2023, 4, 18, 0, 0, 0, DateTimeKind.Utc), IsActive = true }
            );
        }
    }
}

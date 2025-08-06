using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using EmployeeService.API.Data;
using EmployeeService.API.Models;

namespace EmployeeService.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class EmployeesController : ControllerBase
    {
        private readonly EmployeeContext _context;
        private readonly ILogger<EmployeesController> _logger;

        public EmployeesController(EmployeeContext context, ILogger<EmployeesController> logger)
        {
            _context = context;
            _logger = logger;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<Employee>>> GetEmployees()
        {
            try
            {
                _logger.LogInformation("Fetching all employees");
                var employees = await _context.Employees.ToListAsync();
                _logger.LogInformation($"Retrieved {employees.Count} employees");
                return Ok(employees);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error occurred while fetching employees");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<Employee>> GetEmployee(int id)
        {
            try
            {
                _logger.LogInformation($"Fetching employee with ID: {id}");
                var employee = await _context.Employees.FindAsync(id);

                if (employee == null)
                {
                    _logger.LogWarning($"Employee with ID: {id} not found");
                    return NotFound();
                }

                return Ok(employee);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error occurred while fetching employee with ID: {id}");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("department/{department}")]
        public async Task<ActionResult<IEnumerable<Employee>>> GetEmployeesByDepartment(string department)
        {
            try
            {
                _logger.LogInformation($"Fetching employees from department: {department}");
                var employees = await _context.Employees
                    .Where(e => e.Department.ToLower() == department.ToLower())
                    .ToListAsync();
                
                _logger.LogInformation($"Retrieved {employees.Count} employees from {department} department");
                return Ok(employees);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error occurred while fetching employees from department: {department}");
                return StatusCode(500, "Internal server error");
            }
        }

        [HttpGet("health")]
        public IActionResult Health()
        {
            return Ok(new { Status = "Healthy", Timestamp = DateTime.UtcNow });
        }
    }
}

using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
using System.Threading.Tasks;

namespace Tete.Api.Controllers
{
  [ApiController]
  [Route("[controller]")]
  public class HealthController : ControllerBase
  {
    private readonly Tete.Api.Contexts.MainContext _context;

    public HealthController(Tete.Api.Contexts.MainContext context)
    {
      _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> Get()
    {
      try
      {
        var healthStatus = new
        {
          status = "healthy",
          timestamp = DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ss.fffZ"),
          application = "Tete Web API",
          database = await CheckDatabaseConnection()
        };

        return Ok(healthStatus);
      }
      catch (Exception ex)
      {
        var healthStatus = new
        {
          status = "unhealthy",
          timestamp = DateTime.UtcNow.ToString("yyyy-MM-ddTHH:mm:ss.fffZ"),
          application = "Tete Web API",
          error = ex.Message,
          database = new { status = "error", message = ex.Message }
        };

        return StatusCode(503, healthStatus);
      }
    }

    private async Task<object> CheckDatabaseConnection()
    {
      try
      {
        await _context.Database.OpenConnectionAsync();
        await _context.Database.CloseConnectionAsync();
        
        return new { status = "connected", message = "Database connection successful" };
      }
      catch (Exception ex)
      {
        return new { status = "error", message = ex.Message };
      }
    }
  }
}
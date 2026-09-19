using Microsoft.AspNetCore.Mvc;

namespace Bookcase.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class HealthController : ControllerBase
{
    // GET api/health
    [HttpGet]
    public IActionResult Get()
    {
        return Ok(new
        {
            status = "ok",
            service = "Bookcase.Api",
            timeUtc = DateTime.UtcNow
        });
    }
}

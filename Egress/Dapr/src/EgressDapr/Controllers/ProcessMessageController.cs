using Microsoft.AspNetCore.Mvc;
using System.Text.Json;

namespace EgressDapr.Controllers;

[ApiController]
public class ProcessMessageController : ControllerBase
{
    public ProcessMessageController(ILogger<ProcessMessageController> logger)
    {
        _logger = logger;
    }

    [HttpPost("/processmessage")]
    public ActionResult ProcessMessage(JsonDocument input)
    {
        using (var stream = new MemoryStream())
        {
            using (var writer = new Utf8JsonWriter(stream))
            {
                input.WriteTo(writer);
            }

            stream.Seek(0, SeekOrigin.Begin);
            using (var reader = new StreamReader(stream))
            {
                _logger.LogInformation($"Received the following message:{Environment.NewLine}{reader.ReadToEnd()}");
                return Ok();
            }
        }
    }

    private readonly ILogger<ProcessMessageController> _logger;
}
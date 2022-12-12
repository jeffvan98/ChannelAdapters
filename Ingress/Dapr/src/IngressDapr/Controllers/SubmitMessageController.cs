using Dapr.Client;
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;

namespace IngressDapr.Controllers;

[ApiController]
[Route("[controller]")]
public class SubmitMessageController : ControllerBase
{
    public SubmitMessageController(ILogger<SubmitMessageController> logger)
    {
        _logger = logger;
    }

    [HttpPost]
    public async Task<ActionResult> SubmitMessage(JsonDocument input, [FromServices] DaprClient daprClient)
    {
        await daprClient.InvokeBindingAsync("channel", "create", input);
        return Accepted();
    }

    private readonly ILogger<SubmitMessageController> _logger;
}

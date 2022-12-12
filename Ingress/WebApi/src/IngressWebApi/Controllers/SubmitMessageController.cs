using Azure.Messaging.ServiceBus;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;
using System.Text.Json;
using IngressWebApi.Utilities;

namespace IngressWebApi.Controllers;

[ApiController]
[Route("[controller]")]
public class SubmitMessageController : ControllerBase
{
    public SubmitMessageController(ILogger<SubmitMessageController> logger, IOptions<AppOptions> options, ServiceBusClient client)
    {
        _logger = logger;
        _sender = client.CreateSender(options.Value.Queue);
    }

    [HttpPost]
    public async Task<ActionResult> SubmitMessage(JsonDocument input)
    {    
        var message = new ServiceBusMessage(BinaryData.FromObjectAsJson(input));
        await _sender.SendMessageAsync(message);
        return Accepted();
    }

    private ILogger<SubmitMessageController> _logger;
    private ServiceBusSender _sender;
}
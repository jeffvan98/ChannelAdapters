using System.Net;
using System.Text.Json;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace IngressFunc;

public class SubmitMessage
{
    public SubmitMessage(ILoggerFactory loggerFactory)
    {
        _logger = loggerFactory.CreateLogger<SubmitMessage>();
    }

    [Function("SubmitMessage")]
    public SubmitMessageResult Run([HttpTrigger(AuthorizationLevel.Anonymous, "post")] HttpRequestData req)
    {
        var input = JsonDocument.Parse(req.Body);
        return new SubmitMessageResult() 
        {
            HttpResponseData = req.CreateResponse(HttpStatusCode.Accepted),
            Data = input
        };
    }

    private readonly ILogger _logger;
}

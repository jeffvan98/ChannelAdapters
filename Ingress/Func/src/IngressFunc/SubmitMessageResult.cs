using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using System.Text.Json;

namespace IngressFunc;

public class SubmitMessageResult
{
    public HttpResponseData? HttpResponseData { get; set; } = default;

    [ServiceBusOutput("%QueueName%", Connection="IngressFunc")]
    public JsonDocument? Data { get; set; } = default;
}
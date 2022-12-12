using System;
using System.Text.Json;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace EgressFunc
{
    public class ProcessMessage
    {
        private readonly ILogger _logger;

        public ProcessMessage(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<ProcessMessage>();
        }

        [Function("ProcessMessage")]
        public void Run([ServiceBusTrigger("%QueueName%", Connection = "EgressFunc")] JsonDocument input)
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
                }
            }
        }
    }
}

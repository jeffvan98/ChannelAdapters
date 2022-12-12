using Azure.Messaging.ServiceBus;
using Microsoft.Extensions.Options;
using System.Text.Json;
using EgressWebApi.Utilities;

namespace EgressWebApi.Services;

public class ProcessMessageService : BackgroundService
{
    public ProcessMessageService(ILogger<ProcessMessageService> logger, IOptions<AppOptions> options, ServiceBusClient client)
    {
        _logger = logger;
        _processor = client.CreateProcessor(options.Value.Queue);
        _processor.ProcessErrorAsync += ProcessServicesBusError;
        _processor.ProcessMessageAsync += ProcessServiceBusMessage;
    }

    public override async Task StartAsync(CancellationToken cancellationToken)
    {
        await _processor.StartProcessingAsync(cancellationToken);
        await base.StartAsync(cancellationToken);
    }

    protected override Task ExecuteAsync(CancellationToken stoppingToken)
    {
        return Task.CompletedTask;
    }

    public override async Task StopAsync(CancellationToken cancellationToken)
    {
        await base.StopAsync(cancellationToken);
        await _processor.StopProcessingAsync(cancellationToken);
    }

    private Task ProcessServicesBusError(ProcessErrorEventArgs args)
    {   
        _logger.LogError(args.Exception, "Unexpected error: {0}; {1}", args.ErrorSource, args.EntityPath);
        return Task.CompletedTask;
    }

    private async Task ProcessServiceBusMessage(ProcessMessageEventArgs args)
    {
        using (var doc = await JsonDocument.ParseAsync(args.Message.Body.ToStream()))
        {
            using (var stream = new MemoryStream())
            {
                using (var writer = new Utf8JsonWriter(stream))
                {
                    doc.WriteTo(writer);
                }

                stream.Seek(0, SeekOrigin.Begin);
                using (var reader = new StreamReader(stream))
                {
                    _logger.LogInformation($"Received the following message:{Environment.NewLine}{await reader.ReadToEndAsync()}");
                }
            }
        }
    }

    private readonly ILogger<ProcessMessageService> _logger;
    private readonly ServiceBusProcessor _processor;
}
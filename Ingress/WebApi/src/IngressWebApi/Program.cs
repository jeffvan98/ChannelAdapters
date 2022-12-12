using Azure.Identity;
using Microsoft.Extensions.Azure;
using IngressWebApi.Utilities;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddAzureClients(acf => {
    acf.UseCredential(new DefaultAzureCredential());
    acf.ConfigureDefaults(builder.Configuration.GetSection("AzureDefaults"));
    acf.AddServiceBusClient(builder.Configuration.GetSection("ServiceBus"));
});

builder.Services.Configure<AppOptions>(
    builder.Configuration.GetSection("IngressWebApi"));

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.MapControllers();
app.Run();

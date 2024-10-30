# HttpClientFactory 
## Key features

- uses a configuration class 'EndpointOptions' - there is probably a better name
- uses a Token Service to generate the token
- uses caching to cache the token - probably doesn't save much time


## Not complete examples below, but enough to get you started.

https://learn.microsoft.com/en-us/dotnet/core/extensions/httpclient-factory

```CSharp
  public static void Main(string[] args)
  {
      var builder = WebApplication.CreateBuilder(args);
      builder.Services.AddScoped<ITokenService, TokenService>();
      builder.Services.AddTransient<TokenHandler>();

      EndpointOptions endpointOptions = new();
      builder.Configuration.GetSection(nameof(EndpointOptions)).Bind(endpointOptions);
      // attempting CommonGraphQL Factory
      string? httpClientName = endpointOptions.CommonGraphURL;
      builder.Services.AddHttpClient(
          httpClientName,
          client =>
          {
              client.BaseAddress = new Uri(endpointOptions.CommonGraphURL);
              client.DefaultRequestHeaders.Accept.Add(
                  new MediaTypeWithQualityHeaderValue("application/json"));
          })
          .AddHttpMessageHandler<TokenHandler>();

      // end attempt
```

```CSharp
public class TokenHandler : DelegatingHandler
{
    private readonly ITokenService _tokenService;
    public TokenHandler(ITokenService tokenService)
    {
        _tokenService = tokenService;
    }

    protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        var token = await _tokenService.GetTokenAsync();
        if (token != null)
        {
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
        }

        return await base.SendAsync(request, cancellationToken);
    }
}
```


```CSharp
 public class TokenService : ITokenService
 {
     private static string? _cachedToken;
     private static DateTime _tokenExpiry;
     public EndpointOptions? _endpointOptions { get; private set; }
     private readonly IConfiguration _configuration;
     public TokenService(IConfiguration configuration)
     {
         _configuration = configuration;
         EndpointOptions = _configuration.GetSection("EndpointOptions").Get<EndpointOptions>() ?? throw new ArgumentNullException(nameof(EndpointOptions), "Endpoint options are missing in configuration.");
     }
     public EndpointOptions? EndpointOptions { get; set; }
     public Task<string> GetTokenAsync()
     {
         if (!string.IsNullOrEmpty(_cachedToken) && DateTime.UtcNow < _tokenExpiry)
         {
             return Task.FromResult(_cachedToken);
         }

         var options = EndpointOptions ?? throw new InvalidOperationException("Endpoint options are not configured.");
         string apiKey = options.APIKey ?? throw new InvalidOperationException("APIKey is not configured.");
         string issuer = options.Issuer ?? throw new InvalidOperationException("Issuer is not configured.");
         string audience = options.Audience ?? throw new InvalidOperationException("Audience is not configured.");
         string role = options.Role ?? throw new InvalidOperationException("Role is not configured.");
         string name = options.Name ?? throw new InvalidOperationException("Name is not configured.");

         var symmetricSecurityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(apiKey));
         var credentials = new SigningCredentials(symmetricSecurityKey, SecurityAlgorithms.HmacSha256);
         var claims = new Claim[] {
             new Claim(ClaimTypes.Role, role),
             new Claim(ClaimTypes.Name, name)
         };

         var jwtToken = new JwtSecurityToken(
             issuer: issuer,
             audience: audience,
             claims: claims,
             expires: DateTime.Now.AddMinutes(1440),
             signingCredentials: credentials
         );

         _cachedToken = new JwtSecurityTokenHandler().WriteToken(jwtToken);
         _tokenExpiry = jwtToken.ValidTo;
         return Task.FromResult(_cachedToken);
     }
```


```json
{
  "EndpointOptions": {
    "APIKey": "k#yExample!!!",
    "Audience": "anothervariableforencryption",
    "AzurePersonalAccessToken": "borkborkbork!",
    "CommonGraphURL": "CommonGraphURL goes here",
    "ConnectionMessage": "UI message here",
    "FormGraphURL": "FormGraphURL",
    "GatewayGraphURL": "GatewayGraph/graphql",
    "Issuer": "https://yournamehere.com",
    "Name": "Fred Flintstone",
    "OracleConnectionString": "pleaseuseSQLServer",
    "PaymentGraphURL": "PaymentGraph/graphql/",
    "ReportGraphURL": "/ReportGraph/graphql/",
    "Role": "user",

    "Logging": {
      "LogLevel": {
        "Default": "Information",
        "Microsoft.AspNetCore": "Warning"
      }
    },
    "AllowedHosts": "*"
  }
}
```

```CSharp
  public class EndpointOptions
  {
      public string? APIKey { get; set; }
      public string? Audience { get; set; }
      public string? AzurePersonalAccessToken { get; set; }
      public string? CommonGraphURL { get; set; }
      public string? ConnectionMessage { get; set; }
      public string? FormGraphURL { get; set; }
      public string? GatewayGraphURL { get; set; }
      public string? Issuer { get; set; }
      public string? Name { get; set; }
      public string? OracleConnectionString { get; set; }
      public string? PaymentGraphURL { get; set; }
      public string? ReportGraphURL { get; set; }
      public string? Role { get; set; }
  }

  public class LogLevelConfig
  {
      public string? Default { get; set; }
      public string? MicrosoftAspNetCore { get; set; }
  }

  public class LoggingConfig
  {
      public LogLevelConfig? LogLevel { get; set; }
  }

  public class AppConfig
  {
      public EndpointOptions? Logger { get; set; }
      public LoggingConfig? Logging { get; set; }
      public string? AllowedHosts { get; set; }
  }
  ```

# Console App

## credit: ClaudeAI
https://claude.ai/chat/25010d19-ca36-41f8-aabe-4ba8c662f81b

1. Install the required NuGet package:
   ```
   dotnet add package Microsoft.Extensions.Http
   ```

2. In your `Program.cs` file, add the following using statements:
   ```csharp
   using Microsoft.Extensions.DependencyInjection;
   using Microsoft.Extensions.Hosting;
   ```

3. In the `Main` method, create a new `IHostBuilder` and configure the `HttpClientFactory`:
   ```csharp
   using IHost host = Host.CreateDefaultBuilder(args)
       .ConfigureServices((_, services) =>
           services.AddHttpClient())
       .Build();

   // Use the HttpClient here
   using var httpClient = host.Services.GetRequiredService<IHttpClientFactory>().CreateClient();
   ```

Here's the complete `Program.cs` file:

```csharp
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

using IHost host = Host.CreateDefaultBuilder(args)
    .ConfigureServices((_, services) =>
        services.AddHttpClient())
    .Build();

using var httpClient = host.Services.GetRequiredService<IHttpClientFactory>().CreateClient();

// Use the HttpClient here
```

The key steps are:

1. Install the `Microsoft.Extensions.Http` NuGet package.
2. Add the required using statements.
3. Create a new `IHostBuilder` and configure the `HttpClientFactory` by calling `services.AddHttpClient()`.
4. Retrieve an instance of the `IHttpClientFactory` from the dependency injection container and use it to create an `HttpClient` instance.

This setup allows you to use the `HttpClient` throughout your console application with the benefits of the `HttpClientFactory`, such as request retries, automatic disposal, and more.

Let me know if you have any other questions!

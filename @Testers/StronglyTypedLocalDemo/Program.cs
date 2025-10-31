//using AppSettingsAccessor.Tester;


var builder = WebApplication.CreateBuilder(args);

//=================================//

////Access appsettings data:
//StartupData stData = new(builder.Configuration);

//var bccAddresses = stData.EmailSection.GetBccAddresses();
//Debug.WriteLine($"BCC Addresses: {string.Join(", ", bccAddresses)}");

//var ccAddresses = stData.EmailSection.GetCcAddresses();
//Debug.WriteLine($"CC Addresses: {string.Join(", ", ccAddresses)}");

//var defaultToAddress = stData.EmailSection.GetToAddress();
//Debug.WriteLine($"Default To Address: {defaultToAddress}");

//var maxSize = stData.GetMaxSize();
//Debug.WriteLine($"Max Size: {maxSize}");

//var minSize = stData.GetMinSize();
//Debug.WriteLine($"Min Size: {minSize}");

//var defaultLogLevel = stData.LoggingSection.LogLevelSection.GetDefault();
//Debug.WriteLine($"Default Log Level: {defaultLogLevel}");

//var msLogLevel = stData.LoggingSection.LogLevelSection.GetMicrosoft_AspNetCore();
//Debug.WriteLine($"Microsoft ASP.NET Core Log Level: {msLogLevel}");

//var googleOathClientId = stData.OAuthSection.GoogleSection.GetClientId();
//Debug.WriteLine($"Google OAuth Client ID: {googleOathClientId}");

//var googleOathClientSecret = stData.OAuthSection.GoogleSection.GetClientSecret();
//Debug.WriteLine($"Google OAuth Client Secret: {googleOathClientSecret}");

//var qRQ_Ijk = stData.ChMgrSection.EmailSection.InnerEmailSection.ABCSection.QRQSection.GetIjk();
//Debug.WriteLine($"QRQ IJK Values: {string.Join(", ", qRQ_Ijk)}");


//---------------------------------//

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();


//---------------------------------//

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();

//=================================//
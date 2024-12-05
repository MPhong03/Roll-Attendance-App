using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using RollAttendanceServer.Configs;
using RollAttendanceServer.Data;
using MudBlazor.Services;
using System.Text;
using Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage;
using Microsoft.AspNetCore.Components.Authorization;
using RollAttendanceServer.Authentication;
using RollAttendanceServer.Models;
using Microsoft.AspNetCore.Authorization;
using RollAttendanceServer.Middlewares;
using Microsoft.AspNetCore.Authentication;
using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;
using Microsoft.Extensions.Configuration;
using RollAttendanceServer.Services.Configs;
using RollAttendanceServer.Services.Systems;
using System.Reflection;

namespace RollAttendanceServer
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            builder.Services.ConfigureServices(builder);

            // DATABASE CONNECTION
            builder.Services.AddDbContext<ApplicationDbContext>(options =>
                options.UseSqlServer(builder.Configuration.GetConnectionString("ITPDatabase")).EnableSensitiveDataLogging()
            );

            builder.Services.AddHttpContextAccessor();

            // AUTHENTICATION STATE
            builder.Services.AddScoped<ProtectedSessionStorage>();
            builder.Services.AddScoped<AuthenticationStateProvider, CustomAuthenticationStateProvider>();
            builder.Services.AddScoped<CustomAuthenticationStateProvider>();

            // REGISTER JWT SERVICE
            builder.Services.AddScoped<JwtService>();
            builder.Services.AddScoped<AuthService>();
            builder.Services.AddScoped<LoadingService>();

            // SINGLETON
            builder.Services.AddSingleton<CloudinaryService>();

            // FIREBASE
            FirebaseApp.Create(new AppOptions
            {
                Credential = GoogleCredential.FromFile(builder.Configuration.GetValue<string>("Firebase:CredentialsPath"))
            });

            // AUTHENTICATION
            //builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            //    .AddJwtBearer(options =>
            //    {
            //        options.TokenValidationParameters = new TokenValidationParameters
            //        {
            //            ValidateIssuer = true,
            //            ValidateAudience = true,
            //            ValidateLifetime = true,
            //            ValidateIssuerSigningKey = true,
            //            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            //            ValidAudience = builder.Configuration["Jwt:Audience"],
            //            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]))
            //        };
            //    });
            builder.Services.AddAuthentication("Firebase")
                .AddScheme<AuthenticationSchemeOptions, FirebaseAuthenticationHandler>("Firebase", null);


            builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
                .AddCookie(options =>
                {
                    options.LoginPath = "/login";
                    options.LogoutPath = "/logout";
                    options.ExpireTimeSpan = TimeSpan.FromHours(2);
                    options.AccessDeniedPath = "/access-denied";
                });

            builder.Services.AddControllers();
            builder.Services.AddEndpointsApiExplorer();

            // Add services to the container.
            builder.Services.AddRazorPages();
            builder.Services.AddServerSideBlazor();

            // CORS Configuration
            builder.Services.AddCors(options =>
            {
                options.AddPolicy("AllowAll", builder =>
                {
                    builder.AllowAnyOrigin()
                           .AllowAnyMethod()
                           .AllowAnyHeader();
                });
            });

            // Mud Blazor
            builder.Services.AddMudServices();

            var app = builder.Build();

            // Configure the HTTP request pipeline.
            if (!app.Environment.IsDevelopment())
            {
                app.UseExceptionHandler("/Error");
                // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
                app.UseHsts();
            }

            app.UseHttpsRedirection();

            app.UseRouting();

            app.UseAuthentication();
            app.UseAuthorization();

            app.UseStaticFiles();

            // API Controllers
            app.MapControllers();

            // CORS Policy
            app.UseCors("AllowAll");

            app.MapBlazorHub();
            app.MapFallbackToPage("/_Host");


            app.Run();
        }
    }

    public static class ServiceExtensions
    {
        public static void ConfigureServices(this IServiceCollection services, WebApplicationBuilder builder)
        {
            var serviceAssembly = Assembly.GetExecutingAssembly();
            var serviceTypes = serviceAssembly.GetTypes()
                .Where(t => t.Name.EndsWith("Service") && t.IsClass && !t.IsAbstract)
                .ToList();

            foreach (var serviceType in serviceTypes)
            {
                var interfaceType = serviceType.GetInterfaces().FirstOrDefault();
                if (interfaceType != null)
                {
                    services.AddTransient(interfaceType, serviceType);
                }
            }
        }
    }
}
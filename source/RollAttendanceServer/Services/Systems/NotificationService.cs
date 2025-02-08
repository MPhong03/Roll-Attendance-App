using System.Net.Http.Headers;
using System.Text;
using Google.Apis.Auth.OAuth2;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json;
using RollAttendanceServer.Data;
using RollAttendanceServer.Interfaces;

namespace RollAttendanceServer.Services.Systems
{
    public class NotificationService : INotificationService
    {
        private readonly IConfiguration _configuration;
        private readonly ApplicationDbContext _context;
        private readonly HttpClient _httpClient;
        private readonly string _projectId;
        private readonly string _credentialsPath;

        public NotificationService(ApplicationDbContext context, IConfiguration configuration)
        {
            _configuration = configuration;
            _context = context;
            _httpClient = new HttpClient();
            _projectId = configuration["Firebase:ProjectId"];
            _credentialsPath = configuration["Firebase:CredentialsPath"];
        }

        private async Task<string> GetAccessTokenAsync()
        {
            GoogleCredential credential;
            using (var stream = new FileStream(_credentialsPath, FileMode.Open, FileAccess.Read))
            {
                credential = GoogleCredential.FromStream(stream)
                    .CreateScoped(new[] { "https://www.googleapis.com/auth/firebase.messaging" });
            }

            var token = await credential.UnderlyingCredential.GetAccessTokenForRequestAsync();
            return token;
        }

        public async Task<bool> SendNotificationAsync(string userId, string title, string body, string? image = null, string? route = null)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null || string.IsNullOrEmpty(user.FCMToken))
            {
                return false;
            }

            var accessToken = await GetAccessTokenAsync();
            var requestUri = $"https://fcm.googleapis.com/v1/projects/{_projectId}/messages:send";

            var payload = new
            {
                message = new
                {
                    token = user.FCMToken,
                    notification = new
                    {
                        title = title,
                        body = body,
                        image = image
                    },
                    data = new
                    {
                        route = route
                    }
                }
            };

            var jsonPayload = JsonConvert.SerializeObject(payload);
            var requestContent = new StringContent(jsonPayload, Encoding.UTF8, "application/json");

            _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);

            var response = await _httpClient.PostAsync(requestUri, requestContent);
            return response.IsSuccessStatusCode;
        }

        public async Task<bool> SendAndSaveNotificationAsync(string userId, string title, string body, string? image = null, string? route = null)
        {
            var result = await SendNotificationAsync(userId, title, body, image, route);
            if (result)
            {
                var notification = new Models.Notification
                {
                    UserId = userId,
                    FCMToken = (await _context.Users.FindAsync(userId))?.FCMToken,
                    Title = title,
                    Body = body,
                    Image = image,
                    Route = route
                };

                _context.Notifications.Add(notification);
                await _context.SaveChangesAsync();
            }

            return result;
        }

        public async Task<int> SendNotificationToAllAsync(string title, string body, string? image = null, string? route = null)
        {
            var users = await _context.Users
                .Where(u => !string.IsNullOrEmpty(u.FCMToken))
                .ToListAsync();

            if (!users.Any())
            {
                return 0;
            }

            var accessToken = await GetAccessTokenAsync();
            var requestUri = $"https://fcm.googleapis.com/v1/projects/{_projectId}/messages:send";

            int successCount = 0;

            foreach (var user in users)
            {
                var payload = new
                {
                    message = new
                    {
                        token = user.FCMToken,
                        notification = new
                        {
                            title = title,
                            body = body,
                            image = image
                        },
                        data = new
                        {
                            route = route
                        }
                    }
                };

                var jsonPayload = JsonConvert.SerializeObject(payload);
                var requestContent = new StringContent(jsonPayload, Encoding.UTF8, "application/json");

                _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);

                var response = await _httpClient.PostAsync(requestUri, requestContent);

                if (response.IsSuccessStatusCode)
                {
                    successCount++;
                }
            }

            return successCount;
        }

    }
}

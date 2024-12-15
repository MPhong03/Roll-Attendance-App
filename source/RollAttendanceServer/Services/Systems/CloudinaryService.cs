using CloudinaryDotNet.Actions;
using CloudinaryDotNet;
using RollAttendanceServer.Interfaces;

namespace RollAttendanceServer.Services.Systems
{
    public class CloudinaryService : ICloudinaryService
    {
        private readonly Cloudinary _cloudinary;

        public CloudinaryService(IConfiguration configuration)
        {
            var cloudName = configuration["Cloudinary:CloudName"];
            var apiKey = configuration["Cloudinary:ApiKey"];
            var apiSecret = configuration["Cloudinary:ApiSecret"];

            var account = new Account(cloudName, apiKey, apiSecret);
            _cloudinary = new Cloudinary(account);
        }

        public async Task<string> UploadImageAsync(Stream imageStream, string fileName, string id, string folder)
        {
            string timestamp = DateTime.UtcNow.Ticks.ToString();
            var uploadParams = new ImageUploadParams
            {
                File = new FileDescription(fileName, imageStream),
                PublicId = $"{folder}/{id}_{timestamp}",
                Overwrite = true
            };

            var uploadResult = await _cloudinary.UploadAsync(uploadParams);

            if (uploadResult.StatusCode == System.Net.HttpStatusCode.OK)
            {
                return uploadResult.SecureUrl.ToString();
            }
            else
            {
                throw new Exception("Image upload failed");
            }
        }
    }
}

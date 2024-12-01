using CloudinaryDotNet.Actions;
using CloudinaryDotNet;

namespace RollAttendanceServer.Services
{
    public class CloudinaryService
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

        public async Task<string> UploadImageAsync(Stream imageStream, string fileName, string uid)
        {
            try
            {
                string timestamp = DateTime.UtcNow.Ticks.ToString();
                var uploadParams = new ImageUploadParams()
                {
                    File = new FileDescription(fileName, imageStream),
                    PublicId = $"users/{uid}_{timestamp}",
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
            catch (Exception ex)
            {
                throw new Exception($"Error uploading image: {ex.Message}");
            }
        }
    }
}

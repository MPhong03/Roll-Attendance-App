namespace RollAttendanceServer.Interfaces
{
    public interface ICloudinaryService
    {
        Task<string> UploadImageAsync(Stream imageStream, string fileName, string id, string folder);
    }
}

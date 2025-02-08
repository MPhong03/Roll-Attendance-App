namespace RollAttendanceServer.Interfaces
{
    public interface INotificationService
    {
        Task<bool> SendNotificationAsync(string userId, string title, string body, string? image = null, string? route = null);
        Task<bool> SendAndSaveNotificationAsync(string userId, string title, string body, string? image = null, string? route = null);
        Task<int> SendNotificationToAllAsync(string title, string body, string? image = null, string? route = null);
    }
}

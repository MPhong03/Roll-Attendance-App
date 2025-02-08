using RollAttendanceServer.Models;

namespace RollAttendanceServer.Interfaces
{
    public interface IUserService
    {
        Task<bool> IsEmailExistsAsync(string email);
        Task CreateUserAsync(User user);
        Task<User?> GetUserByEmailAsync(string email);
        Task<User?> GetUserByUidAsync(string uid);
        Task UpdateUserFaceData(string id, string faceData);
        Task UpdateUserAsync(User user);
        Task<string> GetUserFCMTokenAsync(string userId);
        Task UpdateUserFCMTokenAsync(string userId, string token);
    }
}

using RollAttendanceServer.Models;

namespace RollAttendanceServer.Interfaces
{
    public interface IUserService
    {
        Task<bool> IsEmailExistsAsync(string email);
        Task CreateUserAsync(User user);
        Task<User?> GetUserByEmailAsync(string email);
        Task<User?> GetUserByUidAsync(string uid);
    }
}

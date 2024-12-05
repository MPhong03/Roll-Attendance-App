using RollAttendanceServer.Models;

namespace RollAttendanceServer.Interfaces
{
    public interface IJwtService
    {
        string GenerateAccessToken(User user);
        string GenerateRefreshToken();
    }
}

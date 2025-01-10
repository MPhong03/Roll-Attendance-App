using RollAttendanceServer.Data.Enum;

namespace RollAttendanceServer.Data.Requests
{
    public class AddToRoleRequest
    {
        public string? UserId { get; set; }
        public UserRole Role { get; set; }
    }
}

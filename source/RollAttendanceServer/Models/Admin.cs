using System.Data;

namespace RollAttendanceServer.Models
{
    public class Admin
    {
        public int Id { get; set; }
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string Phone { get; set; } = string.Empty;
        public int RoleId { get; set; }
        public Role Role { get; set; } = new Role();
    }
}

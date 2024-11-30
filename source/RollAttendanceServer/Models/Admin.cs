using RollAttendanceServer.Models.Common;
using System.ComponentModel.DataAnnotations;
using System.Data;

namespace RollAttendanceServer.Models
{
    public class Admin : BaseEntity
    {
        [Key]
        public string Id { get; set; } = Guid.NewGuid().ToString("N").ToString().ToUpper();
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string Phone { get; set; } = string.Empty;
        public string RoleId { get; set; } = string.Empty;
        public Role Role { get; set; }
    }
}

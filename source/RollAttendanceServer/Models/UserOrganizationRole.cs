using RollAttendanceServer.Data.Enum;
using RollAttendanceServer.Models.Common;

namespace RollAttendanceServer.Models
{
    public class UserOrganizationRole : BaseEntity
    {
        public string? UserId { get; set; }
        public User? User { get; set; }

        public string? OrganizationId { get; set; }
        public Organization? Organization { get; set; }

        public UserRole Role { get; set; }  // 'Representative', 'Organizer', 'User'
    }
}

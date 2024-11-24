using RollAttendanceServer.Models.Common;
using System.ComponentModel.DataAnnotations;

namespace RollAttendanceServer.Models
{
    public class Role : BaseEntity
    {
        [Key]
        public string Id { get; set; } = Guid.NewGuid().ToString("N").ToString().ToUpper();
        public string RoleName { get; set; } = string.Empty;
        public ICollection<Permission> Permissions { get; set; } = new HashSet<Permission>();
    }
}

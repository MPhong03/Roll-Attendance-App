using RollAttendanceServer.Models.Common;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace RollAttendanceServer.Models
{
    public class Role : BaseEntity
    {
        [Key]
        public string Id { get; set; } = Guid.NewGuid().ToString("N").ToString().ToUpper();
        public string RoleName { get; set; } = string.Empty;
        [JsonIgnore]
        public ICollection<Permission> Permissions { get; set; } = new HashSet<Permission>();
    }
}

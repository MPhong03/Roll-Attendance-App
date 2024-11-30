using RollAttendanceServer.Models.Common;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace RollAttendanceServer.Models
{
    public class Organization : BaseEntity
    {
        [Key]
        public string Id { get; set; } = Guid.NewGuid().ToString("N").ToString().ToUpper();
        public string? Name { get; set; }
        public string? Description { get; set; }
        public string Address { get; set; } = string.Empty;
        public bool IsPrivate { get; set; } = false;

        [JsonIgnore]
        public ICollection<UserOrganizationRole> UserOrganizationRoles { get; set; } = new List<UserOrganizationRole>();
    }
}

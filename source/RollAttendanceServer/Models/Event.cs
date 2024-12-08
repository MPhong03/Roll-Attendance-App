using RollAttendanceServer.Data.Enum;
using RollAttendanceServer.Models.Common;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace RollAttendanceServer.Models
{
    public class Event : BaseEntity
    {
        [Key]
        public string Id { get; set; } = Guid.NewGuid().ToString("N").ToString().ToUpper();
        public string? Name { get; set; }
        public string? Description { get; set; }
        public DateTime? StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public string CurrentLocation { get; set; } = string.Empty;
        public decimal CurrentLocationRadius { get; set; }
        public string CurrentQR { get; set; } = string.Empty;
        public short EventStatus { get; set; } = (short)Status.EVENT_NOT_STARTED;
        public string OrganizerId { get; set; } = string.Empty;
        public string? OrganizationId { get; set; }
        public Organization? Organization { get; set; }
        public bool IsPrivate { get; set; } = false;
        [JsonIgnore]
        public ICollection<User> PermitedUser { get; set; } = new List<User>();
        [JsonIgnore]
        public ICollection<History> Histories { get; set; } = new List<History>();
    }
}

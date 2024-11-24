using RollAttendanceServer.Models.Common;
using System.ComponentModel.DataAnnotations;

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
        public ICollection<User> PermitedUser { get; set; } = new List<User>();
    }
}

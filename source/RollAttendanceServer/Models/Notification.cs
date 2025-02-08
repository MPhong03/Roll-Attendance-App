using System.ComponentModel.DataAnnotations;
using RollAttendanceServer.Models.Common;

namespace RollAttendanceServer.Models
{
    public class Notification : BaseEntity
    {
        [Key]
        public string Id { get; set; } = Guid.NewGuid().ToString("N").ToString().ToUpper();
        public string? UserId { get; set; }
        public string? FCMToken { get; set; }
        public string? Image { get; set; }
        public string? Title { get; set; }
        public string? Body { get; set; }
        public string? Route { get; set; }
    }
}

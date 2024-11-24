using RollAttendanceServer.Models.Common;
using System.ComponentModel.DataAnnotations;

namespace RollAttendanceServer.Models
{
    public class User : BaseEntity
    {
        [Key]
        public string Id { get; set; } = Guid.NewGuid().ToString("N").ToString().ToUpper();
        public string? Email { get; set; }
        public string Uid { get; set; } = string.Empty;
        public string FaceData { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public string Gender { get; set; } = string.Empty;
    }
}

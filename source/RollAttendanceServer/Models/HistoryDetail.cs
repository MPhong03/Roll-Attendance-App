using RollAttendanceServer.Data.Enum;
using RollAttendanceServer.Models.Common;
using System.ComponentModel.DataAnnotations;

namespace RollAttendanceServer.Models
{
    public class HistoryDetail : BaseEntity
    {
        [Key]
        public string Id { get; set; } = Guid.NewGuid().ToString("N").ToString().ToUpper();
        public string UserId { get; set; } = string.Empty;
        public string UserName { get; set; } = string.Empty;
        public string UserEmail { get; set; } = string.Empty;
        public string UserAvatar { get; set; } = string.Empty;
        public DateTime? AbsentTime { get; set; }
        public DateTime? LeaveTime { get; set; }
        public int AttendanceCount { get; set; }
        public short AttendanceStatus { get; set; } = (short)Status.USER_PRESENTED;
        public string? HistoryId { get; set; }
        public History? History { get; set; }
    }
}

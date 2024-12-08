using Newtonsoft.Json;
using RollAttendanceServer.Models.Common;
using System.ComponentModel.DataAnnotations;

namespace RollAttendanceServer.Models
{
    public class History : BaseEntity
    {
        [Key]
        public string Id { get; set; } = Guid.NewGuid().ToString("N").ToString().ToUpper();
        public DateTime? OccurDate { get; set; } = DateTime.Now;
        public DateTime? StartTime { get; set; } = DateTime.Now;
        public DateTime? EndTime { get; set; } = DateTime.Now;
        public int TotalCount { get; set; }
        public int PresentCount { get; set; }
        public int LateCount { get; set; }
        public int AttendanceTimes { get; set; }
        public string EventId { get; set; } = string.Empty;
        [JsonIgnore]
        public ICollection<HistoryDetail> HistoryDetails { get; set; } = new List<HistoryDetail>();
    }
}

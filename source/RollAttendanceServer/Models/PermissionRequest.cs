using RollAttendanceServer.Data.Enum;
using RollAttendanceServer.Models.Common;
using System.ComponentModel.DataAnnotations;

namespace RollAttendanceServer.Models
{
    public class PermissionRequest : BaseEntity
    {
        [Key]
        public string Id { get; set; } = Guid.NewGuid().ToString("N").ToString().ToUpper();
        public string? UserId { get; set; }
        public string? UserName { get; set; }
        public string? UserEmail { get; set; }
        public string? UserAvatar { get; set; }
        public string? OrganizationId { get; set; }
        public string? OrganizationName { get; set; }
        public string? EventId { get; set; }
        public string? EventName { get; set; }
        public string? Notes { get; set; }
        public bool IsUsed { get; set; } = false;
        public short RequestType { get; set; } = (short)Status.ABSENT_REQUEST;
        public short RequestStatus { get; set; } = (short)Status.REQUEST_WAITING;
    }
}

using RollAttendanceServer.Data.Enum;
using RollAttendanceServer.Models.Common;
using System.ComponentModel.DataAnnotations;

namespace RollAttendanceServer.Models
{
    public class ParticipationRequest : BaseEntity
    {
        [Key]
        public string Id { get; set; } = Guid.NewGuid().ToString("N").ToString().ToUpper();
        public string? UserId { get; set; }
        public string? UserName { get; set; }
        public string? UserEmail { get; set; }
        public string? OrganizationId { get; set; }
        public string? OrganizationName { get; set; }
        public string? ParticipationMethod { get; set; }
        public short RequestStatus { get; set; } = (short)Status.REQUEST_WAITING;
    }
}

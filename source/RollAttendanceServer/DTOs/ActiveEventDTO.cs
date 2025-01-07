using RollAttendanceServer.Data.Enum;
using RollAttendanceServer.Models;
using System.ComponentModel.DataAnnotations;

namespace RollAttendanceServer.DTOs
{
    public class ActiveEventDTO
    {
        public string? Id { get; set; }
        public string? Name { get; set; }
        public string? Description { get; set; }
        public DateTime? StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public string? CurrentLocation { get; set; }
        public decimal CurrentLocationRadius { get; set; }
        public string? CurrentQR { get; set; }
        public short EventStatus { get; set; }

        // ORGANIZER
        public string? OrganizerId { get; set; }
        public string? OrganizerName { get; set; }
        public string? OrganizerEmail { get; set; }
        public string? OrganizerAvatar { get; set; }

        // ORGANIZATION
        public string? OrganizationId { get; set; }
        public string? OrganizationName { get; set; }
        public string? OrganizationImage { get; set; }

        // ATTENDANCE
        public bool IsCheckInYet { get; set; } = false;
        public short AttendanceStatus { get; set; }
        public int AttendanceTimes { get; set; }

        public bool IsPrivate { get; set; }
    }
}

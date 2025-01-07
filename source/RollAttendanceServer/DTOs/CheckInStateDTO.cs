namespace RollAttendanceServer.DTOs
{
    public class CheckInStateDTO
    {
        public string? UserId { get; set; }
        public string? DisplayName { get; set; }
        public string? Email { get; set; }
        public string? Avatar { get; set; }

        public bool IsCheckInYet { get; set; } = false;
        public short AttendanceStatus { get; set; }
        public int AttendanceCount { get; set; }

        public string? EventId { get; set; }
    }
}

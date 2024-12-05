namespace RollAttendanceServer.DTOs
{
    public class EventDTO
    {
        public string? Name { get; set; }
        public string? Description { get; set; }
        public DateTime? StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public string CurrentLocation { get; set; } = string.Empty;
        public decimal CurrentLocationRadius { get; set; }
        public string CurrentQR { get; set; } = string.Empty;
        public short EventStatus { get; set; }
        public string? OrganizationId { get; set; }
    }

}

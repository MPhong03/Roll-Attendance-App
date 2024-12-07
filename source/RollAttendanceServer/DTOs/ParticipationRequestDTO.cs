namespace RollAttendanceServer.DTOs
{
    public class ParticipationRequestDTO
    {
        public string? UserId { get; set; }
        public string? UserName { get; set; }
        public string? UserEmail { get; set; }
        public string? OrganizationId { get; set; }
        public string? OrganizationName { get; set; }
        public string? ParticipationMethod { get; set; }
    }
}

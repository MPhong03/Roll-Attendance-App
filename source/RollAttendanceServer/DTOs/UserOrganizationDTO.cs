namespace RollAttendanceServer.DTOs
{
    public class UserOrganizationDTO
    {
        public string? Id { get; set; }
        public string? Uid { get; set; }
        public string? Email { get; set; }
        public string? DisplayName { get; set; }
        public string? PhoneNumber { get; set; }
        public string? Avatar { get; set; }
        public int? Role { get; set; }
    }
}

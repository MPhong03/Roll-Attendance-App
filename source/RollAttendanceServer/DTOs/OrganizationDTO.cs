namespace RollAttendanceServer.DTOs
{
    public class OrganizationDTO
    {
        public string? Name { get; set; }
        public string? Description { get; set; }
        public string? Address { get; set; } 
        public string? UserId { get; set; } // Firebase Uid
        public bool? IsPrivate { get; set; }
    }
}

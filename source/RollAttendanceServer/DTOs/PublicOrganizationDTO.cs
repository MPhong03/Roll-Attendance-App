namespace RollAttendanceServer.DTOs
{
    public class PublicOrganizationDTO
    {
        public string? Id { get; set; }
        public string? Name { get; set; }
        public string? Description { get; set; }
        public string? Address { get; set; }
        public bool IsPrivate { get; set; } = false;

        public string? Banner { get; set; }
        public string? Image { get; set; }

        public int Users { get; set; } = 0;
        public int Events { get; set; } = 0;
    }
}

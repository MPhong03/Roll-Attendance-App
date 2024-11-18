namespace RollAttendanceServer.Models
{
    public class User
    {
        public int Id { get; set; }
        public string? Email { get; set; }
        public string Uid { get; set; } = string.Empty;
        public string FaceData { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public string Gender { get; set; } = string.Empty;
    }
}

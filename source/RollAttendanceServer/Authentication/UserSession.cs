namespace RollAttendanceServer.Authentication
{
    public class UserSession
    {
        public string Email { get; set; } = string.Empty;
        public string RoleId { get; set; } = string.Empty;
        public ICollection<string> Permissions { get; set; } = new List<string>();
    }
}

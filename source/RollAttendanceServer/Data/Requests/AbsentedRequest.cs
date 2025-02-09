namespace RollAttendanceServer.Data.Requests
{
    public class AbsentedRequest
    {
        public string? Notes { get; set; }
        public int Type { get; set; } = 0;
    }
}

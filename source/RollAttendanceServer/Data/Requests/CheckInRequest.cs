namespace RollAttendanceServer.Data.Requests
{
    public class CheckInRequest
    {
        public string? UserId { get; set; }
        public string? QrCode { get; set; }
        public int AttendanceAttempt { get; set; }
    }
}

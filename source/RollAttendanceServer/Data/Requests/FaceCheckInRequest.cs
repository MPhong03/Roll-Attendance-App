namespace RollAttendanceServer.Data.Requests
{
    public class FaceCheckInRequest
    {
        public string? UserId { get; set; }
        public string? FaceData { get; set; }
        public int AttendanceAttempt { get; set; }
    }
}

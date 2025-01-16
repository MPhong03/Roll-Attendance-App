namespace RollAttendanceServer.DTOs
{
	public class BiometricCheckInResultDTO
	{
        public string? UserId { get; set; }
        public string? Email { get; set; }
        public string? Name { get; set; }
        public string? EventId { get; set; }
		public string? Method { get; set; } = "FACE_DETECTION";
        public double? Prediction { get; set; }
    }
}

namespace RollAttendanceServer.Data.Requests
{
    public class SetLocationRequest
    {
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public decimal Radius { get; set; }
    }
}

namespace RollAttendanceServer.Interfaces
{
    public interface IFaceRecognitionService
    {
        Task<float[]> ExtractFeatureAsync(float[] image);
    }
}

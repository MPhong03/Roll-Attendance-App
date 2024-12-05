namespace RollAttendanceServer.Services.Configs
{
    public class LoadingService
    {
        public event Action<bool> OnChange;

        public void Show()
        {
            OnChange?.Invoke(true);
        }

        public void Hide()
        {
            OnChange?.Invoke(false);
        }
    }
}

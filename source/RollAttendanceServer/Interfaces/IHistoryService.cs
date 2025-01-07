using RollAttendanceServer.Models;

namespace RollAttendanceServer.Interfaces
{
    public interface IHistoryService
    {
        Task<History?> GetHistoryByEventIdAsync(string eventId);
        Task<IEnumerable<HistoryDetail>> GetHistoryDetailsByHistoryIdAsync(string historyId, int pageIndex, int pageSize, string keyword);
    }
}

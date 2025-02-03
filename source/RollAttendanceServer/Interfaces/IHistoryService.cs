using RollAttendanceServer.Models;

namespace RollAttendanceServer.Interfaces
{
    public interface IHistoryService
    {
        Task<List<History>> GetHistoriesByEventIdAsync(string eventId);
        Task<IEnumerable<HistoryDetail>> GetHistoryDetailsByHistoryIdAsync(string historyId, int pageIndex, int pageSize, string keyword);
    }
}

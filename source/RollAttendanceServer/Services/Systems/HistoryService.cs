using Microsoft.EntityFrameworkCore;
using RollAttendanceServer.Data;
using RollAttendanceServer.Interfaces;
using RollAttendanceServer.Models;

namespace RollAttendanceServer.Services.Systems
{
    public class HistoryService : IHistoryService
    {
        private readonly ApplicationDbContext _context;

        public HistoryService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<History?> GetHistoryByEventIdAsync(string eventId)
        {
            var history = await _context.Histories
                                        .Where(h => h.EventId == eventId)
                                        .FirstOrDefaultAsync();
            return history;
        }

        public async Task<IEnumerable<HistoryDetail>> GetHistoryDetailsByHistoryIdAsync(
            string historyId,
            int pageIndex,
            int pageSize,
            string? keyword = null)
        {
            var query = _context.HistoryDetails
                .Where(hd => hd.HistoryId == historyId);

            if (!string.IsNullOrEmpty(keyword))
            {
                query = query.Where(hd =>
                    hd.UserName.Contains(keyword) ||
                    hd.UserEmail.Contains(keyword));
            }

            var paginatedDetails = await query
                .Skip((pageIndex - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return paginatedDetails;
        }

    }
}

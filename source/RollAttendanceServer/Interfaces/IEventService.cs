using RollAttendanceServer.DTOs;
using RollAttendanceServer.Models;

namespace RollAttendanceServer.Interfaces
{
    public interface IEventService
    {
        Task<Event> Create(EventDTO eventDto, string organizerId);
        Task<Event> Update(string eventId, EventDTO eventDto, string organizerId);
        Task<Event?> GetEventByIdAsync(string eventId);
        Task<bool> AddUsersToPermitedUserAsync(string eventId, List<string> userIds);
        Task<IEnumerable<Event>> GetEventsByOrganizationAsync(string organizationId, string keyword, DateTime? startDate, DateTime? endDate, int pageIndex, int pageSize);
    }
}

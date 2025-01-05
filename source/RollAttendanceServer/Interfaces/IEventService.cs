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
        Task<IEnumerable<ActiveEventDTO>> GetUserActiveEvents(string userId, DateTime? date, short status, int pageIndex, int pageSize);

        // CHECK IN MODULE
        Task<Event> ActivateEventAsync(string eventId);
        Task CheckInAsync(string eventId, string userId, string qrCode, int attendanceAttempt);
        Task AddAttendanceAttemptAsync(string eventId);
        Task<Event> CompleteEventAsync(string eventId);
        Task<IEnumerable<UserDTO>> GetEventUsersAsync(string eventId);
    }
}

using RollAttendanceServer.Data.Responses;
using RollAttendanceServer.DTOs;
using RollAttendanceServer.Models;

namespace RollAttendanceServer.Interfaces
{
    public interface IEventService
    {
        bool IsAdmin { get; set; }
        Task<Event> Create(EventDTO eventDto, string organizerId);
        Task<Event> Update(string eventId, EventDTO eventDto, string organizerId);
        Task<Event?> GetEventByIdAsync(string eventId);
        Task<bool> AddUsersToPermitedUserAsync(string eventId, List<string> userIds);
        Task<IEnumerable<Event>> GetEventsByOrganizationAsync(string organizationId, string keyword, DateTime? startDate, DateTime? endDate, int pageIndex, int pageSize);
        Task<IEnumerable<ActiveEventDTO>> GetUserActiveEvents(string userId, DateTime? startDate, DateTime? endDate, short status, int pageIndex, int pageSize);
        Task DeleteEventAsync(string id);
        Task CancelEventAsync(string id);

        // CHECK IN MODULE
        Task<Event> ActivateEventAsync(string eventId);
        Task CheckInAsync(string eventId, string userId, string qrCode, int attendanceAttempt);
        Task AddAttendanceAttemptAsync(string eventId);
        Task<Event> CompleteEventAsync(string eventId);
        Task<IEnumerable<UserDTO>> GetEventUsersAsync(string eventId);

        // FACE CHECKIN
        Task<BiometricCheckInResultDTO> FaceCheckIn(string eventId, string faceData, int attendanceAttempt);

        // GEOGRAPHY CHECKIN
        Task<Event> ActivateGeographyCheckIn(string eventId, double lat, double lon, decimal radius);
        Task<BiometricCheckInResultDTO> GeographyCheckIn(string eventId, string userId, double lat, double lon, int attendanceAttempt);

        // REQUEST
        Task<PermissionRequest> SendRequest(string eventId, string userId, string notes, short type);
        Task<PermissionRequest> UpdateRequestStatusAsync(string requestId, short status);
        Task<PagedResult<PermissionRequest>> GetEventRequests(string eventId, string userId, string keyword, short type, short status, DateTime? startDate, DateTime? endDate, int pageIndex, int pageSize);

    }
}

using RollAttendanceServer.Data.Responses;
using RollAttendanceServer.Models;

namespace RollAttendanceServer.Interfaces
{
    public interface IParticipationRequestService
    {
        Task<PagedResult<ParticipationRequest>> GetParticipationRequestsAsync(string userId, string organizationId, string keyword, int pageIndex, int pageSize);
        Task<string> CreateParticipationRequestAsync(string userId, string organizationId, string notes);
        Task ApproveOrRejectRequestAsync(string requestId, short newStatus);
        Task CancelRequestAsync(string requestId, string userId);
    }
}

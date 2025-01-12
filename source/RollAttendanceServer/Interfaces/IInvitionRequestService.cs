using RollAttendanceServer.Data.Responses;
using RollAttendanceServer.Models;

namespace RollAttendanceServer.Interfaces
{
    public interface IInvitionRequestService
    {
        Task<PagedResult<InviteRequest>> GetInviteRequestsAsync(string userId, string organizationId, string keyword, int status, int pageIndex, int pageSize, bool forUser = true);
        Task InviteUsersAsync(string organizationId, List<InviteRequest> inviteRequests);
        Task UpdateInvitationStatusAsync(string invitationId, short status);
    }
}

namespace RollAttendanceServer.Interfaces
{
    public interface IParticipationRequestService
    {
        Task<string> CreateParticipationRequestAsync(string userId, string organizationId);
        Task ApproveOrRejectRequestAsync(string requestId, short newStatus);
        Task CancelRequestAsync(string requestId, string userId);
    }
}

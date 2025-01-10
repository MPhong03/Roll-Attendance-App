namespace RollAttendanceServer.Interfaces
{
    public interface IParticipationRequestService
    {
        Task<string> CreateParticipationRequestAsync(string userId, string organizationId, string notes);
        Task ApproveOrRejectRequestAsync(string requestId, short newStatus);
        Task CancelRequestAsync(string requestId, string userId);
    }
}

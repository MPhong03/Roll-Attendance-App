using RollAttendanceServer.Data.Enum;
using RollAttendanceServer.Data.Requests;
using RollAttendanceServer.DTOs;
using RollAttendanceServer.Models;

namespace RollAttendanceServer.Interfaces
{
    public interface IOrganizationService
    {
        Task<IEnumerable<Organization>> GetAll(string? keyword, int pageIndex = 0, int pageSize = 10);
        Task<IEnumerable<string>> SuggestOrganizationNamesAsync(string keyword, int maxSuggestions = 10);
        Task<IEnumerable<PublicOrganizationDTO>> SearchOrganizationsAsync(string? keyword, int pageIndex = 0, int pageSize = 10);
        Task<IEnumerable<Organization?>> GetOrganizationsByUserAsync(string uid, UserRole role, string? keyword, int pageIndex = 0, int pageSize = 10);
        Task<Organization?> GetOrganizationByIdAsync(string id);
        Task<Organization> CreateOrganizationAsync(OrganizationDTO dto, Stream bannerStream, Stream imageStream);
        Task<Organization> UpdateOrganizationAsync(string organizationId, OrganizationDTO dto, Stream? bannerStream, Stream? imageStream);
        Task AddUserToRoleAsync(string organizationId, AddToRoleRequest request);
        Task AddUsersAsync(string organizationId, List<AddToRoleRequest> requests);
        Task RemoveUsersAsync(string organizationId, RemoveUsersRequest request);
        Task DeleteOrganizationAsync(string id);
        Task<IEnumerable<UserOrganizationDTO?>> GetOrganizationUsersAsync(string id, string keyword, int pageIndex, int pageSize);
    }
}

using RollAttendanceServer.Data.Enum;
using RollAttendanceServer.DTOs;
using RollAttendanceServer.Models;
using RollAttendanceServer.Requests;

namespace RollAttendanceServer.Interfaces
{
    public interface IOrganizationService
    {
        Task<IEnumerable<Organization?>> GetOrganizationsByUserAsync(string uid, UserRole role, string? keyword, int pageIndex = 0, int pageSize = 10);
        Task<Organization?> GetOrganizationByIdAsync(string id);
        Task<Organization> CreateOrganizationAsync(OrganizationDTO dto, Stream bannerStream, Stream imageStream);
        Task<Organization> UpdateOrganizationAsync(string organizationId, OrganizationDTO dto, Stream? bannerStream, Stream? imageStream);
        Task AddUserToRoleAsync(string organizationId, AddToRoleRequest request);
        Task DeleteOrganizationAsync(string id);
        Task<IEnumerable<UserOrganizationDTO?>> GetOrganizationUsersAsync(string id, string keyword, int pageIndex, int pageSize);
    }
}

using RollAttendanceServer.Data.Enum;
using RollAttendanceServer.DTOs;
using RollAttendanceServer.Models;
using RollAttendanceServer.Requests;

namespace RollAttendanceServer.Interfaces
{
    public interface IOrganizationService
    {
        Task<IEnumerable<Organization?>> GetOrganizationsByUserAsync(string uid, UserRole role);
        Task<Organization?> GetOrganizationByIdAsync(string id);
        Task<Organization> CreateOrganizationAsync(OrganizationDTO dto);
        Task<Organization> UpdateOrganizationAsync(string id, OrganizationDTO dto);
        Task AddUserToRoleAsync(string organizationId, AddToRoleRequest request);
        Task DeleteOrganizationAsync(string id);
        Task<IEnumerable<User?>> GetOrganizationUsersAsync(string id, string keyword, int pageIndex, int pageSize);
    }
}

using RollAttendanceServer.Models;

namespace RollAttendanceServer.Interfaces
{
    public interface IRoleService
    {
        Task<IEnumerable<Role>> GetAllRolesAsync();
    }
}

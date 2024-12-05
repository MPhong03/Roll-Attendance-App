using Microsoft.EntityFrameworkCore;
using RollAttendanceServer.Data;
using RollAttendanceServer.Interfaces;
using RollAttendanceServer.Models;

namespace RollAttendanceServer.Services.Systems
{
    public class RoleService : IRoleService
    {
        private readonly ApplicationDbContext _context;

        public RoleService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Role>> GetAllRolesAsync()
        {
            return await _context.Roles.Include(r => r.Permissions).ToListAsync();
        }
    }
}

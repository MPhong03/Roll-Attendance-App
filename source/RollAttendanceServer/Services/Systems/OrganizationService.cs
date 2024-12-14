using RollAttendanceServer.Data.Enum;
using RollAttendanceServer.Data;
using RollAttendanceServer.DTOs;
using RollAttendanceServer.Interfaces;
using RollAttendanceServer.Models;
using RollAttendanceServer.Requests;
using Microsoft.EntityFrameworkCore;

namespace RollAttendanceServer.Services.Systems
{
    public class OrganizationService : IOrganizationService
    {
        private readonly ApplicationDbContext _context;

        public OrganizationService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Organization?>> GetOrganizationsByUserAsync(string uid, UserRole role)
        {
            return await _context.UserOrganizationRoles
                .Where(uor => uor.User.Uid == uid && uor.Role == role)
                .Select(uor => uor.Organization)
                .ToListAsync();
        }

        public async Task<Organization?> GetOrganizationByIdAsync(string id)
        {
            return await _context.Organizations
                .FirstOrDefaultAsync(org => org.Id == id && !org.IsDeleted);
        }

        public async Task<Organization> CreateOrganizationAsync(OrganizationDTO dto)
        {
            var organization = new Organization
            {
                Id = Guid.NewGuid().ToString("N").ToUpper(),
                Name = dto.Name,
                Description = dto.Description,
                Address = dto.Address ?? string.Empty,
                IsPrivate = dto.IsPrivate ?? false,
                IsDeleted = false
            };

            _context.Organizations.Add(organization);
            await _context.SaveChangesAsync();

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Uid == dto.UserId);
            if (user != null)
            {
                var userRole = new UserOrganizationRole
                {
                    UserId = user.Id,
                    OrganizationId = organization.Id,
                    Role = UserRole.REPRESENTATIVE
                };

                _context.UserOrganizationRoles.Add(userRole);
                await _context.SaveChangesAsync();
            }

            return organization;
        }

        public async Task<Organization> UpdateOrganizationAsync(string id, OrganizationDTO dto)
        {
            var organization = await _context.Organizations
                .FirstOrDefaultAsync(o => o.Id == id && !o.IsDeleted);

            if (organization == null) throw new Exception("Organization not found");

            organization.Name = dto.Name ?? organization.Name;
            organization.Description = dto.Description ?? organization.Description;
            organization.Address = dto.Address ?? organization.Address;

            await _context.SaveChangesAsync();
            return organization;
        }

        public async Task AddUserToRoleAsync(string organizationId, AddToRoleRequest request)
        {
            var organization = await _context.Organizations
                .FirstOrDefaultAsync(o => o.Id == organizationId && !o.IsDeleted);

            if (organization == null) throw new Exception("Organization not found");

            var user = await _context.Users.FirstOrDefaultAsync(u => u.Uid == request.UserId);
            if (user == null) throw new Exception("User not found");

            var existingRole = await _context.UserOrganizationRoles
                .FirstOrDefaultAsync(uor => uor.UserId == user.Id && uor.OrganizationId == organizationId);

            if (existingRole != null) throw new Exception("User already has a role in this organization.");

            var userRole = new UserOrganizationRole
            {
                UserId = user.Id,
                OrganizationId = organization.Id,
                Role = request.Role
            };

            _context.UserOrganizationRoles.Add(userRole);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteOrganizationAsync(string id)
        {
            var organization = await _context.Organizations.FindAsync(id);
            if (organization == null) throw new Exception("Organization not found");

            organization.IsDeleted = true;
            await _context.SaveChangesAsync();
        }

        public async Task<IEnumerable<User?>> GetOrganizationUsersAsync(string id, string keyword, int pageIndex, int pageSize)
        {
            var query = _context.UserOrganizationRoles.AsQueryable();

            query = query.Where(e => e.OrganizationId == id);

            if (!string.IsNullOrEmpty(keyword))
            {
                query = query.Where(e => e.User.Email.Contains(keyword));
            }

            query = query.Skip((pageIndex - 1) * pageSize).Take(pageSize);

            return await query.Select(uor => uor.User).ToListAsync();
        }
    }
}

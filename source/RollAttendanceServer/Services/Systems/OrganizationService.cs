using RollAttendanceServer.Data.Enum;
using RollAttendanceServer.Data;
using RollAttendanceServer.DTOs;
using RollAttendanceServer.Interfaces;
using RollAttendanceServer.Models;
using RollAttendanceServer.Requests;
using Microsoft.EntityFrameworkCore;
using Google.Api.Gax.ResourceNames;

namespace RollAttendanceServer.Services.Systems
{
    public class OrganizationService : IOrganizationService
    {
        private readonly ApplicationDbContext _context;
        private readonly ICloudinaryService _cloudinaryService;

        public OrganizationService(ApplicationDbContext context, ICloudinaryService cloudinaryService)
        {
            _context = context;
            _cloudinaryService = cloudinaryService;
        }

        public async Task<IEnumerable<PublicOrganizationDTO>> SearchOrganizationsAsync(string? keyword, int pageIndex = 0, int pageSize = 10)
        {
            var query = _context.Organizations
                                .Where(org => !org.IsPrivate && !org.IsDeleted)
                                .AsQueryable();

            if (!string.IsNullOrEmpty(keyword))
            {
                query = query.Where(org => org.Name.Contains(keyword) || org.Description.Contains(keyword));
            }

            var organizations = await query.Skip(pageIndex * pageSize)
                                           .Take(pageSize)
                                           .Select(org => new PublicOrganizationDTO
                                           {
                                               Id = org.Id,
                                               Name = org.Name,
                                               Description = org.Description,
                                               Address = org.Address,
                                               IsPrivate = org.IsPrivate,
                                               Banner = org.Banner,
                                               Image = org.Image,
                                               Users = org.UserOrganizationRoles.Count(),
                                               Events = org.Events.Count()
                                           })
                                           .ToListAsync();

            return organizations;
        }

        public async Task<IEnumerable<string>> SuggestOrganizationNamesAsync(string keyword, int maxSuggestions = 10)
        {
            if (string.IsNullOrWhiteSpace(keyword))
            {
                return Enumerable.Empty<string>();
            }

            var suggestions = await _context.Organizations
                                            .Where(org => !org.IsPrivate && !org.IsDeleted && org.Name.Contains(keyword))
                                            .OrderBy(org => org.Name)
                                            .Select(org => org.Name.ToLower())
                                            .Take(maxSuggestions)
                                            .ToListAsync();

            return suggestions;
        }

        public async Task<IEnumerable<Organization?>> GetOrganizationsByUserAsync(string uid, UserRole role, string? keyword, int pageIndex = 0, int pageSize = 10)
        {
            var query = _context.UserOrganizationRoles
                                .Where(uor => uor.User.Uid == uid && uor.Role == role)
                                .Select(uor => uor.Organization)
                                .AsQueryable();

            // Tìm kiếm theo tên hoặc mô tả
            if (!string.IsNullOrEmpty(keyword))
            {
                query = query.Where(org => org.Name.Contains(keyword) || org.Description.Contains(keyword));
            }

            // Phân trang
            var organizations = await query.Skip(pageIndex * pageSize)
                                           .Take(pageSize)
                                           .ToListAsync();

            return organizations;
        }

        public async Task<Organization?> GetOrganizationByIdAsync(string id)
        {
            return await _context.Organizations
                .FirstOrDefaultAsync(org => org.Id == id && !org.IsDeleted);
        }

        public async Task<Organization> CreateOrganizationAsync(OrganizationDTO dto, Stream bannerStream, Stream imageStream)
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

            string folderName = "organizations";

            if (bannerStream != null)
            {
                organization.Banner = await _cloudinaryService.UploadImageAsync(bannerStream, $"{organization.Id}_{DateTime.UtcNow:yyyyMMddHHmmss}_banner.jpg", organization.Id, folderName);
            }

            if (imageStream != null)
            {
                organization.Image = await _cloudinaryService.UploadImageAsync(imageStream, $"{organization.Id}_{DateTime.UtcNow:yyyyMMddHHmmss}_image.jpg", organization.Id, folderName);
            }

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

        public async Task<Organization> UpdateOrganizationAsync(string organizationId, OrganizationDTO dto, Stream? bannerStream = null, Stream? imageStream = null)
        {
            var organization = await _context.Organizations.FirstOrDefaultAsync(o => o.Id == organizationId);
            if (organization == null)
            {
                throw new Exception("Organization not found");
            }

            string folderName = "organizations";

            organization.Name = dto.Name ?? organization.Name;
            organization.Description = dto.Description ?? organization.Description;
            organization.Address = dto.Address ?? organization.Address;
            organization.IsPrivate = dto.IsPrivate ?? organization.IsPrivate;

            if (bannerStream != null)
            {
                organization.Banner = await _cloudinaryService.UploadImageAsync(bannerStream, $"{organization.Id}_{DateTime.UtcNow:yyyyMMddHHmmss}_banner.jpg", organization.Id, folderName);
            }

            if (imageStream != null)
            {
                organization.Image = await _cloudinaryService.UploadImageAsync(imageStream, $"{organization.Id}_{DateTime.UtcNow:yyyyMMddHHmmss}_image.jpg", organization.Id, folderName);
            }

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

        public async Task<IEnumerable<UserOrganizationDTO?>> GetOrganizationUsersAsync(string id, string keyword, int pageIndex, int pageSize)
        {
            var query = _context.UserOrganizationRoles.AsQueryable();

            query = query.Where(e => e.OrganizationId == id);

            if (!string.IsNullOrEmpty(keyword))
            {
                query = query.Where(e => e.User.Email.Contains(keyword));
            }

            query = query.Skip((pageIndex - 1) * pageSize).Take(pageSize);

            return await query.Select(uor => new UserOrganizationDTO
            {
                Id = uor.User.Id,
                Uid = uor.User.Uid,
                Email = uor.User.Email,
                DisplayName = uor.User.DisplayName,
                PhoneNumber = uor.User.PhoneNumber,
                Avatar = uor.User.Avatar,
                Role = (int)uor.Role
            }).ToListAsync();
        }
    }
}

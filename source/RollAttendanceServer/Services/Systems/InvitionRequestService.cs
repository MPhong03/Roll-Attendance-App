using Google.Api.Gax.ResourceNames;
using Microsoft.EntityFrameworkCore;
using RollAttendanceServer.Controllers;
using RollAttendanceServer.Data;
using RollAttendanceServer.Data.Enum;
using RollAttendanceServer.Data.Responses;
using RollAttendanceServer.Interfaces;
using RollAttendanceServer.Models;

namespace RollAttendanceServer.Services.Systems
{
    public class InvitionRequestService : IInvitionRequestService
    {
        private readonly ApplicationDbContext _context;

        public InvitionRequestService(ApplicationDbContext context)
        {
            _context = context;
        }
        public async Task<PagedResult<InviteRequest>> GetInviteRequestsAsync(
            string userId,
            string organizationId,
            string keyword,
            int status,
            int pageIndex,
            int pageSize,
            bool forUser)
        {
            var query = _context.InviteRequests.AsQueryable();

            if (!string.IsNullOrEmpty(userId) && forUser)
            {
                query = query.Where(r => r.UserId == userId);
            }

            if (!string.IsNullOrEmpty(organizationId))
            {
                query = query.Where(r => r.OrganizationId == organizationId);
            }

            if (status >= 0)
            {
                query = query.Where(r => r.RequestStatus == (short)status);
            }

            if (!string.IsNullOrEmpty(keyword))
            {
                query = query.Where(r =>
                    (r.UserName != null && r.UserName.Contains(keyword, StringComparison.OrdinalIgnoreCase)) ||
                    (r.UserEmail != null && r.UserEmail.Contains(keyword, StringComparison.OrdinalIgnoreCase)) ||
                    (r.OrganizationName != null && r.OrganizationName.Contains(keyword, StringComparison.OrdinalIgnoreCase))
                );
            }

            var totalRecords = await query.CountAsync();

            var requests = await query
                .Skip((pageIndex - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return new PagedResult<InviteRequest>
            {
                Items = requests,
                TotalRecords = totalRecords,
                PageIndex = pageIndex,
                PageSize = pageSize
            };
        }
        public async Task InviteUsersAsync(string organizationId, InvitedList request)
        {
            var organization = await _context.Organizations
                .FirstOrDefaultAsync(o => o.Id == organizationId && !o.IsDeleted);
            if (organization == null) throw new Exception("Organization not found");

            var newInvites = new List<InviteRequest>();

            foreach (var invitedUser in request.Users)
            {
                var existingUser = await _context.Users
                    .FirstOrDefaultAsync(u => u.Uid == invitedUser.UserId);

                if (existingUser == null)
                {
                    throw new Exception($"User {invitedUser.UserId} doesn't exists in the system.");
                }

                var invitation = new InviteRequest
                {
                    UserId = existingUser.Id,
                    UserName = existingUser.DisplayName,
                    UserEmail = existingUser.Email,
                    OrganizationId = organization.Id,
                    OrganizationName = organization.Name,
                    Notes = request.Notes,
                    Role = invitedUser.Role,
                    RequestStatus = (short)Status.INVITION_WAITING,
                };

                newInvites.Add(invitation);
            }

            _context.InviteRequests.AddRange(newInvites);
            await _context.SaveChangesAsync();
        }


        public async Task UpdateInvitationStatusAsync(string invitationId, short status)
        {
            var invitation = await _context.InviteRequests
                .FirstOrDefaultAsync(i => i.Id == invitationId);

            if (invitation == null) throw new Exception("Invitation not found");

            if (status == (short)Status.INVITION_APPROVED)
            {
                var organization = await _context.Organizations
                    .FirstOrDefaultAsync(o => o.Id == invitation.OrganizationId && !o.IsDeleted);
                var user = await _context.Users
                    .FirstOrDefaultAsync(u => u.Id == invitation.UserId);

                if (user == null) throw new Exception("User not found");
                if (organization == null) throw new Exception("Organization not found");

                var existingRole = await _context.UserOrganizationRoles
                    .FirstOrDefaultAsync(uor => uor.UserId == user.Id && uor.OrganizationId == organization.Id);
                if (existingRole != null) throw new Exception("User already has a role in this organization.");

                var userRole = new UserOrganizationRole
                {
                    UserId = user.Id,
                    OrganizationId = organization.Id,
                    Role = (UserRole)invitation.Role
                };

                _context.UserOrganizationRoles.Add(userRole);
                invitation.RequestStatus = (short)Status.INVITION_APPROVED;
            }
            else
            {
                invitation.RequestStatus = status;
            }

            await _context.SaveChangesAsync();
        }
    }
}

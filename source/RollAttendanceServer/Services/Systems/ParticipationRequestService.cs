﻿using Microsoft.EntityFrameworkCore;
using RollAttendanceServer.Data;
using RollAttendanceServer.Data.Enum;
using RollAttendanceServer.Data.Responses;
using RollAttendanceServer.Interfaces;
using RollAttendanceServer.Models;

namespace RollAttendanceServer.Services.Systems
{
    public class ParticipationRequestService : IParticipationRequestService
    {
        private readonly ApplicationDbContext _context;
        private readonly INotificationService _notificationService;

        public ParticipationRequestService(ApplicationDbContext context, INotificationService notificationService)
        {
            _context = context;
            _notificationService = notificationService;
        }

        public async Task<PagedResult<ParticipationRequest>> GetParticipationRequestsAsync(
            string userId,
            string organizationId,
            string keyword,
            int status,
            int pageIndex,
            int pageSize,
            bool forUser)
        {
            var query = _context.ParticipationRequests.AsQueryable();

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

            return new PagedResult<ParticipationRequest>
            {
                Items = requests,
                TotalRecords = totalRecords,
                PageIndex = pageIndex,
                PageSize = pageSize
            };
        }

        public async Task<string> CreateParticipationRequestAsync(string userId, string organizationId, string notes)
        {
            var organization = await _context.Organizations.FindAsync(organizationId);
            if (organization == null)
            {
                throw new Exception("Tổ chức không tồn tại.");
            }

            var existingRole = await _context.UserOrganizationRoles
                .FirstOrDefaultAsync(r => r.UserId == userId && r.OrganizationId == organizationId);
            if (existingRole != null)
            {
                throw new Exception("Người dùng đã tham gia tổ chức này.");
            }

            var existingRequest = await _context.ParticipationRequests
                                                .FirstOrDefaultAsync(r =>
                                                    r.UserId == userId &&
                                                    r.OrganizationId == organizationId &&
                                                    r.RequestStatus == (short)Status.REQUEST_WAITING);

            if (existingRequest != null)
            {
                throw new Exception("Người dùng đã nộp đơn tham gia tổ chức này và đang chờ xử lý.");
            }

            var user = await _context.Users.FindAsync(userId);
            if (user == null)
            {
                throw new Exception("Người dùng không tồn tại.");
            }

            var newRequest = new ParticipationRequest
            {
                UserId = userId,
                UserName = user.DisplayName,
                UserEmail = user.Email,
                OrganizationId = organizationId,
                OrganizationName = organization.Name,
                Notes = notes,
                ParticipationMethod = "Online",
                RequestStatus = (short)Status.REQUEST_WAITING
            };

            _context.ParticipationRequests.Add(newRequest);
            await _context.SaveChangesAsync();

            return newRequest.Id;
        }

        public async Task ApproveOrRejectRequestAsync(string requestId, short newStatus)
        {
            if (newStatus != (short)Status.REQUEST_APPROVED && newStatus != (short)Status.REQUEST_REJECTED)
            {
                throw new Exception("Trạng thái mới không hợp lệ.");
            }

            var request = await _context.ParticipationRequests.FindAsync(requestId);
            if (request == null)
            {
                throw new Exception("Yêu cầu không tồn tại.");
            }

            if (request.RequestStatus == (short)Status.REQUEST_APPROVED || request.RequestStatus == (short)Status.REQUEST_CANCELLED)
            {
                throw new Exception("Yêu cầu đã được duyệt hoặc đã bị hủy.");
            }

            var organization = await _context.Organizations.FindAsync(request.OrganizationId);
            if (organization == null)
            {
                throw new Exception("Tổ chức không tồn tại.");
            }

            var userInOrganization = await _context.UserOrganizationRoles
                .FirstOrDefaultAsync(r => r.UserId == request.UserId && r.OrganizationId == request.OrganizationId);

            request.RequestStatus = newStatus;
            _context.ParticipationRequests.Update(request);

            if (newStatus == (short)Status.REQUEST_APPROVED && userInOrganization == null)
            {
                var newUserRole = new UserOrganizationRole
                {
                    UserId = request.UserId,
                    OrganizationId = request.OrganizationId,
                    Role = UserRole.USER
                };
                _context.UserOrganizationRoles.Add(newUserRole);
            }

            await _context.SaveChangesAsync();

            string title, body, route;
            if (newStatus == (short)Status.REQUEST_APPROVED)
            {
                title = "Yêu cầu của bạn được duyệt";
                body = $"Yêu cầu tham gia {organization.Name} của bạn được duyệt.";
                route = $"/organization-detail/{organization.Id}";
            }
            else // REQUEST_REJECTED
            {
                title = "Yêu cầu của bạn bị từ chối";
                body = $"Yêu cầu tham gia {organization.Name} của bạn đã bị từ chối.";
                route = $"/public-organization-detail/{organization.Id}";
            }

            await _notificationService.SendAndSaveNotificationAsync(request.UserId, title, body, null, route);
        }

        public async Task CancelRequestAsync(string requestId, string userId)
        {
            var request = await _context.ParticipationRequests.FindAsync(requestId);
            if (request == null)
            {
                throw new Exception("Yêu cầu không tồn tại.");
            }

            if (request.UserId != userId)
            {
                throw new Exception("Người dùng không có quyền hủy yêu cầu này.");
            }

            request.RequestStatus = (short)Status.REQUEST_CANCELLED;
            _context.ParticipationRequests.Update(request);

            await _context.SaveChangesAsync();
        }
    }
}

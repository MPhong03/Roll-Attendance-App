using Microsoft.EntityFrameworkCore;
using RollAttendanceServer.Data;
using RollAttendanceServer.Data.Enum;
using RollAttendanceServer.DTOs;
using RollAttendanceServer.Helpers;
using RollAttendanceServer.Interfaces;
using RollAttendanceServer.Models;

namespace RollAttendanceServer.Services.Systems
{
    public class EventService : IEventService
    {
        private readonly ApplicationDbContext _context;

        public EventService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<Event?> GetEventByIdAsync(string eventId)
        {
            return await _context.Events
                .Include(e => e.Organization)
                .FirstOrDefaultAsync(e => e.Id == eventId);
        }

        public async Task<Event> Create(EventDTO eventDto, string organizerId)
        {
            var organization = await _context.Organizations
                .Include(o => o.UserOrganizationRoles)
                .FirstOrDefaultAsync(o => o.Id == eventDto.OrganizationId);

            if (organization == null)
            {
                throw new Exception("Organization does not exist.");
            }

            var userRole = organization.UserOrganizationRoles
                .FirstOrDefault(ur => ur.UserId == organizerId);

            if (userRole == null || (userRole.Role != UserRole.ORGANIZER && userRole.Role != UserRole.REPRESENTATIVE))
            {
                throw new Exception("User is not authorized to create an event in this organization.");
            }

            var newEvent = new Event
            {
                Name = eventDto.Name,
                Description = eventDto.Description,
                StartTime = eventDto.StartTime,
                EndTime = eventDto.EndTime,
                CurrentLocation = eventDto.CurrentLocation,
                CurrentLocationRadius = eventDto.CurrentLocationRadius,
                CurrentQR = eventDto.CurrentQR,
                EventStatus = eventDto.EventStatus,
                OrganizationId = eventDto.OrganizationId,
                OrganizerId = organizerId,
                IsPrivate = eventDto.IsPrivate,
            };

            _context.Events.Add(newEvent);
            await _context.SaveChangesAsync();

            return newEvent;
        }

        public async Task<Event> Update(string eventId, EventDTO eventDto, string organizerId)
        {
            var existingEvent = await _context.Events
                .Include(e => e.Organization)
                .FirstOrDefaultAsync(e => e.Id == eventId);

            if (existingEvent == null)
            {
                throw new Exception("Event does not exist.");
            }

            var organization = await _context.Organizations
                .Include(o => o.UserOrganizationRoles)
                .FirstOrDefaultAsync(o => o.Id == eventDto.OrganizationId);

            if (organization == null)
            {
                throw new Exception("Organization does not exist.");
            }

            var userRole = organization.UserOrganizationRoles
                .FirstOrDefault(ur => ur.UserId == organizerId);

            if (userRole == null || (userRole.Role != UserRole.ORGANIZER && userRole.Role != UserRole.REPRESENTATIVE))
            {
                throw new Exception("User is not authorized to update this event.");
            }

            existingEvent.Name = eventDto.Name ?? existingEvent.Name;
            existingEvent.Description = eventDto.Description ?? existingEvent.Description;
            existingEvent.StartTime = eventDto.StartTime ?? existingEvent.StartTime;
            existingEvent.EndTime = eventDto.EndTime ?? existingEvent.EndTime;
            existingEvent.CurrentLocation = eventDto.CurrentLocation ?? existingEvent.CurrentLocation;
            existingEvent.CurrentLocationRadius = eventDto.CurrentLocationRadius != 0 ? eventDto.CurrentLocationRadius : existingEvent.CurrentLocationRadius;
            existingEvent.CurrentQR = eventDto.CurrentQR ?? existingEvent.CurrentQR;
            existingEvent.EventStatus = eventDto.EventStatus != 0 ? eventDto.EventStatus : existingEvent.EventStatus;
            existingEvent.IsPrivate = eventDto.IsPrivate;

            await _context.SaveChangesAsync();
            return existingEvent;
        }

        public async Task<bool> AddUsersToPermitedUserAsync(string eventId, List<string> userIds)
        {
            var @event = await _context.Events
                .Include(e => e.EventUsers)
                .FirstOrDefaultAsync(e => e.Id == eventId);

            if (@event == null)
                throw new Exception("Event not found.");

            var existingUserIds = @event.EventUsers.Select(eu => eu.UserId).ToList();

            var users = await _context.Users
                .Where(u => userIds.Contains(u.Id))
                .ToListAsync();

            if (users.Count != userIds.Count)
                throw new Exception("Some users not found.");

            foreach (var user in users)
            {
                if (!existingUserIds.Contains(user.Id))
                {
                    @event.EventUsers.Add(new EventUser
                    {
                        EventId = eventId,
                        UserId = user.Id
                    });
                }
            }

            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<IEnumerable<Event>> GetEventsByOrganizationAsync(string organizationId, string keyword, DateTime? startDate, DateTime? endDate, int pageIndex, int pageSize)
        {
            var query = _context.Events.AsQueryable();

            query = query.Where(e => e.OrganizationId == organizationId);

            if (!string.IsNullOrEmpty(keyword))
            {
                query = query.Where(e => e.Name.Contains(keyword));
            }

            if (startDate.HasValue)
            {
                query = query.Where(e => e.StartTime >= startDate.Value);
            }

            if (endDate.HasValue)
            {
                query = query.Where(e => e.EndTime <= endDate.Value);
            }

            query = query.Skip((pageIndex - 1) * pageSize).Take(pageSize);

            return await query.ToListAsync();
        }

        // CHECK IN MODULE
        public async Task<Event> ActivateEventAsync(string eventId)
        {
            var eventEntity = await _context.Events.FindAsync(eventId);
            if (eventEntity == null || eventEntity.EventStatus != (short)Status.EVENT_NOT_STARTED)
                throw new Exception("Event not found or already started.");

            eventEntity.EventStatus = (short)Status.EVENT_IN_PROGRESS;
            eventEntity.CurrentQR = Tools.GenerateUniqueCode();
            eventEntity.StartTime = DateTime.UtcNow;

            var history = new History { EventId = eventEntity.Id };
            _context.Histories.Add(history);

            await _context.SaveChangesAsync();
            return eventEntity;
        }

        public async Task CheckInAsync(string eventId, string userId, string qrCode, int attendanceAttempt)
        {
            var eventEntity = await _context.Events
                .Include(e => e.EventUsers)
                .Include(e => e.Histories)
                .ThenInclude(h => h.HistoryDetails)
                .FirstOrDefaultAsync(e => e.Id == eventId);

            if (eventEntity == null || eventEntity.EventStatus != (short)Status.EVENT_IN_PROGRESS)
                throw new Exception("Event not found or not active.");

            if (eventEntity.CurrentQR != qrCode)
                throw new Exception("Invalid QR code.");

            if (eventEntity.IsPrivate && !eventEntity.EventUsers.Any(eu => eu.UserId == userId))
                throw new Exception("User not permitted for this event.");

            var history = eventEntity.Histories.FirstOrDefault();
            if (history == null) throw new Exception("History not found for the event.");

            var userDetail = history.HistoryDetails.FirstOrDefault(d => d.UserId == userId);
            if (userDetail == null)
            {
                userDetail = new HistoryDetail
                {
                    UserId = userId,
                    AttendanceCount = 1,
                    AbsentTime = DateTime.UtcNow,
                    AttendanceStatus = attendanceAttempt == 1 ? (short)Status.USER_PRESENTED : (short)Status.USER_LATED
                };
                history.HistoryDetails.Add(userDetail);
            }
            else
            {
                userDetail.AttendanceCount++;
                userDetail.LeaveTime = DateTime.UtcNow;
            }

            if (attendanceAttempt == 1)
                history.PresentCount++;

            await _context.SaveChangesAsync();
        }

        public async Task AddAttendanceAttemptAsync(string eventId)
        {
            var history = await _context.Histories.FirstOrDefaultAsync(h => h.EventId == eventId);
            if (history == null) throw new Exception("History not found.");

            history.AttendanceTimes++;
            var eventEntity = await _context.Events.FindAsync(eventId);
            eventEntity.CurrentQR = Tools.GenerateUniqueCode();

            await _context.SaveChangesAsync();
        }

        public async Task<Event> CompleteEventAsync(string eventId)
        {
            var eventEntity = await _context.Events
                .Include(e => e.EventUsers)
                .Include(e => e.Histories)
                .ThenInclude(h => h.HistoryDetails)
                .FirstOrDefaultAsync(e => e.Id == eventId);

            if (eventEntity == null || eventEntity.EventStatus != (short)Status.EVENT_IN_PROGRESS)
                throw new Exception("Event not found or not active.");

            eventEntity.EventStatus = (short)Status.EVENT_COMPLETED;
            eventEntity.EndTime = DateTime.UtcNow;

            var history = eventEntity.Histories.FirstOrDefault();
            if (history != null)
            {
                history.TotalCount = eventEntity.IsPrivate
                    ? eventEntity.EventUsers.Count
                    : history.HistoryDetails.Count;

                history.PresentCount = history.HistoryDetails.Count(d => d.AttendanceStatus == (short)Status.USER_PRESENTED);
                history.LateCount = history.HistoryDetails.Count(d => d.AttendanceStatus == (short)Status.USER_LATED);
            }

            await _context.SaveChangesAsync();
            return eventEntity;
        }
    }
}

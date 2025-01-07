using Microsoft.EntityFrameworkCore;
using RollAttendanceServer.Data;
using RollAttendanceServer.Data.Enum;
using RollAttendanceServer.DTOs;
using RollAttendanceServer.Helpers;
using RollAttendanceServer.Interfaces;
using RollAttendanceServer.Models;
using static Microsoft.Extensions.Logging.EventSource.LoggingEventSource;

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

        public async Task<CheckInStateDTO?> GetEventCheckInState(string eventId, string userId)
        {
            var history = await _context.Histories
                .Where(h => h.EventId == eventId)
                .Include(h => h.HistoryDetails)
                .FirstOrDefaultAsync();

            if (history == null)
            {
                return new CheckInStateDTO
                {
                    UserId = userId,
                    EventId = eventId,
                    IsCheckInYet = false,
                    AttendanceStatus = (short)Status.EVENT_NOT_STARTED,
                    AttendanceCount = 0
                };
            }

            var userHistoryDetail = history.HistoryDetails
                .FirstOrDefault(hd => hd.UserId == userId);

            if (userHistoryDetail == null)
            {
                return new CheckInStateDTO
                {
                    UserId = userId,
                    EventId = eventId,
                    IsCheckInYet = false,
                    AttendanceStatus = (short)Status.USER_ABSENTED,
                    AttendanceCount = 0
                };
            }

             return new CheckInStateDTO
            {
                UserId = userHistoryDetail.UserId,
                DisplayName = userHistoryDetail.UserName,
                Email = userHistoryDetail.UserEmail,
                Avatar = userHistoryDetail.UserAvatar,
                IsCheckInYet = true,
                AttendanceStatus = userHistoryDetail.AttendanceStatus,
                AttendanceCount = userHistoryDetail.AttendanceCount,
                EventId = history.EventId
            };
        }

        public async Task<IEnumerable<ActiveEventDTO>> GetUserActiveEvents(string userId, DateTime? date, short status, int pageIndex, int pageSize)
        {
            var organizationIds = await _context.UserOrganizationRoles
                .Where(uor => uor.UserId == userId)
                .Select(uor => uor.OrganizationId)
                .ToListAsync();

            if (!organizationIds.Any())
            {
                return Enumerable.Empty<ActiveEventDTO>();
            }

            var query = _context.Events
                .Where(e =>
                    organizationIds.Contains(e.OrganizationId) &&
                    (!e.IsPrivate || e.EventUsers.Any(eu => eu.UserId == userId))
                );

            if (date.HasValue)
            {
                query = query.Where(e => e.StartTime.Value.Date <= date.Value.Date && e.EndTime.Value.Date >= date.Value.Date);
            }

            query = query.Where(e => e.EventStatus == status);

            query = query.Skip((pageIndex - 1) * pageSize).Take(pageSize);

            var events = await query
                .Select(e => new ActiveEventDTO
                {
                    Id = e.Id,
                    Name = e.Name,
                    Description = e.Description,
                    StartTime = e.StartTime,
                    EndTime = e.EndTime,
                    CurrentLocation = e.CurrentLocation,
                    CurrentLocationRadius = e.CurrentLocationRadius,
                    CurrentQR = e.CurrentQR,
                    EventStatus = e.EventStatus,
                    OrganizerId = e.OrganizerId,
                    OrganizationId = e.OrganizationId,
                    IsPrivate = e.IsPrivate,

                    OrganizerName = _context.Users
                        .Where(u => u.Id == e.OrganizerId)
                        .Select(u => u.DisplayName)
                        .FirstOrDefault(),
                    OrganizerEmail = _context.Users
                        .Where(u => u.Id == e.OrganizerId)
                        .Select(u => u.Email)
                        .FirstOrDefault(),
                    OrganizerAvatar = _context.Users
                        .Where(u => u.Id == e.OrganizerId)
                        .Select(u => u.Avatar)
                        .FirstOrDefault(),

                    OrganizationName = _context.Organizations
                        .Where(o => o.Id == e.OrganizationId)
                        .Select(o => o.Name)
                        .FirstOrDefault(),
                    OrganizationImage = _context.Organizations
                        .Where(o => o.Id == e.OrganizationId)
                        .Select(o => o.Image)
                        .FirstOrDefault()
                })
                .ToListAsync();

            foreach (var eventDto in events)
            {
                var history = await _context.Histories
                    .FirstOrDefaultAsync(h => h.EventId == eventDto.Id);

                if (history != null)
                {
                    var historyDetail = await _context.HistoryDetails
                        .FirstOrDefaultAsync(hd => hd.HistoryId == history.Id && hd.UserId == userId);

                    if (historyDetail != null)
                    {
                        eventDto.AttendanceStatus = historyDetail.AttendanceStatus;
                        eventDto.AttendanceTimes = historyDetail.AttendanceCount;
                        eventDto.IsCheckInYet = true;
                    }
                    else
                    {
                        eventDto.AttendanceStatus = (short)Status.USER_ABSENTED;
                        eventDto.IsCheckInYet = false;
                    }
                }
                else
                {
                    eventDto.AttendanceStatus = (short)Status.EVENT_NOT_STARTED;
                    eventDto.IsCheckInYet = false;
                }
            }

            return events;
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

            _context.EventUsers.RemoveRange(@event.EventUsers);

            var existingUserIds = @event.EventUsers.Select(eu => eu.UserId).ToList();

            var users = await _context.Users
                .Where(u => userIds.Contains(u.Id))
                .ToListAsync();

            if (users.Count != userIds.Count)
                throw new Exception("Some users not found.");

            foreach (var user in users)
            {
                @event.EventUsers.Add(new EventUser
                {
                    EventId = eventId,
                    UserId = user.Id
                });
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

        public async Task<IEnumerable<UserDTO>> GetEventUsersAsync(string eventId)
        {
            var eventEntity = await _context.Events
                .Include(e => e.EventUsers)
                .ThenInclude(eu => eu.User)
                .FirstOrDefaultAsync(e => e.Id == eventId);

            if (eventEntity == null)
            {
                throw new Exception("Event not found.");
            }

            return eventEntity.EventUsers.Select(eu => new UserDTO
            {
                Id = eu.User.Id,
                Uid = eu.User.Uid,
                DisplayName = eu.User.DisplayName,
                Email = eu.User.Email,
                PhoneNumber = eu.User.PhoneNumber,
                Avatar = eu.User.Avatar,
            }).ToList();
        }

    }
}

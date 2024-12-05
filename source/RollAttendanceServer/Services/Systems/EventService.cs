using Microsoft.EntityFrameworkCore;
using RollAttendanceServer.Data;
using RollAttendanceServer.Data.Enum;
using RollAttendanceServer.DTOs;
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
                OrganizerId = organizerId
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

            await _context.SaveChangesAsync();
            return existingEvent;
        }

        public async Task<bool> AddUsersToPermitedUserAsync(string eventId, List<string> userIds)
        {
            var @event = await _context.Events
                .Include(e => e.PermitedUser)
                .FirstOrDefaultAsync(e => e.Id == eventId);

            if (@event == null)
                throw new Exception("Event not found.");

            var users = await _context.Users
                .Where(u => userIds.Contains(u.Id))
                .ToListAsync();

            if (users.Count != userIds.Count)
                throw new Exception("Some users not found.");

            foreach (var user in users)
            {
                if (!@event.PermitedUser.Contains(user))
                    @event.PermitedUser.Add(user);
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
    }
}

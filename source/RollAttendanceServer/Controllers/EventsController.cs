using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using RollAttendanceServer.Data;
using RollAttendanceServer.DTOs;
using RollAttendanceServer.Interfaces;
using RollAttendanceServer.Requests;
using System.Security.Claims;

namespace RollAttendanceServer.Controllers
{
    [Authorize(AuthenticationSchemes = "Firebase")]
    [Route("api/[controller]")]
    [ApiController]
    public class EventsController : ControllerBase
    {
        private readonly IEventService _eventService;

        public EventsController(IEventService eventService)
        {
            _eventService = eventService;
        }

        [HttpGet("organization/{organizationId}")]
        public async Task<IActionResult> GetEventsByOrganization(
            string organizationId,
            [FromQuery] string? keyword,
            [FromQuery] DateTime? startDate,
            [FromQuery] DateTime? endDate,
            [FromQuery] int pageIndex = 1,
            [FromQuery] int pageSize = 10)
        {
            try
            {
                var events = await _eventService.GetEventsByOrganizationAsync(organizationId, keyword, startDate, endDate, pageIndex, pageSize);
                return Ok(events);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("create")]
        public async Task<IActionResult> CreateEvent([FromBody] EventDTO eventDto)
        {
            try
            {
                var organizerId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(organizerId))
                {
                    return Unauthorized("Invalid user.");
                }

                var newEvent = await _eventService.Create(eventDto, organizerId);
                return CreatedAtAction(nameof(GetEventById), new { eventId = newEvent.Id }, newEvent);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("update/{eventId}")]
        public async Task<IActionResult> UpdateEvent(string eventId, [FromBody] EventDTO eventDto)
        {
            try
            {
                var organizerId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(organizerId))
                {
                    return Unauthorized("Invalid user.");
                }

                var updatedEvent = await _eventService.Update(eventId, eventDto, organizerId);
                return Ok(updatedEvent);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("{eventId}")]
        public async Task<IActionResult> GetEventById(string eventId)
        {
            try
            {
                var @event = await _eventService.GetEventByIdAsync(eventId);
                if (@event == null)
                {
                    return NotFound("Event not found.");
                }

                return Ok(@event);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("{eventId}/add-users")]
        public async Task<IActionResult> AddUsersToEvent(string eventId, [FromBody] List<string> userIds)
        {
            try
            {
                if (userIds == null || userIds.Count == 0)
                    return BadRequest("User list is empty.");

                var result = await _eventService.AddUsersToPermitedUserAsync(eventId, userIds);

                if (result)
                    return Ok("Users added to PermitedUser successfully.");

                return BadRequest("Failed to add users.");
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("{eventId}/activate")]
        public async Task<IActionResult> ActivateEvent(string eventId)
        {
            try
            {
                var result = await _eventService.ActivateEventAsync(eventId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("{eventId}/check-in")]
        public async Task<IActionResult> CheckIn(string eventId, [FromBody] CheckInRequest request)
        {
            try
            {
                await _eventService.CheckInAsync(eventId, request.UserId, request.QrCode, request.AttendanceAttempt);
                return Ok();
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("{eventId}/add-attempt")]
        public async Task<IActionResult> AddAttendanceAttempt(string eventId)
        {
            try
            {
                await _eventService.AddAttendanceAttemptAsync(eventId);
                return Ok();
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("{eventId}/complete")]
        public async Task<IActionResult> CompleteEvent(string eventId)
        {
            try
            {
                var result = await _eventService.CompleteEventAsync(eventId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

    }
}

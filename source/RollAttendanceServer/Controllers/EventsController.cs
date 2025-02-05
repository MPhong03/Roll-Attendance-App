﻿using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using RollAttendanceServer.Data;
using RollAttendanceServer.Data.Requests;
using RollAttendanceServer.DTOs;
using RollAttendanceServer.Interfaces;
using RollAttendanceServer.Services.Systems;
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

        [HttpGet("available-events")]
        public async Task<IActionResult> GetUserAvailableEvents(
            [FromQuery] DateTime? startDate,
            [FromQuery] DateTime? endDate,
            [FromQuery] short status,
            [FromQuery] int pageIndex = 1,
            [FromQuery] int pageSize = 10)
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized("Invalid user.");
                }
                var events = await _eventService.GetUserActiveEvents(userId, startDate, endDate, status, pageIndex, pageSize);
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

        [HttpGet("users/{eventId}")]
        public async Task<IActionResult> GetPermittedUserEvent(string eventId)
        {
            try
            {
                var users = await _eventService.GetEventUsersAsync(eventId);
                if (users == null)
                {
                    return NotFound("Event not found.");
                }

                return Ok(users);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("{eventId}/add-users")]
        public async Task<IActionResult> AddUsersToEvent(string eventId, [FromBody] UserListDTO dto)
        {
            try
            {
                if (dto.UserIds == null || dto.UserIds.Count == 0)
                    return BadRequest("User list is empty.");

                var result = await _eventService.AddUsersToPermitedUserAsync(eventId, dto.UserIds);

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
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized("Invalid user.");
                }

                await _eventService.CheckInAsync(eventId, userId, request.QrCode, request.AttendanceAttempt);
                return Ok("Successfully check in!");
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("{eventId}/check-in-by-face")]
        public async Task<IActionResult> CheckInByFace(string eventId, [FromBody] FaceCheckInRequest request)
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized("Invalid user.");
                }

                if (string.IsNullOrEmpty(request.FaceData))
                {
                    return NotFound("Face data not found!");
                }

                await _eventService.FaceCheckIn(eventId, request.FaceData, request.AttendanceAttempt);
                return Ok("Successfully check in!");
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
                return Ok("Successfully add attempt");
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

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteEvent(string id)
        {
            try
            {
                await _eventService.DeleteEventAsync(id);

                return Ok(new { eventId = id, message = "Successfully delete event" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
            }
        }

        [HttpPost("{id}/cancel")]
        public async Task<IActionResult> CancelEvent(string id)
        {
            try
            {
                await _eventService.CancelEventAsync(id);

                return Ok(new { eventId = id, message = "Successfully cancel event" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
            }
        }

        [HttpPost("{id}/absented-request")]
        public async Task<IActionResult> SendAbsentRequest(string id, [FromBody] AbsentedRequest request)
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized("Invalid user.");
                }

                var newRequest = await _eventService.SendRequest(id, userId, request.Notes, 0);

                return Ok(new { request = newRequest, message = "Successfully send request" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
            }
        }

        [HttpPut("{id}/update-request")]
        public async Task<IActionResult> UpdateAbsentRequest(string id, [FromBody] UpdateStatusRequest request)
        {
            try
            {
                var existedRequest = await _eventService.UpdateRequestStatusAsync(id, request.Status);

                return Ok(new { request = existedRequest, message = "Successfully update request" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
            }
        }

        [HttpGet("absented-requests/{eventId}")]
        public async Task<IActionResult> GetAbsentedRequest(
            string eventId,
            [FromQuery] string? keyword,
            [FromQuery] short type,
            [FromQuery] short status,
            [FromQuery] DateTime? startDate,
            [FromQuery] DateTime? endDate,
            [FromQuery] int pageIndex = 1,
            [FromQuery] int pageSize = 10)
        {
            try
            {
                var events = await _eventService.GetEventRequests(eventId, null, keyword, type, status, startDate, endDate, pageIndex, pageSize);
                return Ok(events);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("user-absented-requests/{eventId}")]
        public async Task<IActionResult> GetUserAbsentedRequest(
            string eventId,
            [FromQuery] string? keyword,
            [FromQuery] short type,
            [FromQuery] short status,
            [FromQuery] DateTime? startDate,
            [FromQuery] DateTime? endDate,
            [FromQuery] int pageIndex = 1,
            [FromQuery] int pageSize = 10)
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized("Invalid user.");
                }

                var events = await _eventService.GetEventRequests(eventId, userId, keyword, type, status, startDate, endDate, pageIndex, pageSize);
                return Ok(events);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("{id}/activate-geography-checkin")]
        public async Task<IActionResult> ActivateGeographyCheckIn(string id, [FromBody] GeographyCheckInRequest request)
        {
            try
            {
                var result = await _eventService.ActivateGeographyCheckIn(id, request.Latitude, request.Longitude, request.Radius);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("{id}/geography-checkin")]
        public async Task<IActionResult> GeographyCheckIn(string id, [FromBody] GeographyCheckInUserRequest request)
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized("Invalid user.");
                }

                var result = await _eventService.GeographyCheckIn(id, userId, request.Latitude, request.Longitude, request.AttendanceAttempt);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }

    public class GeographyCheckInRequest
    {
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public decimal Radius { get; set; }
    }

    public class GeographyCheckInUserRequest
    {
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public int AttendanceAttempt { get; set; }
    }
}

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using RollAttendanceServer.Data;
using RollAttendanceServer.Data.Enum;
using RollAttendanceServer.Data.Requests;
using RollAttendanceServer.DTOs;
using RollAttendanceServer.Interfaces;
using RollAttendanceServer.Models;
using RollAttendanceServer.Services.Systems;
using System.Diagnostics;
using System.Drawing.Printing;
using System.Security.Claims;

namespace RollAttendanceServer.Controllers
{
    [Authorize(AuthenticationSchemes = "Firebase")]
    [Route("api/[controller]")]
    [ApiController]
    public class OrganizationController : ControllerBase
    {
        private readonly IOrganizationService _organizationService;
        private readonly IInvitionRequestService _invitionRequestService;

        public OrganizationController(IOrganizationService organizationService, IInvitionRequestService invitionRequestService)
        {
            _organizationService = organizationService;
            _invitionRequestService = invitionRequestService;
        }

        [HttpGet]
        public async Task<IActionResult> SearchOrganizations(string? keyword, int pageIndex = 0, int pageSize = 10)
        {
            try
            {
                var organizations = await _organizationService.SearchOrganizationsAsync(keyword, pageIndex, pageSize);
                return Ok(organizations);
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
            }
        }

        [HttpGet("suggestions")]
        public async Task<IActionResult> GetOrganizationSuggestions([FromQuery] string keyword)
        {
            try
            {
                var authorizationHeader = Request.Headers["Authorization"].ToString();

                if (string.IsNullOrEmpty(authorizationHeader) || !authorizationHeader.StartsWith("Bearer "))
                {
                    return Unauthorized("Missing or invalid Authorization header.");
                }

                var token = authorizationHeader.Substring("Bearer ".Length);

                Debug.WriteLine("Bearer " + token);

                var suggestions = await _organizationService.SuggestOrganizationNamesAsync(keyword);
                return Ok(suggestions);
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
            }
        }

        [HttpGet("getall/{uid}")]
        public async Task<IActionResult> GetMyOrganizations(string uid, [FromQuery] string? keyword, [FromQuery] int pageIndex = 0, [FromQuery] int pageSize = 10)
        {
            try
            {
                var organizations = await _organizationService.GetOrganizationsByUserAsync(uid, UserRole.REPRESENTATIVE, keyword, pageIndex, pageSize);

                if (organizations == null || !organizations.Any())
                    return NotFound("No organizations found for the specified user.");

                return Ok(organizations);
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
            }
        }

        [HttpGet("getusers/{organizationId}")]
        public async Task<IActionResult> GetUsersByOrganization(
            string organizationId,
            [FromQuery] string? keyword,
            [FromQuery] int pageIndex = 1,
            [FromQuery] int pageSize = 10)
        {
            try
            {
                var users = await _organizationService.GetOrganizationUsersAsync(organizationId, keyword, pageIndex, pageSize);
                return Ok(users);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("detail/{id}")]
        public async Task<IActionResult> GetOrganization(string id)
        {
            try
            {
                var organization = await _organizationService.GetOrganizationByIdAsync(id);
                if (organization == null)
                    return NotFound($"Organization with ID {id} not found.");

                return Ok(organization);
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
            }
        }

        [HttpPost]
        public async Task<IActionResult> CreateOrganization([FromForm] OrganizationDTO dto, [FromForm] IFormFile? bannerFile, [FromForm] IFormFile? imageFile)
        {
            try
            {
                Stream? bannerStream = bannerFile?.OpenReadStream();
                Stream? imageStream = imageFile?.OpenReadStream();

                Debug.WriteLine("FORMFILE:", imageFile, bannerFile);

                var organization = await _organizationService.CreateOrganizationAsync(dto, bannerStream, imageStream);
                return CreatedAtAction(nameof(CreateOrganization), new { id = organization.Id }, organization);
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
            }
        }

        [HttpPut("{organizationId}")]
        public async Task<IActionResult> UpdateOrganization(string organizationId, [FromForm] OrganizationDTO dto, [FromForm] IFormFile? bannerFile, [FromForm] IFormFile? imageFile)
        {
            try
            {
                Stream? bannerStream = bannerFile?.OpenReadStream();
                Stream? imageStream = imageFile?.OpenReadStream();

                var organization = await _organizationService.UpdateOrganizationAsync(organizationId, dto, bannerStream, imageStream);
                return Ok(organization);
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
            }
        }

        [HttpGet("invite-list")]
        public async Task<IActionResult> GetParticipationRequests([FromQuery] InvitionQuery query)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userId))
            {
                return Unauthorized("Không thể xác thực người dùng.");
            }

            try
            {
                var result = await _invitionRequestService.GetInviteRequestsAsync(
                    query.UserId ?? userId,
                    query.OrganizationId,
                    query.Keyword,
                    query.Status,
                    query.PageIndex,
                    query.PageSize,
                    query.ForUser
                );

                return Ok(new
                {
                    Message = "Danh sách thư mời tham gia",
                    Data = result.Items,
                    result.TotalRecords,
                    result.PageIndex,
                    result.PageSize
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }

        [HttpPost("invite/{organizationId}")]
        public async Task<IActionResult> InviteUser(string organizationId, [FromBody] InvitedList request)
        {
            try
            {
                await _invitionRequestService.InviteUsersAsync(organizationId, request);
                return Ok(new { organizationId, request });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPut("invite/accept/{invitationId}")]
        public async Task<IActionResult> AcceptInvitation(string invitationId)
        {
            try
            {
                await _invitionRequestService.UpdateInvitationStatusAsync(invitationId, (short)Status.INVITION_APPROVED);
                return Ok(new { invitationId, status = Status.INVITION_APPROVED });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPut("invite/reject/{invitationId}")]
        public async Task<IActionResult> RejectInvitation(string invitationId)
        {
            try
            {
                await _invitionRequestService.UpdateInvitationStatusAsync(invitationId, (short)Status.INVITION_REJECTED);
                return Ok(new { invitationId, status = Status.INVITION_REJECTED });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPut("invite/cancel/{invitationId}")]
        public async Task<IActionResult> CancelInvitation(string invitationId)
        {
            try
            {
                await _invitionRequestService.UpdateInvitationStatusAsync(invitationId, (short)Status.INVITION_CANCELLED);
                return Ok(new { invitationId, status = Status.INVITION_CANCELLED });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("Add/{organizationId}")]
        public async Task<IActionResult> AddToRole(string organizationId, [FromBody] AddToRoleRequest request)
        {
            try
            {
                await _organizationService.AddUserToRoleAsync(organizationId, request);
                return Ok(new { organizationId, request.UserId, request.Role });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPost("add-list/{organizationId}")]
        public async Task<IActionResult> AddToRoles(string organizationId, [FromBody] AddListToRoleRequest request)
        {
            try
            {
                await _organizationService.AddUsersAsync(organizationId, request.Requests);
                return Ok(new { organizationId, request.Requests });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPut("remove-list/{organizationId}")]
        public async Task<IActionResult> RemoveFromOrg(string organizationId, [FromBody] RemoveUsersRequest request)
        {
            try
            {
                await _organizationService.RemoveUsersAsync(organizationId, request);
                return Ok(new { organizationId, request.UserIds });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
    }

    public class InvitionQuery
    {
        public bool ForUser { get; set; } = true;
        public string? UserId { get; set; }
        public string? OrganizationId { get; set; }
        public string? Keyword { get; set; }
        public int Status { get; set; }
        public int PageIndex { get; set; } = 1;
        public int PageSize { get; set; } = 10;
    }

    public class InvitedList
    {
        public List<InvitedUsers> Users { get; set; }
        public string? Notes { get; set; }
    }

    public class InvitedUsers
    {
        public string? UserId { get; set; }
        public short Role { get; set; }
    }
}

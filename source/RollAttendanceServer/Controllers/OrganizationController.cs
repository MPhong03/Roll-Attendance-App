using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using RollAttendanceServer.Data;
using RollAttendanceServer.Data.Enum;
using RollAttendanceServer.DTOs;
using RollAttendanceServer.Interfaces;
using RollAttendanceServer.Models;
using RollAttendanceServer.Requests;
using RollAttendanceServer.Services.Systems;
using System.Diagnostics;

namespace RollAttendanceServer.Controllers
{
    [Authorize(AuthenticationSchemes = "Firebase")]
    [Route("api/[controller]")]
    [ApiController]
    public class OrganizationController : ControllerBase
    {
        private readonly IOrganizationService _organizationService;

        public OrganizationController(IOrganizationService organizationService)
        {
            _organizationService = organizationService;
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
    }
}

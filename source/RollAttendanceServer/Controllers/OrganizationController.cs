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
        public async Task<IActionResult> GetMyOrganizations(string uid)
        {
            try
            {
                var organizations = await _organizationService.GetOrganizationsByUserAsync(uid, UserRole.REPRESENTATIVE);
                if (organizations == null || !organizations.Any())
                    return NotFound("No organizations found for the specified user.");

                return Ok(organizations);
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
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
        public async Task<IActionResult> CreateOrganization([FromBody] OrganizationDTO dto)
        {
            try
            {
                var organization = await _organizationService.CreateOrganizationAsync(dto);
                return CreatedAtAction(nameof(CreateOrganization), new { id = organization.Id }, organization);
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

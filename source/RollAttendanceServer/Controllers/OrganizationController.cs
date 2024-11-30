using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using RollAttendanceServer.Data;
using RollAttendanceServer.Data.Enum;
using RollAttendanceServer.DTOs;
using RollAttendanceServer.Models;

namespace RollAttendanceServer.Controllers
{
    [Authorize(AuthenticationSchemes = "Firebase")]
    [Route("api/[controller]")]
    [ApiController]
    public class OrganizationController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public OrganizationController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet("getall/{uid}")]
        public async Task<IActionResult> GetMyOrganizations(string uid)
        {
            try
            {
                var organizations = await _context.UserOrganizationRoles
                    .Where(uor => uor.User.Uid == uid && uor.Role == UserRole.REPRESENTATIVE)
                    .Select(uor => uor.Organization)
                    .ToListAsync();

                if (organizations == null || organizations.Count == 0)
                {
                    return NotFound("No organizations found for the specified user.");
                }

                return Ok(organizations);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        [HttpGet("detail/{id}")]
        public async Task<IActionResult> GetOrganization(string id)
        {
            try
            {
                var organization = await _context.Organizations
                    .FirstOrDefaultAsync(org => org.Id == id && !org.IsDeleted);

                if (organization == null)
                {
                    return NotFound($"Organization with ID {id} not found.");
                }

                return Ok(organization);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        [HttpPost]
        public async Task<IActionResult> CreateOrganization([FromBody] OrganizationDTO dto)
        {
            try
            {
                var organization = new Organization
                {
                    Id = Guid.NewGuid().ToString("N").ToUpper(),
                    Name = dto.Name,
                    Description = dto.Description,
                    Address = dto.Address ?? string.Empty,
                    IsPrivate = (bool)dto.IsPrivate,
                    IsDeleted = false
                };

                _context.Organizations.Add(organization);
                await _context.SaveChangesAsync();

                var user = await _context.Users.FirstOrDefaultAsync(u => u.Uid == dto.UserId);
                if (user != null)
                {
                    var userRole = new UserOrganizationRole
                    {
                        UserId = user.Id,
                        OrganizationId = organization.Id,
                        Role = UserRole.REPRESENTATIVE
                    };

                    _context.UserOrganizationRoles.Add(userRole);
                    await _context.SaveChangesAsync();
                }

                return CreatedAtAction(nameof(CreateOrganization), new { id = organization.Id }, organization);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateOrganization(string id, [FromBody] OrganizationDTO dto)
        {
            try
            {
                var organization = await _context.Organizations
                    .FirstOrDefaultAsync(o => o.Id == id && !o.IsDeleted);

                if (organization == null)
                {
                    return NotFound("Organization not found");
                }

                organization.Name = dto.Name ?? organization.Name;
                organization.Description = dto.Description ?? organization.Description;
                organization.Address = dto.Address ?? organization.Address;

                await _context.SaveChangesAsync();

                return Ok(organization);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        [HttpPost("Add/{organizationId}")]
        public async Task<IActionResult> AddToRole(string organizationId, [FromQuery] string userId, [FromQuery] UserRole role)
        {
            try
            {
                var organization = await _context.Organizations
                    .FirstOrDefaultAsync(o => o.Id == organizationId && !o.IsDeleted);

                if (organization == null) return NotFound("Organization not found");

                var user = await _context.Users.FirstOrDefaultAsync(u => u.Uid == userId);
                if (user == null) return NotFound("User not found");

                var existingRole = await _context.UserOrganizationRoles
                    .FirstOrDefaultAsync(uor => uor.UserId == userId && uor.OrganizationId == organizationId);

                if (existingRole != null)
                {
                    return BadRequest("User already has a role in this organization.");
                }

                var userRole = new UserOrganizationRole
                {
                    UserId = user.Id,
                    OrganizationId = organization.Id,
                    Role = role
                };

                _context.UserOrganizationRoles.Add(userRole);
                await _context.SaveChangesAsync();

                return Ok(new { organizationId = organization.Id, userId = user.Id, role = role });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteOrganization(string id)
        {
            try
            {
                var organization = await _context.Organizations.FindAsync(id);
                if (organization == null) return NotFound("Organization not found");

                organization.IsDeleted = true;
                await _context.SaveChangesAsync();

                return Ok("Organization marked as deleted");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }
    }
}

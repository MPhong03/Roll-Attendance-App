using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using RollAttendanceServer.Data;
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

        [HttpPost("CreateOrganization")]
        public async Task<IActionResult> CreateOrganization([FromBody] OrganizationDTO dto)
        {
            try
            {
                var existingOrganization = await _context.Organizations
                    .FirstOrDefaultAsync(o => o.Name == dto.Name && !o.IsDeleted);

                if (existingOrganization != null)
                {
                    return BadRequest("Organization with the same name already exists.");
                }

                var organization = new Organization
                {
                    Id = Guid.NewGuid().ToString("N").ToUpper(),
                    Name = dto.Name,
                    Description = dto.Description,
                    Address = dto.Address,
                    IsDeleted = false
                };

                _context.Organizations.Add(organization);
                await _context.SaveChangesAsync();

                // Thêm User vào Representatives
                var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == dto.UserId);
                if (user != null)
                {
                    organization.Representatives.Add(user);
                    await _context.SaveChangesAsync();
                }

                return CreatedAtAction(nameof(CreateOrganization), new { id = organization.Id }, organization);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        [HttpPut("UpdateOrganization/{id}")]
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

        [HttpPost("AddUser/{id}")]
        public async Task<IActionResult> AddUser(string id, [FromQuery] string userId)
        {
            try
            {
                var organization = await _context.Organizations.Include(o => o.Users).FirstOrDefaultAsync(o => o.Id == id);
                if (organization == null || organization.IsDeleted) return NotFound("Organization not found");

                var user = await _context.Users.FindAsync(userId);
                if (user == null) return NotFound("User not found");

                organization.Users.Add(user);
                await _context.SaveChangesAsync();

                return Ok(organization);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        [HttpPost("AddToOrganizers/{id}")]
        public async Task<IActionResult> AddToOrganizers(string id, [FromQuery] string userId)
        {
            try
            {
                var organization = await _context.Organizations.Include(o => o.Organizers).FirstOrDefaultAsync(o => o.Id == id);
                if (organization == null || organization.IsDeleted) return NotFound("Organization not found");

                var user = await _context.Users.FindAsync(userId);
                if (user == null) return NotFound("User not found");

                organization.Organizers.Add(user);
                await _context.SaveChangesAsync();

                return Ok(organization);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        [HttpPost("AddToRepresentatives/{id}")]
        public async Task<IActionResult> AddToRepresentatives(string id, [FromQuery] string userId)
        {
            try
            {
                var organization = await _context.Organizations.Include(o => o.Representatives).FirstOrDefaultAsync(o => o.Id == id);
                if (organization == null || organization.IsDeleted) return NotFound("Organization not found");

                var user = await _context.Users.FindAsync(userId);
                if (user == null) return NotFound("User not found");

                organization.Representatives.Add(user);
                await _context.SaveChangesAsync();

                return Ok(organization);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        [HttpDelete("DeleteOrganization/{id}")]
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

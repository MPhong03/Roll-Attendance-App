using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using RollAttendanceServer.Interfaces;
using RollAttendanceServer.Services.Systems;

namespace RollAttendanceServer.Controllers
{
    [Authorize(AuthenticationSchemes = "Firebase")]
    [Route("api/[controller]")]
    [ApiController]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _userService;

        public UsersController(IUserService userService)
        {
            _userService = userService;
        }

        [HttpGet("{email}")]
        public async Task<IActionResult> GetUserByEmail(string email)
        {
            try
            {
                var user = await _userService.GetUserByEmailAsync(email);
                return Ok(user);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}

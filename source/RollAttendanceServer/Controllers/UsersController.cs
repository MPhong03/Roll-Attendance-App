using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using RollAttendanceServer.Data.Requests;
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

        [HttpGet("fcm-token")]
        public async Task<IActionResult> GetUserFCMToken()
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized("Invalid user.");
                }

                var token = await _userService.GetUserFCMTokenAsync(userId);

                return Ok(token);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("fcm-token")]
        public async Task<IActionResult> UpdateUserFCMToken([FromBody] FCMTokenRequest request)
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized("Invalid user.");
                }

                await _userService.UpdateUserFCMTokenAsync(userId, request.Token);
                return Ok(new { message = "Update FCM Token Successfully!", token = request.Token });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}

using FirebaseAdmin.Auth;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RollAttendanceServer.Data;
using RollAttendanceServer.DTOs;
using RollAttendanceServer.Models;
using RollAttendanceServer.Services;
using System.Diagnostics;

namespace RollAttendanceServer.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly JwtService _jwtService;

        public AuthController(ApplicationDbContext context, JwtService jwtService)
        {
            _context = context;
            _jwtService = jwtService;
        }
        //// DEPRECATED
        //[HttpPost("register")]
        //public async Task<IActionResult> Register(User user)
        //{
        //    try
        //    {
        //        // Check if email already exists
        //        if (await _context.Users.AnyAsync(u => u.Email == user.Email))
        //            return BadRequest("Email already exists.");

        //        // Hash the password
        //        user.Password = BCrypt.Net.BCrypt.HashPassword(user.Password);

        //        // Add user to database
        //        _context.Users.Add(user);
        //        await _context.SaveChangesAsync();

        //        return Ok("User registered successfully.");
        //    }
        //    catch (Exception ex)
        //    {
        //        return BadRequest(ex.Message);
        //    }
        //}
        //// DEPRECATED
        //[HttpPost("login")]
        //public async Task<IActionResult> Login([FromBody] User loginUser)
        //{
        //    try
        //    {
        //        var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == loginUser.Email);
        //        if (user == null || !BCrypt.Net.BCrypt.Verify(loginUser.Password, user.Password))
        //            return Unauthorized("Invalid email or password.");

        //        var accessToken = _jwtService.GenerateAccessToken(user);
        //        var refreshToken = _jwtService.GenerateRefreshToken();

        //        return Ok(new { accessToken, refreshToken });
        //    }
        //    catch (Exception ex)
        //    {
        //        return BadRequest(ex.Message);
        //    }
        //}
        //// DEPRECATED
        //[HttpPost("change-password")]
        //public async Task<IActionResult> changePassword([FromBody] NewPasswordDTO data)
        //{
        //    try
        //    {
        //        // Validate input
        //        if (string.IsNullOrEmpty(data.CurrentPassword) || string.IsNullOrEmpty(data.NewPassword) || string.IsNullOrEmpty(data.ConfirmPassword))
        //            return BadRequest("Password are required.");

        //        if (!((data.NewPassword).Equals(data.ConfirmPassword)))
        //            return BadRequest("Password isn't matched.");

        //        // Get the current user's ID (from JWT or Authorization header)
        //        var userIdClaim = User.Claims.FirstOrDefault(c => c.Type == "Id");
        //        if (userIdClaim == null)
        //            return Unauthorized("User is not authenticated.");

        //        int userId = int.Parse(userIdClaim.Value);

        //        // Find the user
        //        var user = await _context.Users.FindAsync(userId);
        //        if (user == null)
        //            return NotFound("User not found.");

        //        // Verify the old password
        //        if (!BCrypt.Net.BCrypt.Verify(data.CurrentPassword, user.Password))
        //            return Unauthorized("Current password is incorrect.");

        //        // Hash the new password
        //        user.Password = BCrypt.Net.BCrypt.HashPassword(data.NewPassword);

        //        // Save the updated password
        //        _context.Users.Update(user);
        //        await _context.SaveChangesAsync();

        //        return Ok("Password updated successfully.");
        //    }
        //    catch (Exception ex)
        //    {
        //        return BadRequest(ex.Message);
        //    }
        //}

        [HttpPost("new-profile")]
        public async Task<IActionResult> createProfile([FromBody] NewProfileDTO data)
        {
            try
            {
                if (string.IsNullOrEmpty(data.Email) || string.IsNullOrEmpty(data.Uid))
                    return BadRequest("Email are required.");

                if (await _context.Users.AnyAsync(u => u.Email == data.Email))
                    return BadRequest("Email already exists.");

                var user = new User
                {
                    Uid = data.Uid,
                    Email = data.Email,
                };

                _context.Users.Add(user);
                await _context.SaveChangesAsync();

                return Ok("User profile registered successfully."); ;
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpGet("test-authorization")]
        [Authorize(AuthenticationSchemes = "Firebase")]
        public IActionResult TestUser()
        {
            var user = User.Identity;
            return Ok($"Hello {user?.Name}, your API access is authorized!");
        }

        [HttpGet("profile")]
        [Authorize(AuthenticationSchemes = "Firebase")]
        public async Task<IActionResult> GetProfile()
        {
            try
            {
                var identity = User.Identity;

                if (identity == null) return BadRequest("Unauthorized");

                UserRecord user = await FirebaseAuth.DefaultInstance.GetUserAsync(identity?.Name);

                return Ok(new
                {
                    user.Uid,
                    user.Email,
                    user.DisplayName,
                    user.PhotoUrl,
                    user.EmailVerified
                });
            }
            catch (FirebaseAuthException ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }

        private bool UserExists(int id)
        {
            return _context.Users.Any(e => e.Id == id);
        }
    }
}

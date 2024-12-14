using CloudinaryDotNet;
using FirebaseAdmin.Auth;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RollAttendanceServer.Data;
using RollAttendanceServer.DTOs;
using RollAttendanceServer.Interfaces;
using RollAttendanceServer.Models;
using RollAttendanceServer.Services.Systems;
using System.Diagnostics;
using System.Security.Claims;

namespace RollAttendanceServer.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly IJwtService _jwtService;
        private readonly ICloudinaryService _cloudinaryService;
        private readonly IRoleService _roleService;

        public AuthController(IUserService userService, IJwtService jwtService, ICloudinaryService cloudinaryService, IRoleService roleService)
        {
            _userService = userService;
            _jwtService = jwtService;
            _cloudinaryService = cloudinaryService;
            _roleService = roleService;
        }

        [HttpGet("profile")]
        [Authorize(AuthenticationSchemes = "Firebase")]
        public async Task<IActionResult> GetProfile()
        {
            try
            {
                var identity = User.Identity;

                if (identity == null) return BadRequest("Unauthorized");

                // Lấy thông tin người dùng từ Firebase
                UserRecord firebaseUser = await FirebaseAuth.DefaultInstance.GetUserAsync(identity?.Name);

                // Lấy thông tin người dùng từ bảng User theo Uid
                var user = await _userService.GetUserByUidAsync(firebaseUser.Uid);

                if (user == null)
                {
                    return NotFound(new { message = "User not found in the system." });
                }

                return Ok(new
                {
                    firebaseUser.Uid,
                    firebaseUser.Email,
                    firebaseUser.DisplayName,
                    firebaseUser.PhotoUrl,
                    firebaseUser.EmailVerified,
                    Profile = user
                });
            }
            catch (FirebaseAuthException ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }

        [HttpPost("new-profile")]
        public async Task<IActionResult> CreateProfile([FromBody] NewProfileDTO data)
        {
            if (string.IsNullOrEmpty(data.Email) || string.IsNullOrEmpty(data.Uid))
                return BadRequest("Email and Uid are required.");

            if (await _userService.IsEmailExistsAsync(data.Email))
                return BadRequest("Email already exists.");

            var user = new User { Uid = data.Uid, Email = data.Email };
            await _userService.CreateUserAsync(user);

            return Ok("User profile registered successfully.");
        }

        [HttpGet("roles")]
        public async Task<IActionResult> GetRoles()
        {
            var roles = await _roleService.GetAllRolesAsync();
            if (!roles.Any())
                return NotFound("No roles found.");

            return Ok(roles);
        }

        [HttpPost("upload-profile-image")]
        [Authorize(AuthenticationSchemes = "Firebase")]
        public async Task<IActionResult> UploadProfileImage(IFormFile file)
        {
            if (file == null || file.Length == 0)
                return BadRequest("No file uploaded.");

            var identity = User.Identity;
            if (identity == null)
                return Unauthorized("User is not authenticated.");

            string uid = identity.Name;
            string fileName = $"{uid}_{DateTime.UtcNow:yyyyMMddHHmmss}.jpg";

            using var stream = file.OpenReadStream();
            string url = await _cloudinaryService.UploadImageAsync(stream, fileName, uid);

            return Ok(new { message = "Profile image uploaded successfully.", url });
        }

        [HttpPut("facedata")]
        [Authorize(AuthenticationSchemes = "Firebase")]
        public async Task<IActionResult> UpdateFaceData([FromBody] FaceVectorDTO dto)
        {
            try
            {
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

                Debug.WriteLine("UserID:", userId);

                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized("Invalid user.");
                }

                if (string.IsNullOrEmpty(dto.FaceData))
                {
                    return BadRequest("Invalid face data");
                }

                await _userService.UpdateUserFaceData(userId, dto.FaceData);

                return Ok(new { message = "Face data updated successfully." });
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPut("shareProfile")]
        [Authorize(AuthenticationSchemes = "Firebase")]
        public async Task<IActionResult> ShareProfile()
        {
            try
            {
                var identity = User.Identity;

                if (identity == null)
                {
                    return Unauthorized("Unauthorized");
                }

                UserRecord firebaseUser = await FirebaseAuth.DefaultInstance.GetUserAsync(identity?.Name);

                if (firebaseUser == null)
                {
                    return NotFound(new { message = "User not found in Firebase." });
                }

                var user = await _userService.GetUserByUidAsync(firebaseUser.Uid);

                if (user == null)
                {
                    return NotFound(new { message = "User not found in the system." });
                }

                user.DisplayName = firebaseUser.DisplayName ?? user.DisplayName;
                user.PhoneNumber = firebaseUser.PhoneNumber ?? user.PhoneNumber;
                user.Avatar = firebaseUser.PhotoUrl ?? user.Avatar;

                await _userService.UpdateUserAsync(user);

                return Ok(new
                {
                    message = "User profile updated successfully.",
                    Profile = user
                });
            }
            catch (FirebaseAuthException ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }

    }
}

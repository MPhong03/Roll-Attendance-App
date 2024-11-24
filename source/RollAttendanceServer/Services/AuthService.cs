using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.EntityFrameworkCore;
using RollAttendanceServer.Authentication;
using RollAttendanceServer.Data;
using RollAttendanceServer.DTOs;
using System;
using System.Diagnostics;
using System.Security.Claims;

namespace RollAttendanceServer.Services
{
    public class AuthService
    {
        private readonly ApplicationDbContext _context;
        private readonly CustomAuthenticationStateProvider _authenticationStateProvider; 

        public AuthService(ApplicationDbContext context,
                           CustomAuthenticationStateProvider authenticationStateProvider)
        {
            _context = context;
            _authenticationStateProvider = authenticationStateProvider;
        }

        public async Task<AuthenticationResponse> LoginAsync(LoginDTO model)
        {
            try
            {
                var user = await _context.Admins
                    .Include(u => u.Role)
                    .ThenInclude(r => r.Permissions)
                    .FirstOrDefaultAsync(u => u.Email == model.Email);

                if (user == null)
                {
                    return new AuthenticationResponse
                    {
                        Success = false,
                        Message = "Invalid email or password."
                    };
                }

                if (!BCrypt.Net.BCrypt.Verify(model.Password, user.Password))
                {
                    return new AuthenticationResponse
                    {
                        Success = false,
                        Message = "Invalid email or password."
                    };
                }

                var userSession = new UserSession
                {
                    Email = user.Email,
                    RoleId = user.Role.Id,
                    Permissions = user.Role.Permissions.Select(p => p.PermissionValue).ToList(),
                };

                // Update AuthenticationState with the new session
                await _authenticationStateProvider.UpdateAuthenticationState(userSession);

                return new AuthenticationResponse
                {
                    Success = true,
                    Message = "Login successful."
                };
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Error during login: {ex.Message}");
                return new AuthenticationResponse
                {
                    Success = false,
                    Message = "An unexpected error occurred."
                };
            }
        }

        public async Task<AuthenticationResponse> LogoutAsync()
        {
            try
            {
                await _authenticationStateProvider.UpdateAuthenticationState(null);

                return new AuthenticationResponse
                {
                    Success = true,
                    Message = "Logout successful."
                };
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Error during logout: {ex.Message}");
                return new AuthenticationResponse
                {
                    Success = false,
                    Message = "An unexpected error occurred during logout."
                };
            }
        }
    }
}

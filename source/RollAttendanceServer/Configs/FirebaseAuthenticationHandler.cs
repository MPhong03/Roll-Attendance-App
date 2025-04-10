﻿using FirebaseAdmin.Auth;
using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Options;
using RollAttendanceServer.Interfaces;
using RollAttendanceServer.Models;
using System.Security.Claims;
using System.Text.Encodings.Web;

namespace RollAttendanceServer.Configs
{
    public class FirebaseAuthenticationHandler : AuthenticationHandler<AuthenticationSchemeOptions>
    {
        private readonly IUserService _userService;

        public FirebaseAuthenticationHandler(
            IOptionsMonitor<AuthenticationSchemeOptions> options,
            ILoggerFactory logger,
            UrlEncoder encoder,
            ISystemClock clock,
            IUserService userService)
            : base(options, logger, encoder, clock)
        {
            _userService = userService;
        }

        protected override async Task<AuthenticateResult> HandleAuthenticateAsync()
        {
            var authorizationHeader = Request.Headers["Authorization"].ToString();

            if (string.IsNullOrEmpty(authorizationHeader) || !authorizationHeader.StartsWith("Bearer "))
            {
                return AuthenticateResult.Fail("Missing or invalid Authorization header.");
            }

            var idToken = authorizationHeader.Substring("Bearer ".Length);

            try
            {
                // Verify Firebase ID token
                var decodedToken = await FirebaseAuth.DefaultInstance.VerifyIdTokenAsync(idToken);

                var user = await _userService.GetUserByUidAsync(decodedToken.Uid);

                if (user == null)
                {
                    return AuthenticateResult.Fail("User not found in the system.");
                }

                // Create user claims
                var claims = new List<Claim>
                {
                    new Claim(ClaimTypes.Name, decodedToken.Uid), // Firebase Uid
                    new Claim("email", decodedToken.Claims.ContainsKey("email") ? decodedToken.Claims["email"].ToString() : string.Empty),
                    new Claim(ClaimTypes.NameIdentifier, user.Id) // UserId 
                };

                foreach (var claim in decodedToken.Claims)
                {
                    claims.Add(new Claim(claim.Key, claim.Value.ToString()));
                }

                var claimsIdentity = new ClaimsIdentity(claims, nameof(FirebaseAuthenticationHandler));
                var ticket = new AuthenticationTicket(new ClaimsPrincipal(claimsIdentity), Scheme.Name);

                return AuthenticateResult.Success(ticket);
            }
            catch (Exception ex)
            {
                return AuthenticateResult.Fail($"Token validation failed: {ex.Message}");
            }
        }
    }

}

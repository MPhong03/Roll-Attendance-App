using FirebaseAdmin;
using FirebaseAdmin.Auth;
using Google.Apis.Auth.OAuth2;
using Microsoft.EntityFrameworkCore;
using RollAttendanceServer.Data;
using RollAttendanceServer.Models;
using System.Security.Claims;

namespace RollAttendanceServer.Services
{
    public class FirebaseAuthService
    {
        private readonly FirebaseAuth _firebaseAuth;
        public FirebaseAuthService(IConfiguration configuration)
        {
            var pathToCredentials = configuration.GetValue<string>("Firebase:CredentialsPath");

            FirebaseApp.Create(new AppOptions()
            {
                Credential = GoogleCredential.FromFile(pathToCredentials),
            });
            _firebaseAuth = FirebaseAuth.DefaultInstance;
        }
        public async Task<UserRecord> VerifyIdTokenAsync(string idToken)
        {
            try
            {
                var decodedToken = await _firebaseAuth.VerifyIdTokenAsync(idToken);
                var uid = decodedToken.Uid;
                return await _firebaseAuth.GetUserAsync(uid);
            }
            catch (Exception ex)
            {
                throw new UnauthorizedAccessException("Invalid Firebase token", ex);
            }
        }
    }
}

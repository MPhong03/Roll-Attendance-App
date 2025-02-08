using Microsoft.EntityFrameworkCore;
using RollAttendanceServer.Data;
using RollAttendanceServer.Interfaces;
using RollAttendanceServer.Models;

namespace RollAttendanceServer.Services.Systems
{
    public class UserService : IUserService
    {
        private readonly ApplicationDbContext _context;

        public UserService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<bool> IsEmailExistsAsync(string email)
        {
            return await _context.Users.AnyAsync(u => u.Email == email);
        }

        public async Task CreateUserAsync(User user)
        {
            _context.Users.Add(user);
            await _context.SaveChangesAsync();
        }

        public async Task<User?> GetUserByEmailAsync(string email)
        {
            return await _context.Users.FirstOrDefaultAsync(u => u.Email == email);
        }

        public async Task<User?> GetUserByUidAsync(string uid)
        {
            return await _context.Users.FirstOrDefaultAsync(u => u.Uid == uid);
        }

        public async Task UpdateUserFaceData(string id, string faceData)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == id);

            if (user == null)
            {
                throw new Exception("User not found.");
            }

            user.FaceData = faceData;
            await _context.SaveChangesAsync();
        }
        public async Task UpdateUserAsync(User user)
        {
            _context.Users.Update(user);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateUserFCMTokenAsync(string userId, string token)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null)
            {
                throw new Exception("User not found.");
            }

            user.FCMToken = token;
            await _context.SaveChangesAsync();
        }

        public async Task<string> GetUserFCMTokenAsync(string userId)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null)
            {
                throw new Exception("User not found.");
            }

            return user.FCMToken;
        }
    }
}

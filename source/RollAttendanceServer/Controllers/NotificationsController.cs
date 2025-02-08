using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using RollAttendanceServer.Interfaces;

namespace RollAttendanceServer.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class NotificationsController : ControllerBase
    {
        private readonly INotificationService _notificationService;

        public NotificationsController(INotificationService notificationService)
        {
            _notificationService = notificationService;
        }

        [HttpPost("test")]
        public async Task<IActionResult> SendNotificationToAll([FromBody] TestNotificationRequest request)
        {
            var successCount = await _notificationService.SendNotificationToAllAsync(request.Title, request.Body);

            if (successCount > 0)
            {
                return Ok(new { message = $"Đã gửi thông báo thành công đến {successCount} người dùng." });
            }

            return BadRequest("Không có người dùng hợp lệ để gửi thông báo.");
        }
    }

    public class TestNotificationRequest
    {
        public string Title { get; set; } = "Test";
        public string Body { get; set; } = "Test";
    }
}

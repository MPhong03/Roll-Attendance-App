using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using RollAttendanceServer.Interfaces;
using RollAttendanceServer.Services.Systems;

namespace RollAttendanceServer.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class HistoriesController : ControllerBase
    {
        private readonly IHistoryService _historyService;

        public HistoriesController(IHistoryService historyService)
        {
            _historyService = historyService;
        }

        [HttpGet("{eventId}")]
        public async Task<IActionResult> GetEventHistoryDetail(string eventId)
        {
            try
            {
                var history = await _historyService.GetHistoryByEventIdAsync(eventId);
                if (history == null)
                {
                    return NotFound("Event history detail not found.");
                }

                return Ok(history);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("{eventId}/all")]
        public async Task<IActionResult> GetEventHistoriesDetail(string eventId)
        {
            try
            {
                var histories = await _historyService.GetHistoriesByEventIdAsync(eventId);
                if (histories == null)
                {
                    return NotFound("Event histories not found.");
                }

                return Ok(histories);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpGet("details/{historyId}")]
        public async Task<IActionResult> GetHistoryDetails(
            string historyId,
            [FromQuery] string? keyword,
            [FromQuery] int pageIndex = 1,
            [FromQuery] int pageSize = 10)
        {
            try
            {
                var details = await _historyService.GetHistoryDetailsByHistoryIdAsync(historyId, pageIndex, pageSize, keyword);
                return Ok(details);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
}

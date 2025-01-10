﻿using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using RollAttendanceServer.Interfaces;
using System.Security.Claims;

namespace RollAttendanceServer.Controllers
{
    [Authorize(AuthenticationSchemes = "Firebase")]
    [Route("api/[controller]")]
    [ApiController]
    public class ParticipationRequestsController : ControllerBase
    {
        private readonly IParticipationRequestService _participationRequestService;

        public ParticipationRequestsController(IParticipationRequestService participationRequestService)
        {
            _participationRequestService = participationRequestService;
        }

        [HttpGet]
        public async Task<IActionResult> GetParticipationRequests([FromQuery] ParticipationQuery query)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userId))
            {
                return Unauthorized("Không thể xác thực người dùng.");
            }

            try
            {
                var result = await _participationRequestService.GetParticipationRequestsAsync(
                    query.UserId ?? userId,
                    query.OrganizationId,
                    query.Keyword,
                    query.Status,
                    query.PageIndex,
                    query.PageSize
                );

                return Ok(new
                {
                    Message = "Danh sách yêu cầu tham gia",
                    Data = result.Items,
                    result.TotalRecords,
                    result.PageIndex,
                    result.PageSize
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }

        [HttpPost("create")]
        public async Task<IActionResult> CreateParticipationRequest([FromBody] CreateParticipationRequestDto requestDto)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userId))
            {
                return Unauthorized("Không thể xác thực người dùng.");
            }

            try
            {
                var requestId = await _participationRequestService.CreateParticipationRequestAsync(userId, requestDto.OrganizationId, requestDto.Notes);
                return Ok(new { Message = "Yêu cầu đã được tạo.", RequestId = requestId });
            }
            catch (Exception ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }

        [HttpPut("status")]
        public async Task<IActionResult> ApproveOrRejectRequest([FromBody] ApproveOrRejectRequestDto requestDto)
        {
            try
            {
                await _participationRequestService.ApproveOrRejectRequestAsync(requestDto.RequestId, requestDto.NewStatus);
                return Ok(new { Message = "Trạng thái yêu cầu đã được cập nhật." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }

        [HttpPut("cancel")]
        public async Task<IActionResult> CancelRequest([FromBody] CancelRequestDto requestDto)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userId))
            {
                return Unauthorized("Không thể xác thực người dùng.");
            }

            try
            {
                await _participationRequestService.CancelRequestAsync(requestDto.RequestId, userId);
                return Ok(new { Message = "Yêu cầu đã được hủy." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { Message = ex.Message });
            }
        }
    }
    public class CreateParticipationRequestDto
    {
        public string OrganizationId { get; set; } = string.Empty;
        public string? Notes { get; set; }
    }

    public class ApproveOrRejectRequestDto
    {
        public string RequestId { get; set; } = string.Empty;
        public short NewStatus { get; set; }
    }

    public class CancelRequestDto
    {
        public string RequestId { get; set; } = string.Empty;
    }

    public class ParticipationQuery
    {
        public string? UserId { get; set; }
        public string? OrganizationId { get; set; }
        public string? Keyword { get; set; }
        public int Status { get; set; }
        public int PageIndex { get; set; } = 1;
        public int PageSize { get; set; } = 10;
    }
}

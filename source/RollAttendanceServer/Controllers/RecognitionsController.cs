using System.Drawing;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using RollAttendanceServer.Helpers;
using RollAttendanceServer.Interfaces;

namespace RollAttendanceServer.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class RecognitionsController : ControllerBase
    {
        private readonly IFaceRecognitionService _faceRecognition;

        public RecognitionsController(IFaceRecognitionService faceRecognition)
        {
            _faceRecognition = faceRecognition;
        }

        [HttpPost("extract")]
        public async Task<IActionResult> ExtractFeature([FromForm] FeaturesExtractionRequest request)
        {
            if (request.image == null || request.image.Length == 0)
            {
                return BadRequest("No image uploaded.");
            }

            try
            {
                using var stream = request.image.OpenReadStream();
                using var bitmap = new Bitmap(stream);

                float[] imageArray = Tools.ConvertImageToFloatArray(bitmap);

                float[] features = await _faceRecognition.ExtractFeatureAsync(imageArray);

                return Ok(new { features });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error processing image: {ex.Message}");
            }
        }
    }

    public class FeaturesExtractionRequest
    {
        public IFormFile? image { get; set; }
    }
}

using Microsoft.ML.OnnxRuntime.Tensors;
using Microsoft.ML.OnnxRuntime;

namespace RollAttendanceServer.Services.Systems
{
    using System.Diagnostics;
    using System.Linq;
    using Microsoft.ML.OnnxRuntime;
    using Microsoft.ML.OnnxRuntime.Tensors;
    using RollAttendanceServer.Interfaces;

    public class FaceRecognitionService : IFaceRecognitionService
    {
        private readonly InferenceSession _session;

        public FaceRecognitionService()
        {
            var modelPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "models", "facenet.onnx");
            _session = new InferenceSession(modelPath);
        }

        public async Task<float[]> ExtractFeatureAsync(float[] image)
        {
            return await Task.Run(() =>
            {
                using var results = _session.Run(new List<NamedOnnxValue>
                {
                    NamedOnnxValue.CreateFromTensor("image_input", new DenseTensor<float>(image, new[] { 1, 160, 160, 3 }))
                });

                return results.First().AsTensor<float>().ToArray();
            });
        }
    }
}

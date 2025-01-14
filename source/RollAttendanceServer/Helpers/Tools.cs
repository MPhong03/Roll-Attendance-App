using Newtonsoft.Json;

namespace RollAttendanceServer.Helpers
{
    public static class Tools
    {
        public static string GenerateUniqueCode()
        {
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            var random = new Random();
            return new string(Enumerable.Range(0, 6)
                .Select(_ => chars[random.Next(chars.Length)])
                .ToArray());
        }

        public static string? FindMatchingUser(string inputFaceData, Dictionary<string, string> userFaceData)
        {
            var inputVector = JsonConvert.DeserializeObject<List<float>>(inputFaceData);
            if (inputVector == null) return null;

            string? bestMatchUserId = null;
            double highestSimilarity = 0.0;

            foreach (var (userId, faceVectorData) in userFaceData)
            {
                var userVector = JsonConvert.DeserializeObject<List<float>>(faceVectorData);
                if (userVector == null) continue;

                var similarity = CalculateCosineSimilarity(inputVector, userVector);
                if (similarity > highestSimilarity)
                {
                    highestSimilarity = similarity;
                    bestMatchUserId = userId;
                }
            }

            return highestSimilarity > 0.9 ? bestMatchUserId : null;
        }

        // Hàm tính cosine similarity
        public static double CalculateCosineSimilarity(List<float> vectorA, List<float> vectorB)
        {
            if (vectorA.Count != vectorB.Count)
                throw new ArgumentException("Vectors must have the same dimensions.");

            var dotProduct = vectorA.Zip(vectorB, (a, b) => a * b).Sum();
            var magnitudeA = Math.Sqrt(vectorA.Sum(a => a * a));
            var magnitudeB = Math.Sqrt(vectorB.Sum(b => b * b));

            return dotProduct / (magnitudeA * magnitudeB);
        }
    }
}

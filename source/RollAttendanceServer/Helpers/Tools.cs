using Newtonsoft.Json;
using System.Diagnostics;

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
            var inputVector = JsonConvert.DeserializeObject<List<List<float>>>(inputFaceData);
            if (inputVector == null) return null;

            string? bestMatchUserId = null;
            double highestSimilarity = 0.0;

            foreach (var (userId, faceVectorData) in userFaceData)
            {
                var userVector = JsonConvert.DeserializeObject<List<List<float>>>(faceVectorData);
                if (userVector == null) continue;
                Debug.WriteLine("VECTOR 1: ", inputVector);
                Debug.WriteLine("VECTOR 2: ", userVector);
                var similarity = CalculateCosineSimilarity(inputVector[0], userVector[0]);
                Debug.WriteLine("NUM: ", similarity);
                if (similarity > highestSimilarity)
                {
                    highestSimilarity = similarity;
                    bestMatchUserId = userId;
                }
            }

            Debug.WriteLine("SIMILITARI: ", highestSimilarity);
            Debug.WriteLine("USERID: ", bestMatchUserId);

            return highestSimilarity > 0.8 ? bestMatchUserId : null;
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

        // Hàm tính khoảng cách
        public static double CalculateDistance(double lat1, double lon1, double lat2, double lon2)
        {
            const double R = 6371000; // Bán kính Trái Đất (mét)
            double dLat = (lat2 - lat1) * Math.PI / 180.0;
            double dLon = (lon2 - lon1) * Math.PI / 180.0;

            double a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
                       Math.Cos(lat1 * Math.PI / 180.0) * Math.Cos(lat2 * Math.PI / 180.0) *
                       Math.Sin(dLon / 2) * Math.Sin(dLon / 2);

            double c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
            return R * c;
        }
    }
}

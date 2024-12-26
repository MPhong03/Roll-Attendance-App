using FirebaseAdmin.Auth;

namespace RollAttendanceServer.Middlewares
{
    // NO USE
    public class FirebaseAuthMiddlewares
    {
        private readonly RequestDelegate _next;
        public FirebaseAuthMiddlewares(RequestDelegate next)
        {
            _next = next;
        }
        public async Task Invoke(HttpContext context)
        {
            var authorizationHeader = context.Request.Headers["Authorization"].ToString();

            if (string.IsNullOrEmpty(authorizationHeader) || !authorizationHeader.StartsWith("Bearer "))
            {
                context.Response.StatusCode = 401; // Unauthorized
                await context.Response.WriteAsync("Missing or invalid Authorization header.");
                return;
            }

            var idToken = authorizationHeader.Substring("Bearer ".Length);

            try
            {
                // Verify the token
                var decodedToken = await FirebaseAuth.DefaultInstance.VerifyIdTokenAsync(idToken);
                context.Items["User"] = decodedToken;
            }
            catch (Exception ex)
            {
                context.Response.StatusCode = 401; // Unauthorized
                await context.Response.WriteAsync($"Token validation failed: {ex.Message}");
                return;
            }

            await _next(context);
        }
    }
}

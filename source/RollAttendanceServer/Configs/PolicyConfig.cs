using Microsoft.AspNetCore.Authorization;

namespace RollAttendanceServer.Configs
{
    public class PolicyConfig
    {
        public static void AddPolicies(AuthorizationOptions options)
        {
            options.AddPolicy("product_management", policy =>
                policy.RequireAssertion(context =>
                    context.User.HasClaim(c => c.Type == "Permission" && (c.Value == "admin" || c.Value == "product_management"))
                ));

            options.AddPolicy("customer_management", policy =>
                policy.RequireAssertion(context =>
                    context.User.HasClaim(c => c.Type == "Permission" && (c.Value == "admin" || c.Value == "customer_management"))
                ));
        }
    }
}

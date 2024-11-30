using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RollAttendanceServer.Migrations
{
    public partial class Update_4 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Admins",
                keyColumn: "Id",
                keyValue: "72C16393B1AD4935B44BD369631745A5");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "BD70289CA2ED4266968980B694D21A27");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "FB55885A201B412796D972DAE7671950");

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionsId", "RolesId" },
                keyValues: new object[] { "53282CBC94354B958B136762DDE33922", "62DB22F21EA34D37B05C4A880BBC9AFE" });

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "53282CBC94354B958B136762DDE33922");

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: "62DB22F21EA34D37B05C4A880BBC9AFE");

            migrationBuilder.InsertData(
                table: "Permissions",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "PermissionName", "PermissionValue", "UpdatedAt" },
                values: new object[,]
                {
                    { "59151214D15E4B24A6D2D24FABCC00BE", new DateTime(2024, 11, 28, 5, 11, 27, 285, DateTimeKind.Utc).AddTicks(6084), false, "User Management", "user_management", new DateTime(2024, 11, 28, 5, 11, 27, 285, DateTimeKind.Utc).AddTicks(6085) },
                    { "59CA68F4123844D782B6BFBFA93D7B90", new DateTime(2024, 11, 28, 5, 11, 27, 285, DateTimeKind.Utc).AddTicks(6091), false, "Administrator", "all_permissions", new DateTime(2024, 11, 28, 5, 11, 27, 285, DateTimeKind.Utc).AddTicks(6092) },
                    { "805344294E9B4C83AE224DDF951DFF01", new DateTime(2024, 11, 28, 5, 11, 27, 285, DateTimeKind.Utc).AddTicks(6072), false, "Organization Management", "organization_management", new DateTime(2024, 11, 28, 5, 11, 27, 285, DateTimeKind.Utc).AddTicks(6076) }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "RoleName", "UpdatedAt" },
                values: new object[] { "1D6180F4223041F09560FFC6D9DB5EDC", new DateTime(2024, 11, 28, 5, 11, 27, 285, DateTimeKind.Utc).AddTicks(6327), false, "Administrator", new DateTime(2024, 11, 28, 5, 11, 27, 285, DateTimeKind.Utc).AddTicks(6328) });

            migrationBuilder.InsertData(
                table: "Admins",
                columns: new[] { "Id", "Email", "IsDeleted", "Password", "Phone", "RoleId" },
                values: new object[] { "21839580CBF44FD496B00D4BE7FD86D8", "admin@gmail.com", false, "$2a$10$g6VWMvQ5ifZ0BwtaCwWW5uYQM027p/Olp.lkXBGBslFPFdUoBpjPO", "0000000000", "1D6180F4223041F09560FFC6D9DB5EDC" });

            migrationBuilder.InsertData(
                table: "RolePermissions",
                columns: new[] { "PermissionsId", "RolesId" },
                values: new object[] { "59CA68F4123844D782B6BFBFA93D7B90", "1D6180F4223041F09560FFC6D9DB5EDC" });
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Admins",
                keyColumn: "Id",
                keyValue: "21839580CBF44FD496B00D4BE7FD86D8");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "59151214D15E4B24A6D2D24FABCC00BE");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "805344294E9B4C83AE224DDF951DFF01");

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionsId", "RolesId" },
                keyValues: new object[] { "59CA68F4123844D782B6BFBFA93D7B90", "1D6180F4223041F09560FFC6D9DB5EDC" });

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "59CA68F4123844D782B6BFBFA93D7B90");

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: "1D6180F4223041F09560FFC6D9DB5EDC");

            migrationBuilder.InsertData(
                table: "Permissions",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "PermissionName", "PermissionValue", "UpdatedAt" },
                values: new object[,]
                {
                    { "53282CBC94354B958B136762DDE33922", new DateTime(2024, 11, 28, 5, 7, 20, 255, DateTimeKind.Utc).AddTicks(2882), false, "Administrator", "all_permissions", new DateTime(2024, 11, 28, 5, 7, 20, 255, DateTimeKind.Utc).AddTicks(2882) },
                    { "BD70289CA2ED4266968980B694D21A27", new DateTime(2024, 11, 28, 5, 7, 20, 255, DateTimeKind.Utc).AddTicks(2875), false, "User Management", "user_management", new DateTime(2024, 11, 28, 5, 7, 20, 255, DateTimeKind.Utc).AddTicks(2876) },
                    { "FB55885A201B412796D972DAE7671950", new DateTime(2024, 11, 28, 5, 7, 20, 255, DateTimeKind.Utc).AddTicks(2863), false, "Organization Management", "organization_management", new DateTime(2024, 11, 28, 5, 7, 20, 255, DateTimeKind.Utc).AddTicks(2866) }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "RoleName", "UpdatedAt" },
                values: new object[] { "62DB22F21EA34D37B05C4A880BBC9AFE", new DateTime(2024, 11, 28, 5, 7, 20, 255, DateTimeKind.Utc).AddTicks(3135), false, "Administrator", new DateTime(2024, 11, 28, 5, 7, 20, 255, DateTimeKind.Utc).AddTicks(3136) });

            migrationBuilder.InsertData(
                table: "Admins",
                columns: new[] { "Id", "Email", "IsDeleted", "Password", "Phone", "RoleId" },
                values: new object[] { "72C16393B1AD4935B44BD369631745A5", "admin@gmail.com", false, "$2a$10$/UCqfN.AooikYMAQgYWtA.68pk4rIPwMrnO3LkTOQaQzVy8K.4cj.", "0000000000", "62DB22F21EA34D37B05C4A880BBC9AFE" });

            migrationBuilder.InsertData(
                table: "RolePermissions",
                columns: new[] { "PermissionsId", "RolesId" },
                values: new object[] { "53282CBC94354B958B136762DDE33922", "62DB22F21EA34D37B05C4A880BBC9AFE" });
        }
    }
}

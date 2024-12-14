using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RollAttendanceServer.Migrations
{
    public partial class Update_12 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Admins",
                keyColumn: "Id",
                keyValue: "9251FE22196E471B9C0985E0985D0A27");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "183877446BB648C49CA11EFA50D5988F");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "2A98EC31848D44E0B04336B987D89EA9");

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionsId", "RolesId" },
                keyValues: new object[] { "4271BA388DD94E84B7F02A67CF5450C5", "F6778749B4164535B64A65F9CF5A0611" });

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "4271BA388DD94E84B7F02A67CF5450C5");

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: "F6778749B4164535B64A65F9CF5A0611");

            migrationBuilder.AddColumn<string>(
                name: "Avatar",
                table: "Users",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "DisplayName",
                table: "Users",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "PhoneNumber",
                table: "Users",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.InsertData(
                table: "Permissions",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "PermissionName", "PermissionValue", "UpdatedAt" },
                values: new object[,]
                {
                    { "149D878244E34D04BA61AE9A178B8E56", new DateTime(2024, 12, 14, 13, 0, 8, 817, DateTimeKind.Utc).AddTicks(922), false, "Organization Management", "organization_management", new DateTime(2024, 12, 14, 13, 0, 8, 817, DateTimeKind.Utc).AddTicks(926) },
                    { "15BF713FD26C4F9398507095FF51C9AB", new DateTime(2024, 12, 14, 13, 0, 8, 817, DateTimeKind.Utc).AddTicks(936), false, "User Management", "user_management", new DateTime(2024, 12, 14, 13, 0, 8, 817, DateTimeKind.Utc).AddTicks(936) },
                    { "63000FFDDB3944829A08E622B1AFBFB3", new DateTime(2024, 12, 14, 13, 0, 8, 817, DateTimeKind.Utc).AddTicks(943), false, "Administrator", "all_permissions", new DateTime(2024, 12, 14, 13, 0, 8, 817, DateTimeKind.Utc).AddTicks(944) }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "RoleName", "UpdatedAt" },
                values: new object[] { "C1EAD303A5B649E1A3F92ACA8736017A", new DateTime(2024, 12, 14, 13, 0, 8, 817, DateTimeKind.Utc).AddTicks(1196), false, "Administrator", new DateTime(2024, 12, 14, 13, 0, 8, 817, DateTimeKind.Utc).AddTicks(1196) });

            migrationBuilder.InsertData(
                table: "Admins",
                columns: new[] { "Id", "Email", "IsDeleted", "Password", "Phone", "RoleId" },
                values: new object[] { "E2AB6806E9604562ADDB268CC98ECCCC", "admin@gmail.com", false, "$2a$10$tk3JHgnmz2mqdW/cKCiUwuNrTql0vQLjaSHvEB7oJkIXBj6ybA2RO", "0000000000", "C1EAD303A5B649E1A3F92ACA8736017A" });

            migrationBuilder.InsertData(
                table: "RolePermissions",
                columns: new[] { "PermissionsId", "RolesId" },
                values: new object[] { "63000FFDDB3944829A08E622B1AFBFB3", "C1EAD303A5B649E1A3F92ACA8736017A" });
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Admins",
                keyColumn: "Id",
                keyValue: "E2AB6806E9604562ADDB268CC98ECCCC");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "149D878244E34D04BA61AE9A178B8E56");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "15BF713FD26C4F9398507095FF51C9AB");

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionsId", "RolesId" },
                keyValues: new object[] { "63000FFDDB3944829A08E622B1AFBFB3", "C1EAD303A5B649E1A3F92ACA8736017A" });

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "63000FFDDB3944829A08E622B1AFBFB3");

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: "C1EAD303A5B649E1A3F92ACA8736017A");

            migrationBuilder.DropColumn(
                name: "Avatar",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "DisplayName",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "PhoneNumber",
                table: "Users");

            migrationBuilder.InsertData(
                table: "Permissions",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "PermissionName", "PermissionValue", "UpdatedAt" },
                values: new object[,]
                {
                    { "183877446BB648C49CA11EFA50D5988F", new DateTime(2024, 12, 8, 7, 1, 45, 590, DateTimeKind.Utc).AddTicks(5035), false, "User Management", "user_management", new DateTime(2024, 12, 8, 7, 1, 45, 590, DateTimeKind.Utc).AddTicks(5036) },
                    { "2A98EC31848D44E0B04336B987D89EA9", new DateTime(2024, 12, 8, 7, 1, 45, 590, DateTimeKind.Utc).AddTicks(5027), false, "Organization Management", "organization_management", new DateTime(2024, 12, 8, 7, 1, 45, 590, DateTimeKind.Utc).AddTicks(5031) },
                    { "4271BA388DD94E84B7F02A67CF5450C5", new DateTime(2024, 12, 8, 7, 1, 45, 590, DateTimeKind.Utc).AddTicks(5038), false, "Administrator", "all_permissions", new DateTime(2024, 12, 8, 7, 1, 45, 590, DateTimeKind.Utc).AddTicks(5039) }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "RoleName", "UpdatedAt" },
                values: new object[] { "F6778749B4164535B64A65F9CF5A0611", new DateTime(2024, 12, 8, 7, 1, 45, 590, DateTimeKind.Utc).AddTicks(5176), false, "Administrator", new DateTime(2024, 12, 8, 7, 1, 45, 590, DateTimeKind.Utc).AddTicks(5176) });

            migrationBuilder.InsertData(
                table: "Admins",
                columns: new[] { "Id", "Email", "IsDeleted", "Password", "Phone", "RoleId" },
                values: new object[] { "9251FE22196E471B9C0985E0985D0A27", "admin@gmail.com", false, "$2a$10$TXogjLxkZ873vwYb7PMUQ./YuRjzLStNjumbNaVqJdOHx117gJQEq", "0000000000", "F6778749B4164535B64A65F9CF5A0611" });

            migrationBuilder.InsertData(
                table: "RolePermissions",
                columns: new[] { "PermissionsId", "RolesId" },
                values: new object[] { "4271BA388DD94E84B7F02A67CF5450C5", "F6778749B4164535B64A65F9CF5A0611" });
        }
    }
}

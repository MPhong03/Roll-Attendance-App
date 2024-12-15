using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RollAttendanceServer.Migrations
{
    public partial class Update_13 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
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

            migrationBuilder.AddColumn<string>(
                name: "Banner",
                table: "Organizations",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Image",
                table: "Organizations",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.InsertData(
                table: "Permissions",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "PermissionName", "PermissionValue", "UpdatedAt" },
                values: new object[,]
                {
                    { "3F0ED0A111904DAAB2DC5019C54C60AE", new DateTime(2024, 12, 15, 14, 43, 15, 702, DateTimeKind.Utc).AddTicks(1653), false, "User Management", "user_management", new DateTime(2024, 12, 15, 14, 43, 15, 702, DateTimeKind.Utc).AddTicks(1653) },
                    { "72881CF5D0D347C8B659F3A06DBE7BA5", new DateTime(2024, 12, 15, 14, 43, 15, 702, DateTimeKind.Utc).AddTicks(1661), false, "Administrator", "all_permissions", new DateTime(2024, 12, 15, 14, 43, 15, 702, DateTimeKind.Utc).AddTicks(1662) },
                    { "EC94F9A12E8544C29871387BF15B11EE", new DateTime(2024, 12, 15, 14, 43, 15, 702, DateTimeKind.Utc).AddTicks(1639), false, "Organization Management", "organization_management", new DateTime(2024, 12, 15, 14, 43, 15, 702, DateTimeKind.Utc).AddTicks(1644) }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "RoleName", "UpdatedAt" },
                values: new object[] { "B70B391820D94EBBBEB44F19C93B32A9", new DateTime(2024, 12, 15, 14, 43, 15, 702, DateTimeKind.Utc).AddTicks(1915), false, "Administrator", new DateTime(2024, 12, 15, 14, 43, 15, 702, DateTimeKind.Utc).AddTicks(1915) });

            migrationBuilder.InsertData(
                table: "Admins",
                columns: new[] { "Id", "Email", "IsDeleted", "Password", "Phone", "RoleId" },
                values: new object[] { "81BA6E331AB54D9A8A42A98A2F199DFF", "admin@gmail.com", false, "$2a$10$FBl77l9kWuZ45ZH8Aph94eTubbKfTfW0biTi7cuWgaDXYCqnY9rUW", "0000000000", "B70B391820D94EBBBEB44F19C93B32A9" });

            migrationBuilder.InsertData(
                table: "RolePermissions",
                columns: new[] { "PermissionsId", "RolesId" },
                values: new object[] { "72881CF5D0D347C8B659F3A06DBE7BA5", "B70B391820D94EBBBEB44F19C93B32A9" });
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Admins",
                keyColumn: "Id",
                keyValue: "81BA6E331AB54D9A8A42A98A2F199DFF");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "3F0ED0A111904DAAB2DC5019C54C60AE");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "EC94F9A12E8544C29871387BF15B11EE");

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionsId", "RolesId" },
                keyValues: new object[] { "72881CF5D0D347C8B659F3A06DBE7BA5", "B70B391820D94EBBBEB44F19C93B32A9" });

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "72881CF5D0D347C8B659F3A06DBE7BA5");

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: "B70B391820D94EBBBEB44F19C93B32A9");

            migrationBuilder.DropColumn(
                name: "Banner",
                table: "Organizations");

            migrationBuilder.DropColumn(
                name: "Image",
                table: "Organizations");

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
    }
}

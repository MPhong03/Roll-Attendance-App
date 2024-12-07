using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RollAttendanceServer.Migrations
{
    public partial class Update_8 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Admins",
                keyColumn: "Id",
                keyValue: "5CE2189538D341D48328B520329EE7AE");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "A08C2C8F2B5C4CA99FF42FF013315576");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "D9A4A692FEB145829512021775EDE80B");

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionsId", "RolesId" },
                keyValues: new object[] { "125D9635A26349DB90A8F0BB39E0A215", "79F8F7F26CE043A5877494050BC796F6" });

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "125D9635A26349DB90A8F0BB39E0A215");

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: "79F8F7F26CE043A5877494050BC796F6");

            migrationBuilder.CreateTable(
                name: "ParticipationRequests",
                columns: table => new
                {
                    Id = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    UserId = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    UserName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    UserEmail = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    OrganizationId = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    OrganizationName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ParticipationMethod = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ParticipationRequests", x => x.Id);
                });

            migrationBuilder.InsertData(
                table: "Permissions",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "PermissionName", "PermissionValue", "UpdatedAt" },
                values: new object[,]
                {
                    { "371130744553499396D8A6AC6C60EA00", new DateTime(2024, 12, 7, 13, 15, 24, 422, DateTimeKind.Utc).AddTicks(7400), false, "Administrator", "all_permissions", new DateTime(2024, 12, 7, 13, 15, 24, 422, DateTimeKind.Utc).AddTicks(7400) },
                    { "C69DC30C147B46D191E4A6042FBA6195", new DateTime(2024, 12, 7, 13, 15, 24, 422, DateTimeKind.Utc).AddTicks(7392), false, "User Management", "user_management", new DateTime(2024, 12, 7, 13, 15, 24, 422, DateTimeKind.Utc).AddTicks(7393) },
                    { "EFF353162A274424800514BF2EC9D089", new DateTime(2024, 12, 7, 13, 15, 24, 422, DateTimeKind.Utc).AddTicks(7374), false, "Organization Management", "organization_management", new DateTime(2024, 12, 7, 13, 15, 24, 422, DateTimeKind.Utc).AddTicks(7377) }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "RoleName", "UpdatedAt" },
                values: new object[] { "1AD94A5A259345C082476AFF77BDE845", new DateTime(2024, 12, 7, 13, 15, 24, 422, DateTimeKind.Utc).AddTicks(7622), false, "Administrator", new DateTime(2024, 12, 7, 13, 15, 24, 422, DateTimeKind.Utc).AddTicks(7622) });

            migrationBuilder.InsertData(
                table: "Admins",
                columns: new[] { "Id", "Email", "IsDeleted", "Password", "Phone", "RoleId" },
                values: new object[] { "4D7EE320B15B473FB8F71B16BD1F3016", "admin@gmail.com", false, "$2a$10$/dm0//qYN/4A0I/R9LymoOOFXZPqjFDPlg3v0yO5TWDe6oRrKQRA2", "0000000000", "1AD94A5A259345C082476AFF77BDE845" });

            migrationBuilder.InsertData(
                table: "RolePermissions",
                columns: new[] { "PermissionsId", "RolesId" },
                values: new object[] { "371130744553499396D8A6AC6C60EA00", "1AD94A5A259345C082476AFF77BDE845" });
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ParticipationRequests");

            migrationBuilder.DeleteData(
                table: "Admins",
                keyColumn: "Id",
                keyValue: "4D7EE320B15B473FB8F71B16BD1F3016");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "C69DC30C147B46D191E4A6042FBA6195");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "EFF353162A274424800514BF2EC9D089");

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionsId", "RolesId" },
                keyValues: new object[] { "371130744553499396D8A6AC6C60EA00", "1AD94A5A259345C082476AFF77BDE845" });

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "371130744553499396D8A6AC6C60EA00");

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: "1AD94A5A259345C082476AFF77BDE845");

            migrationBuilder.InsertData(
                table: "Permissions",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "PermissionName", "PermissionValue", "UpdatedAt" },
                values: new object[,]
                {
                    { "125D9635A26349DB90A8F0BB39E0A215", new DateTime(2024, 12, 5, 4, 42, 49, 209, DateTimeKind.Utc).AddTicks(7115), false, "Administrator", "all_permissions", new DateTime(2024, 12, 5, 4, 42, 49, 209, DateTimeKind.Utc).AddTicks(7115) },
                    { "A08C2C8F2B5C4CA99FF42FF013315576", new DateTime(2024, 12, 5, 4, 42, 49, 209, DateTimeKind.Utc).AddTicks(7111), false, "User Management", "user_management", new DateTime(2024, 12, 5, 4, 42, 49, 209, DateTimeKind.Utc).AddTicks(7111) },
                    { "D9A4A692FEB145829512021775EDE80B", new DateTime(2024, 12, 5, 4, 42, 49, 209, DateTimeKind.Utc).AddTicks(7103), false, "Organization Management", "organization_management", new DateTime(2024, 12, 5, 4, 42, 49, 209, DateTimeKind.Utc).AddTicks(7106) }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "RoleName", "UpdatedAt" },
                values: new object[] { "79F8F7F26CE043A5877494050BC796F6", new DateTime(2024, 12, 5, 4, 42, 49, 209, DateTimeKind.Utc).AddTicks(7232), false, "Administrator", new DateTime(2024, 12, 5, 4, 42, 49, 209, DateTimeKind.Utc).AddTicks(7233) });

            migrationBuilder.InsertData(
                table: "Admins",
                columns: new[] { "Id", "Email", "IsDeleted", "Password", "Phone", "RoleId" },
                values: new object[] { "5CE2189538D341D48328B520329EE7AE", "admin@gmail.com", false, "$2a$10$PtjBnVDUe4bQxzFIawQXwexxNKLzzFfxmw2tBNbv6eXIAnj3bMtnW", "0000000000", "79F8F7F26CE043A5877494050BC796F6" });

            migrationBuilder.InsertData(
                table: "RolePermissions",
                columns: new[] { "PermissionsId", "RolesId" },
                values: new object[] { "125D9635A26349DB90A8F0BB39E0A215", "79F8F7F26CE043A5877494050BC796F6" });
        }
    }
}

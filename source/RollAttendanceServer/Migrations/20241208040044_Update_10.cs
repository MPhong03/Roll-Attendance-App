using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RollAttendanceServer.Migrations
{
    public partial class Update_10 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Admins",
                keyColumn: "Id",
                keyValue: "776E9206B6C0464CA38AA988F5A98787");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "C4173A00F4C740F7A9E116AB4D9E8DDD");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "E5095EF218FF44E2844B28F7572552D1");

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionsId", "RolesId" },
                keyValues: new object[] { "69F84593B1A44CB4A65EBB513A7E0DB6", "C06B4B8F05384AD89EE102E2E838DB3C" });

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "69F84593B1A44CB4A65EBB513A7E0DB6");

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: "C06B4B8F05384AD89EE102E2E838DB3C");

            migrationBuilder.AddColumn<short>(
                name: "RequestStatus",
                table: "ParticipationRequests",
                type: "smallint",
                nullable: false,
                defaultValue: (short)0);

            migrationBuilder.AddColumn<bool>(
                name: "IsPrivate",
                table: "Events",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.InsertData(
                table: "Permissions",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "PermissionName", "PermissionValue", "UpdatedAt" },
                values: new object[,]
                {
                    { "359491B992E7440882DECFE7FB136A0D", new DateTime(2024, 12, 8, 4, 0, 43, 648, DateTimeKind.Utc).AddTicks(2169), false, "Administrator", "all_permissions", new DateTime(2024, 12, 8, 4, 0, 43, 648, DateTimeKind.Utc).AddTicks(2169) },
                    { "4169FF53F26549A38241B8003446C7C1", new DateTime(2024, 12, 8, 4, 0, 43, 648, DateTimeKind.Utc).AddTicks(2153), false, "User Management", "user_management", new DateTime(2024, 12, 8, 4, 0, 43, 648, DateTimeKind.Utc).AddTicks(2153) },
                    { "8F4A023FD5984B35921E42EEE423D5D1", new DateTime(2024, 12, 8, 4, 0, 43, 648, DateTimeKind.Utc).AddTicks(2144), false, "Organization Management", "organization_management", new DateTime(2024, 12, 8, 4, 0, 43, 648, DateTimeKind.Utc).AddTicks(2147) }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "RoleName", "UpdatedAt" },
                values: new object[] { "4BF73821F24B4EAE9FE44B39D5471AA6", new DateTime(2024, 12, 8, 4, 0, 43, 648, DateTimeKind.Utc).AddTicks(2278), false, "Administrator", new DateTime(2024, 12, 8, 4, 0, 43, 648, DateTimeKind.Utc).AddTicks(2278) });

            migrationBuilder.InsertData(
                table: "Admins",
                columns: new[] { "Id", "Email", "IsDeleted", "Password", "Phone", "RoleId" },
                values: new object[] { "3923E7C631D848C89536873C31D58313", "admin@gmail.com", false, "$2a$10$.OLqglvnx211VciXfs95lOTLGBKL1H.6f6cOQoFLZvPFhUl/o73UK", "0000000000", "4BF73821F24B4EAE9FE44B39D5471AA6" });

            migrationBuilder.InsertData(
                table: "RolePermissions",
                columns: new[] { "PermissionsId", "RolesId" },
                values: new object[] { "359491B992E7440882DECFE7FB136A0D", "4BF73821F24B4EAE9FE44B39D5471AA6" });
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Admins",
                keyColumn: "Id",
                keyValue: "3923E7C631D848C89536873C31D58313");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "4169FF53F26549A38241B8003446C7C1");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "8F4A023FD5984B35921E42EEE423D5D1");

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionsId", "RolesId" },
                keyValues: new object[] { "359491B992E7440882DECFE7FB136A0D", "4BF73821F24B4EAE9FE44B39D5471AA6" });

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "359491B992E7440882DECFE7FB136A0D");

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: "4BF73821F24B4EAE9FE44B39D5471AA6");

            migrationBuilder.DropColumn(
                name: "RequestStatus",
                table: "ParticipationRequests");

            migrationBuilder.DropColumn(
                name: "IsPrivate",
                table: "Events");

            migrationBuilder.InsertData(
                table: "Permissions",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "PermissionName", "PermissionValue", "UpdatedAt" },
                values: new object[,]
                {
                    { "69F84593B1A44CB4A65EBB513A7E0DB6", new DateTime(2024, 12, 7, 13, 21, 11, 1, DateTimeKind.Utc).AddTicks(556), false, "Administrator", "all_permissions", new DateTime(2024, 12, 7, 13, 21, 11, 1, DateTimeKind.Utc).AddTicks(556) },
                    { "C4173A00F4C740F7A9E116AB4D9E8DDD", new DateTime(2024, 12, 7, 13, 21, 11, 1, DateTimeKind.Utc).AddTicks(552), false, "User Management", "user_management", new DateTime(2024, 12, 7, 13, 21, 11, 1, DateTimeKind.Utc).AddTicks(552) },
                    { "E5095EF218FF44E2844B28F7572552D1", new DateTime(2024, 12, 7, 13, 21, 11, 1, DateTimeKind.Utc).AddTicks(543), false, "Organization Management", "organization_management", new DateTime(2024, 12, 7, 13, 21, 11, 1, DateTimeKind.Utc).AddTicks(546) }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "RoleName", "UpdatedAt" },
                values: new object[] { "C06B4B8F05384AD89EE102E2E838DB3C", new DateTime(2024, 12, 7, 13, 21, 11, 1, DateTimeKind.Utc).AddTicks(875), false, "Administrator", new DateTime(2024, 12, 7, 13, 21, 11, 1, DateTimeKind.Utc).AddTicks(877) });

            migrationBuilder.InsertData(
                table: "Admins",
                columns: new[] { "Id", "Email", "IsDeleted", "Password", "Phone", "RoleId" },
                values: new object[] { "776E9206B6C0464CA38AA988F5A98787", "admin@gmail.com", false, "$2a$10$Q/2kiwdnSrYVs59W3Wsgk.C63uB9M/x20FW9Vt2rJOEsy3ScL2Ln.", "0000000000", "C06B4B8F05384AD89EE102E2E838DB3C" });

            migrationBuilder.InsertData(
                table: "RolePermissions",
                columns: new[] { "PermissionsId", "RolesId" },
                values: new object[] { "69F84593B1A44CB4A65EBB513A7E0DB6", "C06B4B8F05384AD89EE102E2E838DB3C" });
        }
    }
}

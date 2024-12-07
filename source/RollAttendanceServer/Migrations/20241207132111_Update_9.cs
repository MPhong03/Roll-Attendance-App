using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RollAttendanceServer.Migrations
{
    public partial class Update_9 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
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

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAt",
                table: "ParticipationRequests",
                type: "datetime2",
                nullable: false,
                defaultValueSql: "GETUTCDATE()");

            migrationBuilder.AddColumn<bool>(
                name: "IsDeleted",
                table: "ParticipationRequests",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAt",
                table: "ParticipationRequests",
                type: "datetime2",
                nullable: false,
                defaultValueSql: "GETUTCDATE()");

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

        protected override void Down(MigrationBuilder migrationBuilder)
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

            migrationBuilder.DropColumn(
                name: "CreatedAt",
                table: "ParticipationRequests");

            migrationBuilder.DropColumn(
                name: "IsDeleted",
                table: "ParticipationRequests");

            migrationBuilder.DropColumn(
                name: "UpdatedAt",
                table: "ParticipationRequests");

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
    }
}

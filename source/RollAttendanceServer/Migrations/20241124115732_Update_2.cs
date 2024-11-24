using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RollAttendanceServer.Migrations
{
    public partial class Update_2 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Admins",
                keyColumn: "Id",
                keyValue: "D0FE9050C0304DC185B212D2C6D72D19");

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionsId", "RolesId" },
                keyValues: new object[] { "2D9CEABD7D2146ABAF9D0BAC0B5647A9", "A316410EF2634277A7B285D0D0BB25AC" });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionsId", "RolesId" },
                keyValues: new object[] { "31DB31C4A3834215AAA16452D6171D02", "A316410EF2634277A7B285D0D0BB25AC" });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionsId", "RolesId" },
                keyValues: new object[] { "9B8C5833BE0243C1B1F888DB0FB60B36", "A316410EF2634277A7B285D0D0BB25AC" });

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "2D9CEABD7D2146ABAF9D0BAC0B5647A9");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "31DB31C4A3834215AAA16452D6171D02");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "9B8C5833BE0243C1B1F888DB0FB60B36");

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: "A316410EF2634277A7B285D0D0BB25AC");

            migrationBuilder.AddColumn<string>(
                name: "EventId",
                table: "Users",
                type: "nvarchar(450)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "OrganizationId",
                table: "Users",
                type: "nvarchar(450)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "OrganizationId1",
                table: "Users",
                type: "nvarchar(450)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "OrganizationId2",
                table: "Users",
                type: "nvarchar(450)",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "Events",
                columns: table => new
                {
                    Id = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    StartTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    EndTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CurrentLocation = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Events", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Organizations",
                columns: table => new
                {
                    Id = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Address = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Organizations", x => x.Id);
                });

            migrationBuilder.InsertData(
                table: "Permissions",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "PermissionName", "PermissionValue", "UpdatedAt" },
                values: new object[,]
                {
                    { "E0C604990F9D4714844692A2FCE96DDC", new DateTime(2024, 11, 24, 11, 57, 32, 363, DateTimeKind.Utc).AddTicks(223), false, "User Management", "user_management", new DateTime(2024, 11, 24, 11, 57, 32, 363, DateTimeKind.Utc).AddTicks(224) },
                    { "E1D873484C17478FA2E3B38C003454FA", new DateTime(2024, 11, 24, 11, 57, 32, 363, DateTimeKind.Utc).AddTicks(227), false, "Administrator", "all_permissions", new DateTime(2024, 11, 24, 11, 57, 32, 363, DateTimeKind.Utc).AddTicks(227) },
                    { "F64C1165FA704C05AF1C54709622CB7D", new DateTime(2024, 11, 24, 11, 57, 32, 363, DateTimeKind.Utc).AddTicks(215), false, "Organization Management", "organization_management", new DateTime(2024, 11, 24, 11, 57, 32, 363, DateTimeKind.Utc).AddTicks(219) }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "RoleName", "UpdatedAt" },
                values: new object[] { "D37FCBBEAE1A44EA870BE9C90A3623FE", new DateTime(2024, 11, 24, 11, 57, 32, 363, DateTimeKind.Utc).AddTicks(383), false, "Administrator", new DateTime(2024, 11, 24, 11, 57, 32, 363, DateTimeKind.Utc).AddTicks(384) });

            migrationBuilder.InsertData(
                table: "Admins",
                columns: new[] { "Id", "Email", "IsDeleted", "Password", "Phone", "RoleId" },
                values: new object[] { "B4C38D8590C14EF0BDBE907EA5133D7F", "admin@gmail.com", false, "$2a$10$onVdurStbMmxRDzEzGbjkOvy2k79DpjX/nopiZ12vf2AGWk60KuNW", "0000000000", "D37FCBBEAE1A44EA870BE9C90A3623FE" });

            migrationBuilder.InsertData(
                table: "RolePermissions",
                columns: new[] { "PermissionsId", "RolesId" },
                values: new object[,]
                {
                    { "E0C604990F9D4714844692A2FCE96DDC", "D37FCBBEAE1A44EA870BE9C90A3623FE" },
                    { "E1D873484C17478FA2E3B38C003454FA", "D37FCBBEAE1A44EA870BE9C90A3623FE" },
                    { "F64C1165FA704C05AF1C54709622CB7D", "D37FCBBEAE1A44EA870BE9C90A3623FE" }
                });

            migrationBuilder.CreateIndex(
                name: "IX_Users_EventId",
                table: "Users",
                column: "EventId");

            migrationBuilder.CreateIndex(
                name: "IX_Users_OrganizationId",
                table: "Users",
                column: "OrganizationId");

            migrationBuilder.CreateIndex(
                name: "IX_Users_OrganizationId1",
                table: "Users",
                column: "OrganizationId1");

            migrationBuilder.CreateIndex(
                name: "IX_Users_OrganizationId2",
                table: "Users",
                column: "OrganizationId2");

            migrationBuilder.AddForeignKey(
                name: "FK_Users_Events_EventId",
                table: "Users",
                column: "EventId",
                principalTable: "Events",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Users_Organizations_OrganizationId",
                table: "Users",
                column: "OrganizationId",
                principalTable: "Organizations",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Users_Organizations_OrganizationId1",
                table: "Users",
                column: "OrganizationId1",
                principalTable: "Organizations",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Users_Organizations_OrganizationId2",
                table: "Users",
                column: "OrganizationId2",
                principalTable: "Organizations",
                principalColumn: "Id");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Users_Events_EventId",
                table: "Users");

            migrationBuilder.DropForeignKey(
                name: "FK_Users_Organizations_OrganizationId",
                table: "Users");

            migrationBuilder.DropForeignKey(
                name: "FK_Users_Organizations_OrganizationId1",
                table: "Users");

            migrationBuilder.DropForeignKey(
                name: "FK_Users_Organizations_OrganizationId2",
                table: "Users");

            migrationBuilder.DropTable(
                name: "Events");

            migrationBuilder.DropTable(
                name: "Organizations");

            migrationBuilder.DropIndex(
                name: "IX_Users_EventId",
                table: "Users");

            migrationBuilder.DropIndex(
                name: "IX_Users_OrganizationId",
                table: "Users");

            migrationBuilder.DropIndex(
                name: "IX_Users_OrganizationId1",
                table: "Users");

            migrationBuilder.DropIndex(
                name: "IX_Users_OrganizationId2",
                table: "Users");

            migrationBuilder.DeleteData(
                table: "Admins",
                keyColumn: "Id",
                keyValue: "B4C38D8590C14EF0BDBE907EA5133D7F");

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionsId", "RolesId" },
                keyValues: new object[] { "E0C604990F9D4714844692A2FCE96DDC", "D37FCBBEAE1A44EA870BE9C90A3623FE" });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionsId", "RolesId" },
                keyValues: new object[] { "E1D873484C17478FA2E3B38C003454FA", "D37FCBBEAE1A44EA870BE9C90A3623FE" });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionsId", "RolesId" },
                keyValues: new object[] { "F64C1165FA704C05AF1C54709622CB7D", "D37FCBBEAE1A44EA870BE9C90A3623FE" });

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "E0C604990F9D4714844692A2FCE96DDC");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "E1D873484C17478FA2E3B38C003454FA");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "F64C1165FA704C05AF1C54709622CB7D");

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: "D37FCBBEAE1A44EA870BE9C90A3623FE");

            migrationBuilder.DropColumn(
                name: "EventId",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "OrganizationId",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "OrganizationId1",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "OrganizationId2",
                table: "Users");

            migrationBuilder.InsertData(
                table: "Permissions",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "PermissionName", "PermissionValue", "UpdatedAt" },
                values: new object[,]
                {
                    { "2D9CEABD7D2146ABAF9D0BAC0B5647A9", new DateTime(2024, 11, 24, 11, 54, 23, 752, DateTimeKind.Utc).AddTicks(3660), false, "Organization Management", "organization_management", new DateTime(2024, 11, 24, 11, 54, 23, 752, DateTimeKind.Utc).AddTicks(3663) },
                    { "31DB31C4A3834215AAA16452D6171D02", new DateTime(2024, 11, 24, 11, 54, 23, 752, DateTimeKind.Utc).AddTicks(3667), false, "User Management", "user_management", new DateTime(2024, 11, 24, 11, 54, 23, 752, DateTimeKind.Utc).AddTicks(3667) },
                    { "9B8C5833BE0243C1B1F888DB0FB60B36", new DateTime(2024, 11, 24, 11, 54, 23, 752, DateTimeKind.Utc).AddTicks(3670), false, "Administrator", "all_permissions", new DateTime(2024, 11, 24, 11, 54, 23, 752, DateTimeKind.Utc).AddTicks(3670) }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "RoleName", "UpdatedAt" },
                values: new object[] { "A316410EF2634277A7B285D0D0BB25AC", new DateTime(2024, 11, 24, 11, 54, 23, 752, DateTimeKind.Utc).AddTicks(3770), false, "Administrator", new DateTime(2024, 11, 24, 11, 54, 23, 752, DateTimeKind.Utc).AddTicks(3770) });

            migrationBuilder.InsertData(
                table: "Admins",
                columns: new[] { "Id", "Email", "IsDeleted", "Password", "Phone", "RoleId" },
                values: new object[] { "D0FE9050C0304DC185B212D2C6D72D19", "admin@gmail.com", false, "$2a$10$99vv4T7VQc/tZIe5JvWxFuZqqWxEuCXdRAt/cqwCxqUuOydxHoQ7a", "0000000000", "A316410EF2634277A7B285D0D0BB25AC" });

            migrationBuilder.InsertData(
                table: "RolePermissions",
                columns: new[] { "PermissionsId", "RolesId" },
                values: new object[,]
                {
                    { "2D9CEABD7D2146ABAF9D0BAC0B5647A9", "A316410EF2634277A7B285D0D0BB25AC" },
                    { "31DB31C4A3834215AAA16452D6171D02", "A316410EF2634277A7B285D0D0BB25AC" },
                    { "9B8C5833BE0243C1B1F888DB0FB60B36", "A316410EF2634277A7B285D0D0BB25AC" }
                });
        }
    }
}

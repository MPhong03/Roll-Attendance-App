using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RollAttendanceServer.Migrations
{
    public partial class Update_7 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Admins",
                keyColumn: "Id",
                keyValue: "7AE87665AD8E4FF4A0C3E69F941C1624");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "617C1C86D3F0457C9DE3BADFFEBF1436");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "C723EDF3A5F8484D83F5EE0A6FE7DCCD");

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionsId", "RolesId" },
                keyValues: new object[] { "D570AC80420744459C55429B7600E978", "405402E3E5F4484A8DD5F871E204097E" });

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "D570AC80420744459C55429B7600E978");

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: "405402E3E5F4484A8DD5F871E204097E");

            migrationBuilder.AddColumn<decimal>(
                name: "CurrentLocationRadius",
                table: "Events",
                type: "decimal(18,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<string>(
                name: "CurrentQR",
                table: "Events",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<short>(
                name: "EventStatus",
                table: "Events",
                type: "smallint",
                nullable: false,
                defaultValue: (short)0);

            migrationBuilder.AddColumn<string>(
                name: "OrganizationId",
                table: "Events",
                type: "nvarchar(450)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "OrganizerId",
                table: "Events",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.CreateTable(
                name: "Histories",
                columns: table => new
                {
                    Id = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    OccurDate = table.Column<DateTime>(type: "datetime2", nullable: true),
                    StartTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    EndTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    TotalCount = table.Column<int>(type: "int", nullable: false),
                    PresentCount = table.Column<int>(type: "int", nullable: false),
                    AbsentCount = table.Column<int>(type: "int", nullable: false),
                    AttendanceTimes = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Histories", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "HistoryDetails",
                columns: table => new
                {
                    Id = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    UserId = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    UserName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    UserEmail = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    UserAvatar = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    AbsentTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    LeaveTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    AttendanceCount = table.Column<int>(type: "int", nullable: false),
                    AttendanceStatus = table.Column<short>(type: "smallint", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_HistoryDetails", x => x.Id);
                });

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

            migrationBuilder.CreateIndex(
                name: "IX_Events_OrganizationId",
                table: "Events",
                column: "OrganizationId");

            migrationBuilder.AddForeignKey(
                name: "FK_Events_Organizations_OrganizationId",
                table: "Events",
                column: "OrganizationId",
                principalTable: "Organizations",
                principalColumn: "Id");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Events_Organizations_OrganizationId",
                table: "Events");

            migrationBuilder.DropTable(
                name: "Histories");

            migrationBuilder.DropTable(
                name: "HistoryDetails");

            migrationBuilder.DropIndex(
                name: "IX_Events_OrganizationId",
                table: "Events");

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

            migrationBuilder.DropColumn(
                name: "CurrentLocationRadius",
                table: "Events");

            migrationBuilder.DropColumn(
                name: "CurrentQR",
                table: "Events");

            migrationBuilder.DropColumn(
                name: "EventStatus",
                table: "Events");

            migrationBuilder.DropColumn(
                name: "OrganizationId",
                table: "Events");

            migrationBuilder.DropColumn(
                name: "OrganizerId",
                table: "Events");

            migrationBuilder.InsertData(
                table: "Permissions",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "PermissionName", "PermissionValue", "UpdatedAt" },
                values: new object[,]
                {
                    { "617C1C86D3F0457C9DE3BADFFEBF1436", new DateTime(2024, 11, 30, 11, 4, 24, 894, DateTimeKind.Utc).AddTicks(6751), false, "Organization Management", "organization_management", new DateTime(2024, 11, 30, 11, 4, 24, 894, DateTimeKind.Utc).AddTicks(6754) },
                    { "C723EDF3A5F8484D83F5EE0A6FE7DCCD", new DateTime(2024, 11, 30, 11, 4, 24, 894, DateTimeKind.Utc).AddTicks(6772), false, "User Management", "user_management", new DateTime(2024, 11, 30, 11, 4, 24, 894, DateTimeKind.Utc).AddTicks(6773) },
                    { "D570AC80420744459C55429B7600E978", new DateTime(2024, 11, 30, 11, 4, 24, 894, DateTimeKind.Utc).AddTicks(6776), false, "Administrator", "all_permissions", new DateTime(2024, 11, 30, 11, 4, 24, 894, DateTimeKind.Utc).AddTicks(6776) }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "RoleName", "UpdatedAt" },
                values: new object[] { "405402E3E5F4484A8DD5F871E204097E", new DateTime(2024, 11, 30, 11, 4, 24, 894, DateTimeKind.Utc).AddTicks(6916), false, "Administrator", new DateTime(2024, 11, 30, 11, 4, 24, 894, DateTimeKind.Utc).AddTicks(6916) });

            migrationBuilder.InsertData(
                table: "Admins",
                columns: new[] { "Id", "Email", "IsDeleted", "Password", "Phone", "RoleId" },
                values: new object[] { "7AE87665AD8E4FF4A0C3E69F941C1624", "admin@gmail.com", false, "$2a$10$mF6FiPZZo2QKs/7V5ejtMO8QzxdfRZE.O/N12ZIDqKr79AT9IlLp2", "0000000000", "405402E3E5F4484A8DD5F871E204097E" });

            migrationBuilder.InsertData(
                table: "RolePermissions",
                columns: new[] { "PermissionsId", "RolesId" },
                values: new object[] { "D570AC80420744459C55429B7600E978", "405402E3E5F4484A8DD5F871E204097E" });
        }
    }
}

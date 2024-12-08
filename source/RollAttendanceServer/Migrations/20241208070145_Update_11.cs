using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RollAttendanceServer.Migrations
{
    public partial class Update_11 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
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

            migrationBuilder.RenameColumn(
                name: "AbsentCount",
                table: "Histories",
                newName: "LateCount");

            migrationBuilder.AddColumn<string>(
                name: "HistoryId",
                table: "HistoryDetails",
                type: "nvarchar(450)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "EventId",
                table: "Histories",
                type: "nvarchar(450)",
                nullable: false,
                defaultValue: "");

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

            migrationBuilder.CreateIndex(
                name: "IX_HistoryDetails_HistoryId",
                table: "HistoryDetails",
                column: "HistoryId");

            migrationBuilder.CreateIndex(
                name: "IX_Histories_EventId",
                table: "Histories",
                column: "EventId");

            migrationBuilder.AddForeignKey(
                name: "FK_Histories_Events_EventId",
                table: "Histories",
                column: "EventId",
                principalTable: "Events",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_HistoryDetails_Histories_HistoryId",
                table: "HistoryDetails",
                column: "HistoryId",
                principalTable: "Histories",
                principalColumn: "Id");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Histories_Events_EventId",
                table: "Histories");

            migrationBuilder.DropForeignKey(
                name: "FK_HistoryDetails_Histories_HistoryId",
                table: "HistoryDetails");

            migrationBuilder.DropIndex(
                name: "IX_HistoryDetails_HistoryId",
                table: "HistoryDetails");

            migrationBuilder.DropIndex(
                name: "IX_Histories_EventId",
                table: "Histories");

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

            migrationBuilder.DropColumn(
                name: "HistoryId",
                table: "HistoryDetails");

            migrationBuilder.DropColumn(
                name: "EventId",
                table: "Histories");

            migrationBuilder.RenameColumn(
                name: "LateCount",
                table: "Histories",
                newName: "AbsentCount");

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
    }
}

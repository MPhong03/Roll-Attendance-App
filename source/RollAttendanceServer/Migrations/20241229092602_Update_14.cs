using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RollAttendanceServer.Migrations
{
    public partial class Update_14 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Users_Events_EventId",
                table: "Users");

            migrationBuilder.DropIndex(
                name: "IX_Users_EventId",
                table: "Users");

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
                name: "EventId",
                table: "Users");

            migrationBuilder.CreateTable(
                name: "EventUsers",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    EventId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    UserId = table.Column<string>(type: "nvarchar(450)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_EventUsers", x => x.Id);
                    table.ForeignKey(
                        name: "FK_EventUsers_Events_EventId",
                        column: x => x.EventId,
                        principalTable: "Events",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_EventUsers_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                table: "Permissions",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "PermissionName", "PermissionValue", "UpdatedAt" },
                values: new object[,]
                {
                    { "056B8CA929674D099B48D1F8A3BF9C16", new DateTime(2024, 12, 29, 9, 26, 1, 877, DateTimeKind.Utc).AddTicks(6425), false, "User Management", "user_management", new DateTime(2024, 12, 29, 9, 26, 1, 877, DateTimeKind.Utc).AddTicks(6425) },
                    { "10DFA259619844CF8864FDDBF1576748", new DateTime(2024, 12, 29, 9, 26, 1, 877, DateTimeKind.Utc).AddTicks(6429), false, "Administrator", "all_permissions", new DateTime(2024, 12, 29, 9, 26, 1, 877, DateTimeKind.Utc).AddTicks(6429) },
                    { "78BC81F32BF04DBAB5F9BBCF6E361273", new DateTime(2024, 12, 29, 9, 26, 1, 877, DateTimeKind.Utc).AddTicks(6411), false, "Organization Management", "organization_management", new DateTime(2024, 12, 29, 9, 26, 1, 877, DateTimeKind.Utc).AddTicks(6418) }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "RoleName", "UpdatedAt" },
                values: new object[] { "309511C21C4D491C8FE2C30D8814EE87", new DateTime(2024, 12, 29, 9, 26, 1, 877, DateTimeKind.Utc).AddTicks(6572), false, "Administrator", new DateTime(2024, 12, 29, 9, 26, 1, 877, DateTimeKind.Utc).AddTicks(6572) });

            migrationBuilder.InsertData(
                table: "Admins",
                columns: new[] { "Id", "Email", "IsDeleted", "Password", "Phone", "RoleId" },
                values: new object[] { "FD3C8B24CF3C47F1BACA936C89282759", "admin@gmail.com", false, "$2a$10$ANdnVyecPRYKoJPhmrMevOqbspEx0wu/qT8GQ9gpVVj89dMbSWDgG", "0000000000", "309511C21C4D491C8FE2C30D8814EE87" });

            migrationBuilder.InsertData(
                table: "RolePermissions",
                columns: new[] { "PermissionsId", "RolesId" },
                values: new object[] { "10DFA259619844CF8864FDDBF1576748", "309511C21C4D491C8FE2C30D8814EE87" });

            migrationBuilder.CreateIndex(
                name: "IX_EventUsers_EventId",
                table: "EventUsers",
                column: "EventId");

            migrationBuilder.CreateIndex(
                name: "IX_EventUsers_UserId",
                table: "EventUsers",
                column: "UserId");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "EventUsers");

            migrationBuilder.DeleteData(
                table: "Admins",
                keyColumn: "Id",
                keyValue: "FD3C8B24CF3C47F1BACA936C89282759");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "056B8CA929674D099B48D1F8A3BF9C16");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "78BC81F32BF04DBAB5F9BBCF6E361273");

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionsId", "RolesId" },
                keyValues: new object[] { "10DFA259619844CF8864FDDBF1576748", "309511C21C4D491C8FE2C30D8814EE87" });

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "10DFA259619844CF8864FDDBF1576748");

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: "309511C21C4D491C8FE2C30D8814EE87");

            migrationBuilder.AddColumn<string>(
                name: "EventId",
                table: "Users",
                type: "nvarchar(450)",
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

            migrationBuilder.CreateIndex(
                name: "IX_Users_EventId",
                table: "Users",
                column: "EventId");

            migrationBuilder.AddForeignKey(
                name: "FK_Users_Events_EventId",
                table: "Users",
                column: "EventId",
                principalTable: "Events",
                principalColumn: "Id");
        }
    }
}

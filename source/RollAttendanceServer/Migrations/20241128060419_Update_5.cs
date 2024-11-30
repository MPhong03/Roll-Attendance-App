using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RollAttendanceServer.Migrations
{
    public partial class Update_5 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Users_Organizations_OrganizationId",
                table: "Users");

            migrationBuilder.DropForeignKey(
                name: "FK_Users_Organizations_OrganizationId1",
                table: "Users");

            migrationBuilder.DropForeignKey(
                name: "FK_Users_Organizations_OrganizationId2",
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

            migrationBuilder.DropColumn(
                name: "OrganizationId",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "OrganizationId1",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "OrganizationId2",
                table: "Users");

            migrationBuilder.CreateTable(
                name: "UserOrganizationRoles",
                columns: table => new
                {
                    UserId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    OrganizationId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Role = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserOrganizationRoles", x => new { x.UserId, x.OrganizationId });
                    table.ForeignKey(
                        name: "FK_UserOrganizationRoles_Organizations_OrganizationId",
                        column: x => x.OrganizationId,
                        principalTable: "Organizations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_UserOrganizationRoles_Users_UserId",
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
                    { "6BF3F19BADC3488D86A33E2843550A52", new DateTime(2024, 11, 28, 6, 4, 19, 484, DateTimeKind.Utc).AddTicks(2002), false, "User Management", "user_management", new DateTime(2024, 11, 28, 6, 4, 19, 484, DateTimeKind.Utc).AddTicks(2003) },
                    { "AC8D092B0B7D498F86B9D65C997072A3", new DateTime(2024, 11, 28, 6, 4, 19, 484, DateTimeKind.Utc).AddTicks(1990), false, "Organization Management", "organization_management", new DateTime(2024, 11, 28, 6, 4, 19, 484, DateTimeKind.Utc).AddTicks(1994) },
                    { "C4990E5CB813472E909B8288D6EC54AC", new DateTime(2024, 11, 28, 6, 4, 19, 484, DateTimeKind.Utc).AddTicks(2008), false, "Administrator", "all_permissions", new DateTime(2024, 11, 28, 6, 4, 19, 484, DateTimeKind.Utc).AddTicks(2008) }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "RoleName", "UpdatedAt" },
                values: new object[] { "C1ECC039C5484FC3B91F90D46E94E1F9", new DateTime(2024, 11, 28, 6, 4, 19, 484, DateTimeKind.Utc).AddTicks(2209), false, "Administrator", new DateTime(2024, 11, 28, 6, 4, 19, 484, DateTimeKind.Utc).AddTicks(2210) });

            migrationBuilder.InsertData(
                table: "Admins",
                columns: new[] { "Id", "Email", "IsDeleted", "Password", "Phone", "RoleId" },
                values: new object[] { "CCB8BB1E27914AF0B7CA0018AE1DB32C", "admin@gmail.com", false, "$2a$10$60aZ7uaI.UIeiNRU2BziIOYketrZelLcE90rp9xmF9iGYZG/1xa9G", "0000000000", "C1ECC039C5484FC3B91F90D46E94E1F9" });

            migrationBuilder.InsertData(
                table: "RolePermissions",
                columns: new[] { "PermissionsId", "RolesId" },
                values: new object[] { "C4990E5CB813472E909B8288D6EC54AC", "C1ECC039C5484FC3B91F90D46E94E1F9" });

            migrationBuilder.CreateIndex(
                name: "IX_UserOrganizationRoles_OrganizationId",
                table: "UserOrganizationRoles",
                column: "OrganizationId");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "UserOrganizationRoles");

            migrationBuilder.DeleteData(
                table: "Admins",
                keyColumn: "Id",
                keyValue: "CCB8BB1E27914AF0B7CA0018AE1DB32C");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "6BF3F19BADC3488D86A33E2843550A52");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "AC8D092B0B7D498F86B9D65C997072A3");

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionsId", "RolesId" },
                keyValues: new object[] { "C4990E5CB813472E909B8288D6EC54AC", "C1ECC039C5484FC3B91F90D46E94E1F9" });

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "C4990E5CB813472E909B8288D6EC54AC");

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: "C1ECC039C5484FC3B91F90D46E94E1F9");

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
    }
}

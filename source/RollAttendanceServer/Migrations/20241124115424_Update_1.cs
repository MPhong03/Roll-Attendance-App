using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RollAttendanceServer.Migrations
{
    public partial class Update_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionsId", "RolesId" },
                keyValues: new object[] { "31BC845565614955ADD8C3E9BBFAECC5", "D2291DA05EC748398F1476BF67BDD1A5" });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionsId", "RolesId" },
                keyValues: new object[] { "7AB109A6B759479DB2C4BEA8331C9B19", "7EADA125BA324296A3980A17A6500027" });

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionsId", "RolesId" },
                keyValues: new object[] { "FE56125AC1F24D34901AC79CED6C1CD3", "FEFB5EA3647B44DDA62965024521FFAD" });

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "31BC845565614955ADD8C3E9BBFAECC5");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "7AB109A6B759479DB2C4BEA8331C9B19");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "FE56125AC1F24D34901AC79CED6C1CD3");

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: "7EADA125BA324296A3980A17A6500027");

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: "D2291DA05EC748398F1476BF67BDD1A5");

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: "FEFB5EA3647B44DDA62965024521FFAD");

            migrationBuilder.DropColumn(
                name: "DeletedAt",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "DeletedAt",
                table: "Roles");

            migrationBuilder.DropColumn(
                name: "DeletedAt",
                table: "Permissions");

            migrationBuilder.DropColumn(
                name: "DeletedAt",
                table: "Admins");

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

        protected override void Down(MigrationBuilder migrationBuilder)
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

            migrationBuilder.AddColumn<DateTime>(
                name: "DeletedAt",
                table: "Users",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "DeletedAt",
                table: "Roles",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "DeletedAt",
                table: "Permissions",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "DeletedAt",
                table: "Admins",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.InsertData(
                table: "Permissions",
                columns: new[] { "Id", "CreatedAt", "DeletedAt", "IsDeleted", "PermissionName", "PermissionValue", "UpdatedAt" },
                values: new object[,]
                {
                    { "31BC845565614955ADD8C3E9BBFAECC5", new DateTime(2024, 11, 24, 11, 45, 28, 398, DateTimeKind.Utc).AddTicks(9190), new DateTime(2024, 11, 24, 11, 45, 28, 398, DateTimeKind.Utc).AddTicks(9191), false, "User Management", "user_management", new DateTime(2024, 11, 24, 11, 45, 28, 398, DateTimeKind.Utc).AddTicks(9190) },
                    { "7AB109A6B759479DB2C4BEA8331C9B19", new DateTime(2024, 11, 24, 11, 45, 28, 398, DateTimeKind.Utc).AddTicks(9178), new DateTime(2024, 11, 24, 11, 45, 28, 398, DateTimeKind.Utc).AddTicks(9183), false, "Organization Management", "organization_management", new DateTime(2024, 11, 24, 11, 45, 28, 398, DateTimeKind.Utc).AddTicks(9183) },
                    { "FE56125AC1F24D34901AC79CED6C1CD3", new DateTime(2024, 11, 24, 11, 45, 28, 398, DateTimeKind.Utc).AddTicks(9251), new DateTime(2024, 11, 24, 11, 45, 28, 398, DateTimeKind.Utc).AddTicks(9252), false, "Administrator", "all_permissions", new DateTime(2024, 11, 24, 11, 45, 28, 398, DateTimeKind.Utc).AddTicks(9251) }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "CreatedAt", "DeletedAt", "IsDeleted", "RoleName", "UpdatedAt" },
                values: new object[,]
                {
                    { "7EADA125BA324296A3980A17A6500027", new DateTime(2024, 11, 24, 11, 45, 28, 398, DateTimeKind.Utc).AddTicks(9396), new DateTime(2024, 11, 24, 11, 45, 28, 398, DateTimeKind.Utc).AddTicks(9396), false, "Organization Manager", new DateTime(2024, 11, 24, 11, 45, 28, 398, DateTimeKind.Utc).AddTicks(9396) },
                    { "D2291DA05EC748398F1476BF67BDD1A5", new DateTime(2024, 11, 24, 11, 45, 28, 398, DateTimeKind.Utc).AddTicks(9405), new DateTime(2024, 11, 24, 11, 45, 28, 398, DateTimeKind.Utc).AddTicks(9406), false, "User Manager", new DateTime(2024, 11, 24, 11, 45, 28, 398, DateTimeKind.Utc).AddTicks(9405) },
                    { "FEFB5EA3647B44DDA62965024521FFAD", new DateTime(2024, 11, 24, 11, 45, 28, 398, DateTimeKind.Utc).AddTicks(9409), new DateTime(2024, 11, 24, 11, 45, 28, 398, DateTimeKind.Utc).AddTicks(9410), false, "Administrator", new DateTime(2024, 11, 24, 11, 45, 28, 398, DateTimeKind.Utc).AddTicks(9410) }
                });

            migrationBuilder.InsertData(
                table: "RolePermissions",
                columns: new[] { "PermissionsId", "RolesId" },
                values: new object[] { "31BC845565614955ADD8C3E9BBFAECC5", "D2291DA05EC748398F1476BF67BDD1A5" });

            migrationBuilder.InsertData(
                table: "RolePermissions",
                columns: new[] { "PermissionsId", "RolesId" },
                values: new object[] { "7AB109A6B759479DB2C4BEA8331C9B19", "7EADA125BA324296A3980A17A6500027" });

            migrationBuilder.InsertData(
                table: "RolePermissions",
                columns: new[] { "PermissionsId", "RolesId" },
                values: new object[] { "FE56125AC1F24D34901AC79CED6C1CD3", "FEFB5EA3647B44DDA62965024521FFAD" });
        }
    }
}

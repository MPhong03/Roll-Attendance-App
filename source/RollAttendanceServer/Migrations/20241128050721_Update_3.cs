using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RollAttendanceServer.Migrations
{
    public partial class Update_3 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Admins_Roles_RoleId",
                table: "Admins");

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

            migrationBuilder.AlterColumn<string>(
                name: "RoleId",
                table: "Admins",
                type: "nvarchar(450)",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(450)",
                oldNullable: true);

            migrationBuilder.InsertData(
                table: "Permissions",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "PermissionName", "PermissionValue", "UpdatedAt" },
                values: new object[,]
                {
                    { "53282CBC94354B958B136762DDE33922", new DateTime(2024, 11, 28, 5, 7, 20, 255, DateTimeKind.Utc).AddTicks(2882), false, "Administrator", "all_permissions", new DateTime(2024, 11, 28, 5, 7, 20, 255, DateTimeKind.Utc).AddTicks(2882) },
                    { "BD70289CA2ED4266968980B694D21A27", new DateTime(2024, 11, 28, 5, 7, 20, 255, DateTimeKind.Utc).AddTicks(2875), false, "User Management", "user_management", new DateTime(2024, 11, 28, 5, 7, 20, 255, DateTimeKind.Utc).AddTicks(2876) },
                    { "FB55885A201B412796D972DAE7671950", new DateTime(2024, 11, 28, 5, 7, 20, 255, DateTimeKind.Utc).AddTicks(2863), false, "Organization Management", "organization_management", new DateTime(2024, 11, 28, 5, 7, 20, 255, DateTimeKind.Utc).AddTicks(2866) }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "CreatedAt", "IsDeleted", "RoleName", "UpdatedAt" },
                values: new object[] { "62DB22F21EA34D37B05C4A880BBC9AFE", new DateTime(2024, 11, 28, 5, 7, 20, 255, DateTimeKind.Utc).AddTicks(3135), false, "Administrator", new DateTime(2024, 11, 28, 5, 7, 20, 255, DateTimeKind.Utc).AddTicks(3136) });

            migrationBuilder.InsertData(
                table: "Admins",
                columns: new[] { "Id", "Email", "IsDeleted", "Password", "Phone", "RoleId" },
                values: new object[] { "72C16393B1AD4935B44BD369631745A5", "admin@gmail.com", false, "$2a$10$/UCqfN.AooikYMAQgYWtA.68pk4rIPwMrnO3LkTOQaQzVy8K.4cj.", "0000000000", "62DB22F21EA34D37B05C4A880BBC9AFE" });

            migrationBuilder.InsertData(
                table: "RolePermissions",
                columns: new[] { "PermissionsId", "RolesId" },
                values: new object[] { "53282CBC94354B958B136762DDE33922", "62DB22F21EA34D37B05C4A880BBC9AFE" });

            migrationBuilder.AddForeignKey(
                name: "FK_Admins_Roles_RoleId",
                table: "Admins",
                column: "RoleId",
                principalTable: "Roles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Admins_Roles_RoleId",
                table: "Admins");

            migrationBuilder.DeleteData(
                table: "Admins",
                keyColumn: "Id",
                keyValue: "72C16393B1AD4935B44BD369631745A5");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "BD70289CA2ED4266968980B694D21A27");

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "FB55885A201B412796D972DAE7671950");

            migrationBuilder.DeleteData(
                table: "RolePermissions",
                keyColumns: new[] { "PermissionsId", "RolesId" },
                keyValues: new object[] { "53282CBC94354B958B136762DDE33922", "62DB22F21EA34D37B05C4A880BBC9AFE" });

            migrationBuilder.DeleteData(
                table: "Permissions",
                keyColumn: "Id",
                keyValue: "53282CBC94354B958B136762DDE33922");

            migrationBuilder.DeleteData(
                table: "Roles",
                keyColumn: "Id",
                keyValue: "62DB22F21EA34D37B05C4A880BBC9AFE");

            migrationBuilder.AlterColumn<string>(
                name: "RoleId",
                table: "Admins",
                type: "nvarchar(450)",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(450)");

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

            migrationBuilder.AddForeignKey(
                name: "FK_Admins_Roles_RoleId",
                table: "Admins",
                column: "RoleId",
                principalTable: "Roles",
                principalColumn: "Id");
        }
    }
}

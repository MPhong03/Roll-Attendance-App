using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RollAttendanceServer.Migrations
{
    public partial class InitDb : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Permissions",
                columns: table => new
                {
                    Id = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    PermissionName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    PermissionValue = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    DeletedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Permissions", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Roles",
                columns: table => new
                {
                    Id = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    RoleName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    DeletedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Roles", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    Id = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Email = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Uid = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    FaceData = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Address = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Gender = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    DeletedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Admins",
                columns: table => new
                {
                    Id = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Email = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Password = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Phone = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    RoleId = table.Column<string>(type: "nvarchar(450)", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    DeletedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Admins", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Admins_Roles_RoleId",
                        column: x => x.RoleId,
                        principalTable: "Roles",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "RolePermissions",
                columns: table => new
                {
                    PermissionsId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    RolesId = table.Column<string>(type: "nvarchar(450)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RolePermissions", x => new { x.PermissionsId, x.RolesId });
                    table.ForeignKey(
                        name: "FK_RolePermissions_Permissions_PermissionsId",
                        column: x => x.PermissionsId,
                        principalTable: "Permissions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_RolePermissions_Roles_RolesId",
                        column: x => x.RolesId,
                        principalTable: "Roles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

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

            migrationBuilder.CreateIndex(
                name: "IX_Admins_RoleId",
                table: "Admins",
                column: "RoleId");

            migrationBuilder.CreateIndex(
                name: "IX_RolePermissions_RolesId",
                table: "RolePermissions",
                column: "RolesId");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Admins");

            migrationBuilder.DropTable(
                name: "RolePermissions");

            migrationBuilder.DropTable(
                name: "Users");

            migrationBuilder.DropTable(
                name: "Permissions");

            migrationBuilder.DropTable(
                name: "Roles");
        }
    }
}

using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RollAttendanceServer.Migrations
{
    public partial class Update_6 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsPrivate",
                table: "Organizations",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsPrivate",
                table: "Organizations");
        }
    }
}

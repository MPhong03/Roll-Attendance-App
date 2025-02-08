using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace RollAttendanceServer.Migrations
{
    public partial class Update_20 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "FCMToken",
                table: "Users",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "FCMToken",
                table: "Users");
        }
    }
}

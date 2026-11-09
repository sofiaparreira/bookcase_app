using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Bookcase.Api.Migrations
{
    /// <inheritdoc />
    public partial class BookProgressoConclusao : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CompletedAt",
                table: "ReadingGoals");

            migrationBuilder.AddColumn<DateTime>(
                name: "CompletedAt",
                table: "Books",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "CurrentPage",
                table: "Books",
                type: "integer",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CompletedAt",
                table: "Books");

            migrationBuilder.DropColumn(
                name: "CurrentPage",
                table: "Books");

            migrationBuilder.AddColumn<DateTime>(
                name: "CompletedAt",
                table: "ReadingGoals",
                type: "timestamp with time zone",
                nullable: true);
        }
    }
}

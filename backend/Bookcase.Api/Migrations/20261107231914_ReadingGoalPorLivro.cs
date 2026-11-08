using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Bookcase.Api.Migrations
{
    /// <inheritdoc />
    public partial class ReadingGoalPorLivro : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("DELETE FROM \"ReadingGoals\";");

            migrationBuilder.RenameColumn(
                name: "TargetBooks",
                table: "ReadingGoals",
                newName: "TargetPages");

            migrationBuilder.RenameColumn(
                name: "CurrentBooks",
                table: "ReadingGoals",
                newName: "CurrentPage");

            migrationBuilder.AddColumn<int>(
                name: "BookId",
                table: "ReadingGoals",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "CompletedAt",
                table: "ReadingGoals",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_ReadingGoals_BookId",
                table: "ReadingGoals",
                column: "BookId");

            migrationBuilder.AddForeignKey(
                name: "FK_ReadingGoals_Books_BookId",
                table: "ReadingGoals",
                column: "BookId",
                principalTable: "Books",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ReadingGoals_Books_BookId",
                table: "ReadingGoals");

            migrationBuilder.DropIndex(
                name: "IX_ReadingGoals_BookId",
                table: "ReadingGoals");

            migrationBuilder.DropColumn(
                name: "BookId",
                table: "ReadingGoals");

            migrationBuilder.DropColumn(
                name: "CompletedAt",
                table: "ReadingGoals");

            migrationBuilder.RenameColumn(
                name: "TargetPages",
                table: "ReadingGoals",
                newName: "TargetBooks");

            migrationBuilder.RenameColumn(
                name: "CurrentPage",
                table: "ReadingGoals",
                newName: "CurrentBooks");
        }
    }
}

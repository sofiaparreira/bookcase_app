using Microsoft.EntityFrameworkCore;
using Bookcase.Api.Models;
namespace Bookcase.Api.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    public DbSet<Book> Books => Set<Book>();
    public DbSet<ReadingGoal> ReadingGoals => Set<ReadingGoal>();
    public DbSet<User> Users => Set<User>();
    public DbSet<ShoppingListItem> ShoppingListItems => Set<ShoppingListItem>();
}
namespace Bookcase.Api.Models;

public class User
{
    public int Id { get; set; }
    public required String Name { get; set; }
    public required String Email { get; set; }
    public required String PasswordHash { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

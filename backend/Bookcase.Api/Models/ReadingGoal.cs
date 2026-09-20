namespace Bookcase.Api.Models;

public class ReadingGoal
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public required String Title { get; set; }
    public int TargetBooks { get; set; }
    public int CurrentBooks { get; set; } = 0;
    public DateTime StartDate { get; set; } = DateTime.UtcNow;
    public DateTime EndDate { get; set; }
}
namespace Bookcase.Api.Models;

public class ReadingGoal
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public User? User { get; set; }
    public required String Title { get; set; }
    public int BookId { get; set; }
    public Book? Book { get; set; }
    public int TargetPages { get; set; }
    public int CurrentPage { get; set; } = 0;
    public DateTime StartDate { get; set; } = DateTime.UtcNow;
    public DateTime EndDate { get; set; }
    public DateTime? CompletedAt { get; set; }
}

namespace Bookcase.Api.Models;

public class Book
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public required String Title { get; set; }
    public  String? Author { get; set; }
    public String? Description { get; set; }
    public double Rating { get; set; } = 0.0;

    public  ReadingStatus Status { get; set; } = ReadingStatus.NotStarted;

    public enum ReadingStatus{NotStarted,InProgress,Completed}
}
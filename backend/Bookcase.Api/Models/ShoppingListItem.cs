namespace Bookcase.Api.Models;

public class ShoppingListItem
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    public required String Title { get; set; }
    public  String? Author { get; set; }
    public  decimal Price { get; set; }
    public bool Bought { get; set; } = false;

}
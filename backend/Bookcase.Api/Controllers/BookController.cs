using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Bookcase.Api.Data;
using Bookcase.Api.Models;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

namespace Bookcase.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class BookController : ControllerBase
{
    // Método auxiliar para obter o ID do usuário autenticado
    private int GetUserId()
    {
        var id = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        return int.Parse(id!);
    }

    // Injeção de dependência 
    private readonly AppDbContext _context;

    public BookController(AppDbContext context)
    {
        _context = context;
    }

    // GET /api/book (Lista todos os livros do usuário autenticado, com filtro opcional por status de leitura)
    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] Book.ReadingStatus? status)
    {
        var userId = GetUserId();
        var query = _context.Books.Where(book => book.UserId == userId);

        if(status != null)
        {
            query = query.Where(book => book.Status == status);
        }

        var books = await query.ToListAsync();
        return Ok(books);
    }

    // POST /api/book (Cria um novo livro)
    [HttpPost]
    public async Task<IActionResult> Create(Book book)
    {
        var userId = GetUserId();
        book.UserId = userId;
        book.CurrentPage = Math.Max(book.CurrentPage, 0);
        UpdateCompletion(book, book.CompletedAt);

        _context.Books.Add(book);
        await _context.SaveChangesAsync();
        return CreatedAtAction(nameof(GetById), new { id = book.Id }, book);
    }

    // GET /api/book/{id} (Obtém um livro específico pelo ID)
    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var book = await _context.Books.FindAsync(id);

        if (book == null || book.UserId != GetUserId()) return NotFound();

        return Ok(book);
    }

    // PUT api/book/{id} (Busca, Atualiza e Salva alterações de um livro específico pelo ID)
    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, Book book)
    {
        if (id != book.Id) return BadRequest();

        var existingBook = await _context.Books.FindAsync(id);
        if (existingBook == null || existingBook.UserId != GetUserId()) return NotFound();

        existingBook.Title = book.Title;
        existingBook.Author = book.Author;
        existingBook.Description = book.Description;
        existingBook.Rating = book.Rating;
        existingBook.Status = book.Status;
        existingBook.CurrentPage = Math.Max(book.CurrentPage, 0);
        UpdateCompletion(existingBook, book.CompletedAt ?? existingBook.CompletedAt);

        await _context.SaveChangesAsync();
        return NoContent();
    }

    // DELETE api/book/{id} (Deleta um livro específico pelo ID)
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var book = await _context.Books.FindAsync(id);

        if (book == null || book.UserId != GetUserId()) return NotFound();

        _context.Books.Remove(book);
        await _context.SaveChangesAsync();
        return NoContent();
    }

    private static void UpdateCompletion(Book book, DateTime? completedAt)
    {
        book.CompletedAt = book.Status == Book.ReadingStatus.Completed
            ? completedAt ?? DateTime.UtcNow
            : null;
    }
}
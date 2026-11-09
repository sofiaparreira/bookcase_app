using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Bookcase.Api.Data;
using Bookcase.Api.Models;
using Bookcase.Api.Dtos;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

namespace Bookcase.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ReadingGoalController : ControllerBase
{
    // Método auxiliar para obter o ID do usuário autenticado
    private int GetUserId()
    {
        var id = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        return int.Parse(id!);
    }
    
    // Injeção de dependência 
    private readonly AppDbContext _context;

    public ReadingGoalController(AppDbContext context)
    {
        _context = context;
    }

    // GET /api/readinggoal (Lista todos os objetivos de leitura)
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var userId = GetUserId();
        var goals = await _context.ReadingGoals
        .Include(goal => goal.Book)
        .Where(goal => goal.UserId == userId)
        .ToListAsync();
        return Ok(goals);
    }

    // POST /api/readinggoal (Cria um novo objetivo de leitura)
    [HttpPost]
    public async Task<IActionResult> Create(ReadingGoal goal)
    {
        var userId = GetUserId();
        goal.UserId = userId;

        var bookExists = await _context.Books.AnyAsync(b => b.Id == goal.BookId && b.UserId == userId);
        if (!bookExists) return BadRequest("Livro não encontrado.");

        _context.ReadingGoals.Add(goal);
        await _context.SaveChangesAsync();
        return CreatedAtAction(nameof(GetById), new { id = goal.Id }, goal);
    }

    // GET /api/readinggoal/{id} (Obtém um objetivo de leitura específico pelo ID)
    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var goal = await _context.ReadingGoals
            .Include(g => g.Book)
            .FirstOrDefaultAsync(g => g.Id == id);

        if (goal == null || goal.UserId != GetUserId()) return NotFound();

        return Ok(goal);
    }

    // PUT api/readinggoal/{id} (Busca, Atualiza e Salva alterações de um objetivo de leitura específico pelo ID)
    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, ReadingGoal goal)
    {
        if (id != goal.Id) return BadRequest();

        var userId = GetUserId();
        var existingGoal = await _context.ReadingGoals.FindAsync(id);
        if (existingGoal == null || existingGoal.UserId != userId) return NotFound();

        if (!await UserOwnsBook(goal.BookId, userId)) return BadRequest("Livro não encontrado.");
        if (goal.TargetPages <= 0) return BadRequest("Informe um número de páginas maior que zero.");

        existingGoal.Title = goal.Title;
        existingGoal.BookId = goal.BookId;
        existingGoal.TargetPages = goal.TargetPages;
        existingGoal.CurrentPage = Math.Max(goal.CurrentPage, 0);
        existingGoal.StartDate = goal.StartDate;
        existingGoal.EndDate = goal.EndDate;

        await _context.SaveChangesAsync();
        return NoContent();
    }

    // PATCH api/readinggoal/{id}/progress (Salva a página em que o usuário parou)
    [HttpPatch("{id}/progress")]
    public async Task<IActionResult> UpdateProgress(int id, UpdateGoalProgressDto dto)
    {
        if (dto.CurrentPage < 0) return BadRequest("A página não pode ser negativa.");

        var goal = await _context.ReadingGoals.FindAsync(id);
        if (goal == null || goal.UserId != GetUserId()) return NotFound();

        goal.CurrentPage = dto.CurrentPage;

        await _context.SaveChangesAsync();
        return Ok(goal);
    }

    // DELETE api/readinggoal/{id} (Deleta um objetivo de leitura específico pelo ID)
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var goal = await _context.ReadingGoals.FindAsync(id);
        if (goal == null || goal.UserId != GetUserId()) return NotFound();

        _context.ReadingGoals.Remove(goal);
        await _context.SaveChangesAsync();
        return NoContent();
    }

    private Task<bool> UserOwnsBook(int bookId, int userId) =>
        _context.Books.AnyAsync(b => b.Id == bookId && b.UserId == userId);
}

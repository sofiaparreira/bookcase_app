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

        _context.ReadingGoals.Add(goal);
        await _context.SaveChangesAsync();
        return CreatedAtAction(nameof(GetById), new { id = goal.Id }, goal);
    }

    // GET /api/readinggoal/{id} (Obtém um objetivo de leitura específico pelo ID)
    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var goal = await _context.ReadingGoals.FindAsync(id);

        if (goal == null || goal.UserId != GetUserId()) return NotFound();

        return Ok(goal);
    }

    // PUT api/readinggoal/{id} (Busca, Atualiza e Salva alterações de um objetivo de leitura específico pelo ID)
    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, ReadingGoal goal)
    {
        if (id != goal.Id) return BadRequest();

        var existingGoal = await _context.ReadingGoals.FindAsync(id);
        if (existingGoal == null || existingGoal.UserId != GetUserId()) return NotFound();

        existingGoal.Title = goal.Title;
        existingGoal.TargetBooks = goal.TargetBooks;
        existingGoal.CurrentBooks = goal.CurrentBooks;
        existingGoal.StartDate = goal.StartDate;
        existingGoal.EndDate = goal.EndDate;

        await _context.SaveChangesAsync();
        return NoContent();
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
}
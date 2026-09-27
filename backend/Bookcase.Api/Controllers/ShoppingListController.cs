using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Bookcase.Api.Data;
using Bookcase.Api.Models;
using Microsoft.AspNetCore.Authorization;

namespace Bookcase.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ShoppingListController : ControllerBase
{
    // Injeção de dependência 
    private readonly AppDbContext _context;

    public ShoppingListController(AppDbContext context)
    {
        _context = context;
    }

    // GET /api/shoppinglist (Lista todos os itens da lista de compras)
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var itens = await _context.ShoppingListItems.ToListAsync();
        return Ok(itens);
    }

    // POST /api/shoppinglist (Cria um novo item na lista de compras)
    [HttpPost]
    public async Task<IActionResult> Create(ShoppingListItem item)
    {
        _context.ShoppingListItems.Add(item);
        await _context.SaveChangesAsync();
        return CreatedAtAction(nameof(GetById), new { id = item.Id }, item);
    }

    // GET /api/shoppinglist/{id} (Obtém um item específico da lista de compras pelo ID)
    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var item = await _context.ShoppingListItems.FindAsync(id);

        if (item == null) return NotFound();

        return Ok(item);
    }

    // PUT api/shoppinglist/{id} (Busca, Atualiza e Salva alterações de um item específico da lista de compras pelo ID)
    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, ShoppingListItem item)
    {
        if (id != item.Id) return BadRequest();

        var existingItem = await _context.ShoppingListItems.FindAsync(id);
        if (existingItem == null) return NotFound();

        existingItem.Title = item.Title;
        existingItem.Author = item.Author;
        existingItem.Price = item.Price;
        existingItem.Bought = item.Bought;

        await _context.SaveChangesAsync();
        return NoContent();
    }

    // DELETE api/shoppinglist/{id} (Deleta um item específico da lista de compras pelo ID)
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var item = await _context.ShoppingListItems.FindAsync(id);

        if (item == null) return NotFound();

        _context.ShoppingListItems.Remove(item);
        await _context.SaveChangesAsync();
        return NoContent();
    }
}
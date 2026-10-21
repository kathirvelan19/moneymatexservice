package com.moneytrace.controller;

import com.moneytrace.dto.ExpenseDto;
import com.moneytrace.service.ExpenseService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/expenses")
public class ExpenseController {

    private final ExpenseService expenseService;

    public ExpenseController(ExpenseService expenseService) {
        this.expenseService = expenseService;
    }

    @GetMapping
    public ResponseEntity<List<ExpenseDto>> getAllExpenses() {
        return ResponseEntity.ok(expenseService.getAllExpenses());
    }

    @PostMapping
    public ResponseEntity<ExpenseDto> createExpense(@RequestBody ExpenseDto expenseDto) {
        return ResponseEntity.status(HttpStatus.CREATED).body(expenseService.createExpense(expenseDto));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ExpenseDto> updateExpense(@PathVariable String id, @RequestBody ExpenseDto expenseDto) {
        return ResponseEntity.ok(expenseService.updateExpense(id, expenseDto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteExpense(@PathVariable String id) {
        expenseService.deleteExpense(id);
        return ResponseEntity.noContent().build();
    }
}

package com.moneytrace.service;

import com.moneytrace.dto.ExpenseDto;
import com.moneytrace.model.Expense;
import com.moneytrace.repository.ExpenseRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ExpenseService {

    private final ExpenseRepository expenseRepository;

    public ExpenseService(ExpenseRepository expenseRepository) {
        this.expenseRepository = expenseRepository;
    }

    public List<ExpenseDto> getAllExpenses() {
        return expenseRepository.findAllByOrderByDateDesc().stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    public ExpenseDto createExpense(ExpenseDto dto) {
        Expense expense = mapToEntity(dto);
        Expense saved = expenseRepository.save(expense);
        return mapToDto(saved);
    }

    public ExpenseDto updateExpense(String id, ExpenseDto dto) {
        Expense existing = expenseRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Expense not found with id: " + id));

        existing.setAmount(dto.getAmount());
        existing.setCategory(dto.getCategory());
        existing.setDate(dto.getDate());
        existing.setNotes(dto.getNotes());
        existing.setPaymentMethod(dto.getPaymentMethod());

        Expense updated = expenseRepository.save(existing);
        return mapToDto(updated);
    }

    public void deleteExpense(String id) {
        expenseRepository.deleteById(id);
    }

    private ExpenseDto mapToDto(Expense entity) {
        return ExpenseDto.builder()
                .id(entity.getId())
                .amount(entity.getAmount())
                .category(entity.getCategory())
                .date(entity.getDate())
                .notes(entity.getNotes())
                .paymentMethod(entity.getPaymentMethod())
                .build();
    }

    private Expense mapToEntity(ExpenseDto dto) {
        return Expense.builder()
                .id(dto.getId())
                .amount(dto.getAmount())
                .category(dto.getCategory())
                .date(dto.getDate())
                .notes(dto.getNotes())
                .paymentMethod(dto.getPaymentMethod())
                .build();
    }
}

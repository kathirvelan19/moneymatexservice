package com.moneytrace.dto;

import com.moneytrace.model.Expense;
import java.util.List;

public class InsightsRequestDto {
    private List<Expense> expenses;

    public InsightsRequestDto() {}

    public InsightsRequestDto(List<Expense> expenses) {
        this.expenses = expenses;
    }

    public List<Expense> getExpenses() { return expenses; }
    public void setExpenses(List<Expense> expenses) { this.expenses = expenses; }
}

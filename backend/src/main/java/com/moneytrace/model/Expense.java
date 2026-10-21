package com.moneytrace.model;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "expenses")
public class Expense {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false)
    private Double amount;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Category category;

    @Column(nullable = false)
    private LocalDate date;

    private String notes;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PaymentMethod paymentMethod;

    public Expense() {}

    public Expense(String id, Double amount, Category category, LocalDate date, String notes, PaymentMethod paymentMethod) {
        this.id = id;
        this.amount = amount;
        this.category = category;
        this.date = date;
        this.notes = notes;
        this.paymentMethod = paymentMethod;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {
        private String id;
        private Double amount;
        private Category category;
        private LocalDate date;
        private String notes;
        private PaymentMethod paymentMethod;

        public Builder id(String id) { this.id = id; return this; }
        public Builder amount(Double amount) { this.amount = amount; return this; }
        public Builder category(Category category) { this.category = category; return this; }
        public Builder date(LocalDate date) { this.date = date; return this; }
        public Builder notes(String notes) { this.notes = notes; return this; }
        public Builder paymentMethod(PaymentMethod paymentMethod) { this.paymentMethod = paymentMethod; return this; }

        public Expense build() {
            return new Expense(id, amount, category, date, notes, paymentMethod);
        }
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public Double getAmount() { return amount; }
    public void setAmount(Double amount) { this.amount = amount; }

    public Category getCategory() { return category; }
    public void setCategory(Category category) { this.category = category; }

    public LocalDate getDate() { return date; }
    public void setDate(LocalDate date) { this.date = date; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public PaymentMethod getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(PaymentMethod paymentMethod) { this.paymentMethod = paymentMethod; }
}

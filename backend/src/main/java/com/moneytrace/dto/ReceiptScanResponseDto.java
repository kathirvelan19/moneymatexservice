package com.moneytrace.dto;

import com.moneytrace.model.Category;
import java.time.LocalDate;

public class ReceiptScanResponseDto {
    private boolean valid = true;
    private String message;
    private String merchantName;
    private LocalDate date;
    private double totalAmount;
    private Double taxAmount;
    private String originalImageBase64;
    private Category autoCategorized;

    public ReceiptScanResponseDto() {}

    public ReceiptScanResponseDto(boolean valid, String message, String merchantName, LocalDate date, double totalAmount, Double taxAmount, String originalImageBase64, Category autoCategorized) {
        this.valid = valid;
        this.message = message;
        this.merchantName = merchantName;
        this.date = date;
        this.totalAmount = totalAmount;
        this.taxAmount = taxAmount;
        this.originalImageBase64 = originalImageBase64;
        this.autoCategorized = autoCategorized;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {
        private boolean valid = true;
        private String message;
        private String merchantName;
        private LocalDate date;
        private double totalAmount;
        private Double taxAmount;
        private String originalImageBase64;
        private Category autoCategorized;

        public Builder valid(boolean valid) { this.valid = valid; return this; }
        public Builder message(String message) { this.message = message; return this; }
        public Builder merchantName(String merchantName) { this.merchantName = merchantName; return this; }
        public Builder date(LocalDate date) { this.date = date; return this; }
        public Builder totalAmount(double totalAmount) { this.totalAmount = totalAmount; return this; }
        public Builder taxAmount(Double taxAmount) { this.taxAmount = taxAmount; return this; }
        public Builder originalImageBase64(String originalImageBase64) { this.originalImageBase64 = originalImageBase64; return this; }
        public Builder autoCategorized(Category autoCategorized) { this.autoCategorized = autoCategorized; return this; }

        public ReceiptScanResponseDto build() {
            return new ReceiptScanResponseDto(valid, message, merchantName, date, totalAmount, taxAmount, originalImageBase64, autoCategorized);
        }
    }

    public boolean isValid() { return valid; }
    public void setValid(boolean valid) { this.valid = valid; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getMerchantName() { return merchantName; }
    public void setMerchantName(String merchantName) { this.merchantName = merchantName; }

    public LocalDate getDate() { return date; }
    public void setDate(LocalDate date) { this.date = date; }

    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }

    public Double getTaxAmount() { return taxAmount; }
    public void setTaxAmount(Double taxAmount) { this.taxAmount = taxAmount; }

    public String getOriginalImageBase64() { return originalImageBase64; }
    public void setOriginalImageBase64(String originalImageBase64) { this.originalImageBase64 = originalImageBase64; }

    public Category getAutoCategorized() { return autoCategorized; }
    public void setAutoCategorized(Category autoCategorized) { this.autoCategorized = autoCategorized; }
}

package com.moneytrace.dto;

import com.moneytrace.model.Category;
import java.time.LocalDate;

public class UpiScanResponseDto {
    private double paidAmount;
    private String receiverName;
    private LocalDate dateTime;
    private String transactionId;
    private String originalImageBase64;
    private Category autoCategorized;

    public UpiScanResponseDto() {}

    public UpiScanResponseDto(double paidAmount, String receiverName, LocalDate dateTime, String transactionId, String originalImageBase64, Category autoCategorized) {
        this.paidAmount = paidAmount;
        this.receiverName = receiverName;
        this.dateTime = dateTime;
        this.transactionId = transactionId;
        this.originalImageBase64 = originalImageBase64;
        this.autoCategorized = autoCategorized;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {
        private double paidAmount;
        private String receiverName;
        private LocalDate dateTime;
        private String transactionId;
        private String originalImageBase64;
        private Category autoCategorized;

        public Builder paidAmount(double paidAmount) { this.paidAmount = paidAmount; return this; }
        public Builder receiverName(String receiverName) { this.receiverName = receiverName; return this; }
        public Builder dateTime(LocalDate dateTime) { this.dateTime = dateTime; return this; }
        public Builder transactionId(String transactionId) { this.transactionId = transactionId; return this; }
        public Builder originalImageBase64(String originalImageBase64) { this.originalImageBase64 = originalImageBase64; return this; }
        public Builder autoCategorized(Category autoCategorized) { this.autoCategorized = autoCategorized; return this; }

        public UpiScanResponseDto build() {
            return new UpiScanResponseDto(paidAmount, receiverName, dateTime, transactionId, originalImageBase64, autoCategorized);
        }
    }

    public double getPaidAmount() { return paidAmount; }
    public void setPaidAmount(double paidAmount) { this.paidAmount = paidAmount; }

    public String getReceiverName() { return receiverName; }
    public void setReceiverName(String receiverName) { this.receiverName = receiverName; }

    public LocalDate getDateTime() { return dateTime; }
    public void setDateTime(LocalDate dateTime) { this.dateTime = dateTime; }

    public String getTransactionId() { return transactionId; }
    public void setTransactionId(String transactionId) { this.transactionId = transactionId; }

    public String getOriginalImageBase64() { return originalImageBase64; }
    public void setOriginalImageBase64(String originalImageBase64) { this.originalImageBase64 = originalImageBase64; }

    public Category getAutoCategorized() { return autoCategorized; }
    public void setAutoCategorized(Category autoCategorized) { this.autoCategorized = autoCategorized; }
}

package com.moneytrace.dto;

import com.moneytrace.model.Category;
import java.time.LocalDate;

public class NotificationDetectResponseDto {
    private boolean valid = true;
    private String message;
    private double paidAmount;
    private String merchant;
    private String paymentApp;
    private String transactionId;
    private LocalDate dateTime;
    private Category autoCategorized;
    private boolean isDebit;
    private String rawMessage;
    private String summary;

    public NotificationDetectResponseDto() {}

    public NotificationDetectResponseDto(boolean valid, String message, double paidAmount, String merchant, String paymentApp, String transactionId, LocalDate dateTime, Category autoCategorized, boolean isDebit, String rawMessage, String summary) {
        this.valid = valid;
        this.message = message;
        this.paidAmount = paidAmount;
        this.merchant = merchant;
        this.paymentApp = paymentApp;
        this.transactionId = transactionId;
        this.dateTime = dateTime;
        this.autoCategorized = autoCategorized;
        this.isDebit = isDebit;
        this.rawMessage = rawMessage;
        this.summary = summary;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {
        private boolean valid = true;
        private String message;
        private double paidAmount;
        private String merchant;
        private String paymentApp;
        private String transactionId;
        private LocalDate dateTime;
        private Category autoCategorized;
        private boolean isDebit = true;
        private String rawMessage;
        private String summary;

        public Builder valid(boolean valid) { this.valid = valid; return this; }
        public Builder message(String message) { this.message = message; return this; }
        public Builder paidAmount(double paidAmount) { this.paidAmount = paidAmount; return this; }
        public Builder merchant(String merchant) { this.merchant = merchant; return this; }
        public Builder paymentApp(String paymentApp) { this.paymentApp = paymentApp; return this; }
        public Builder transactionId(String transactionId) { this.transactionId = transactionId; return this; }
        public Builder dateTime(LocalDate dateTime) { this.dateTime = dateTime; return this; }
        public Builder autoCategorized(Category autoCategorized) { this.autoCategorized = autoCategorized; return this; }
        public Builder isDebit(boolean isDebit) { this.isDebit = isDebit; return this; }
        public Builder rawMessage(String rawMessage) { this.rawMessage = rawMessage; return this; }
        public Builder summary(String summary) { this.summary = summary; return this; }

        public NotificationDetectResponseDto build() {
            return new NotificationDetectResponseDto(valid, message, paidAmount, merchant, paymentApp, transactionId, dateTime, autoCategorized, isDebit, rawMessage, summary);
        }
    }

    public boolean isValid() { return valid; }
    public void setValid(boolean valid) { this.valid = valid; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public double getPaidAmount() { return paidAmount; }
    public void setPaidAmount(double paidAmount) { this.paidAmount = paidAmount; }

    public String getMerchant() { return merchant; }
    public void setMerchant(String merchant) { this.merchant = merchant; }

    public String getPaymentApp() { return paymentApp; }
    public void setPaymentApp(String paymentApp) { this.paymentApp = paymentApp; }

    public String getTransactionId() { return transactionId; }
    public void setTransactionId(String transactionId) { this.transactionId = transactionId; }

    public LocalDate getDateTime() { return dateTime; }
    public void setDateTime(LocalDate dateTime) { this.dateTime = dateTime; }

    public Category getAutoCategorized() { return autoCategorized; }
    public void setAutoCategorized(Category autoCategorized) { this.autoCategorized = autoCategorized; }

    public boolean isDebit() { return isDebit; }
    public void setDebit(boolean isDebit) { this.isDebit = isDebit; }

    public String getRawMessage() { return rawMessage; }
    public void setRawMessage(String rawMessage) { this.rawMessage = rawMessage; }

    public String getSummary() { return summary; }
    public void setSummary(String summary) { this.summary = summary; }
}

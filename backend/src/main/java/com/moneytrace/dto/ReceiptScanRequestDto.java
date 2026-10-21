package com.moneytrace.dto;

public class ReceiptScanRequestDto {
    private String base64Image;

    public ReceiptScanRequestDto() {}

    public ReceiptScanRequestDto(String base64Image) {
        this.base64Image = base64Image;
    }

    public String getBase64Image() { return base64Image; }
    public void setBase64Image(String base64Image) { this.base64Image = base64Image; }
}

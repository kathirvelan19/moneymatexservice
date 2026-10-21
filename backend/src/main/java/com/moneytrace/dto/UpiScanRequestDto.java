package com.moneytrace.dto;

public class UpiScanRequestDto {
    private String base64Image;

    public UpiScanRequestDto() {}

    public UpiScanRequestDto(String base64Image) {
        this.base64Image = base64Image;
    }

    public String getBase64Image() { return base64Image; }
    public void setBase64Image(String base64Image) { this.base64Image = base64Image; }
}

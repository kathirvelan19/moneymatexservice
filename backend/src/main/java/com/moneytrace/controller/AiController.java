package com.moneytrace.controller;

import com.moneytrace.dto.*;
import com.moneytrace.service.GeminiAiService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/ai")
public class AiController {

    private final GeminiAiService geminiAiService;

    public AiController(GeminiAiService geminiAiService) {
        this.geminiAiService = geminiAiService;
    }

    @PostMapping("/scan-receipt")
    public ResponseEntity<ReceiptScanResponseDto> scanReceipt(@RequestBody ReceiptScanRequestDto request) {
        return ResponseEntity.ok(geminiAiService.scanReceipt(request.getBase64Image()));
    }

    @PostMapping("/scan-upi")
    public ResponseEntity<UpiScanResponseDto> scanUpi(@RequestBody UpiScanRequestDto request) {
        return ResponseEntity.ok(geminiAiService.scanUpiScreenshot(request.getBase64Image()));
    }

    @PostMapping("/insights")
    public ResponseEntity<InsightsResponseDto> getInsights(@RequestBody InsightsRequestDto request) {
        return ResponseEntity.ok(geminiAiService.generateInsights(request.getExpenses()));
    }

    @PostMapping("/parse-notification")
    public ResponseEntity<NotificationDetectResponseDto> parseNotification(@RequestBody NotificationDetectRequestDto request) {
        return ResponseEntity.ok(geminiAiService.parsePaymentNotification(request));
    }
}

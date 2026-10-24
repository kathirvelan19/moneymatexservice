package com.moneytrace.controller;

import com.moneytrace.dto.*;
import com.moneytrace.service.GeminiAiService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Base64;

@RestController
@RequestMapping("/api/ai")
public class AiController {

    private final GeminiAiService geminiAiService;

    public AiController(GeminiAiService geminiAiService) {
        this.geminiAiService = geminiAiService;
    }

    @PostMapping(value = "/scan-receipt", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<ReceiptScanResponseDto> scanReceipt(@RequestBody ReceiptScanRequestDto request) {
        return ResponseEntity.ok(geminiAiService.scanReceipt(request.getBase64Image()));
    }

    @PostMapping(value = "/scan-receipt", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ReceiptScanResponseDto> scanReceiptMultipart(
            @RequestParam(value = "file", required = false) MultipartFile file,
            @RequestParam(value = "image", required = false) MultipartFile image) {
        MultipartFile target = file != null ? file : image;
        if (target == null || target.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        try {
            String base64 = Base64.getEncoder().encodeToString(target.getBytes());
            return ResponseEntity.ok(geminiAiService.scanReceipt(base64));
        } catch (IOException e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @PostMapping(value = "/scan-upi", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<UpiScanResponseDto> scanUpi(@RequestBody UpiScanRequestDto request) {
        return ResponseEntity.ok(geminiAiService.scanUpiScreenshot(request.getBase64Image()));
    }

    @PostMapping(value = "/scan-upi", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<UpiScanResponseDto> scanUpiMultipart(
            @RequestParam(value = "file", required = false) MultipartFile file,
            @RequestParam(value = "image", required = false) MultipartFile image) {
        MultipartFile target = file != null ? file : image;
        if (target == null || target.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        try {
            String base64 = Base64.getEncoder().encodeToString(target.getBytes());
            return ResponseEntity.ok(geminiAiService.scanUpiScreenshot(base64));
        } catch (IOException e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @PostMapping(value = "/insights", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<InsightsResponseDto> getInsights(@RequestBody InsightsRequestDto request) {
        return ResponseEntity.ok(geminiAiService.generateInsights(request.getExpenses()));
    }

    @PostMapping(value = "/parse-notification", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<NotificationDetectResponseDto> parseNotification(@RequestBody NotificationDetectRequestDto request) {
        return ResponseEntity.ok(geminiAiService.parsePaymentNotification(request));
    }
}

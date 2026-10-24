package com.moneytrace.controller;

import com.moneytrace.service.GeminiAiService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.LinkedHashMap;
import java.util.Map;

@RestController
public class HealthController {

    private final GeminiAiService geminiAiService;

    public HealthController(GeminiAiService geminiAiService) {
        this.geminiAiService = geminiAiService;
    }

    @GetMapping({"/health", "/api/health"})
    public ResponseEntity<Map<String, Object>> healthCheck() {
        Map<String, Object> response = new LinkedHashMap<>();
        response.put("status", "UP");
        response.put("service", "moneytrace-backend");
        response.put("geminiConfigured", geminiAiService.isConfigured());
        response.put("geminiKeyMasked", geminiAiService.getMaskedApiKey());
        return ResponseEntity.ok(response);
    }

    @GetMapping({"/health/gemini", "/api/ai/test-key"})
    public ResponseEntity<Map<String, Object>> testGeminiKey() {
        return ResponseEntity.ok(geminiAiService.testConnection());
    }
}


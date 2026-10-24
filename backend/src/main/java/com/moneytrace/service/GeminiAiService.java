package com.moneytrace.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.moneytrace.dto.*;
import com.moneytrace.model.Category;
import com.moneytrace.model.Expense;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.LocalDate;
import java.util.*;

@Service
public class GeminiAiService {

    private static final Logger log = LoggerFactory.getLogger(GeminiAiService.class);

    @Value("${gemini.api.key:}")
    private String rawApiKey;

    @Value("${gemini.api.model:gemini-2.5-flash}")
    private String modelName;

    private final ObjectMapper objectMapper = new ObjectMapper();
    private final HttpClient httpClient = HttpClient.newHttpClient();

    private String getApiKey() {
        return rawApiKey != null ? rawApiKey.trim() : "";
    }

    public boolean isConfigured() {
        return !getApiKey().isBlank();
    }

    public String getMaskedApiKey() {
        String key = getApiKey();
        if (key.isBlank()) return "NOT_CONFIGURED";
        if (key.length() <= 8) return "KEY_TOO_SHORT";
        return key.substring(0, 6) + "..." + key.substring(key.length() - 4);
    }

    public Map<String, Object> testConnection() {
        String key = getApiKey();
        if (key.isBlank()) {
            return Map.of(
                    "status", "ERROR",
                    "configured", false,
                    "message", "Gemini API key is not configured in environment (GEMINI_API_KEY is empty)"
            );
        }

        try {
            String prompt = "Reply with {\"status\":\"OK\"}";
            String res = callGeminiApiTextOnly(prompt);
            return Map.of(
                    "status", "SUCCESS",
                    "configured", true,
                    "model", modelName,
                    "keyMasked", getMaskedApiKey(),
                    "response", res
            );
        } catch (Exception e) {
            log.error("Gemini key connectivity test failed", e);
            return Map.of(
                    "status", "FAILED",
                    "configured", true,
                    "model", modelName,
                    "keyMasked", getMaskedApiKey(),
                    "error", e.getMessage() != null ? e.getMessage() : "Unknown error"
            );
        }
    }

    private static final Map<String, Category> KEYWORD_CATEGORIES = Map.ofEntries(
            // Food
            Map.entry("swiggy", Category.Food),
            Map.entry("zomato", Category.Food),
            Map.entry("restaurant", Category.Food),
            Map.entry("cafe", Category.Food),
            Map.entry("coffee", Category.Food),
            Map.entry("starbucks", Category.Food),
            Map.entry("mcdonald", Category.Food),
            Map.entry("kfc", Category.Food),
            Map.entry("burger", Category.Food),
            Map.entry("pizza", Category.Food),
            Map.entry("domino", Category.Food),
            Map.entry("subway", Category.Food),
            Map.entry("bakery", Category.Food),
            Map.entry("bistro", Category.Food),
            Map.entry("tea", Category.Food),
            Map.entry("chai", Category.Food),
            Map.entry("haldiram", Category.Food),
            Map.entry("canteen", Category.Food),
            Map.entry("dmart", Category.Food),
            Map.entry("d-mart", Category.Food),
            Map.entry("blinkit", Category.Food),
            Map.entry("zepto", Category.Food),
            Map.entry("instamart", Category.Food),
            Map.entry("bigbasket", Category.Food),
            Map.entry("grocery", Category.Food),
            Map.entry("supermarket", Category.Food),
            // Travel
            Map.entry("uber", Category.Travel),
            Map.entry("ola", Category.Travel),
            Map.entry("rapido", Category.Travel),
            Map.entry("petrol", Category.Travel),
            Map.entry("fuel", Category.Travel),
            Map.entry("diesel", Category.Travel),
            Map.entry("shell", Category.Travel),
            Map.entry("indian oil", Category.Travel),
            Map.entry("indianoil", Category.Travel),
            Map.entry("bpcl", Category.Travel),
            Map.entry("hpcl", Category.Travel),
            Map.entry("toll", Category.Travel),
            Map.entry("fastag", Category.Travel),
            Map.entry("metro", Category.Travel),
            Map.entry("flight", Category.Travel),
            Map.entry("irctc", Category.Travel),
            Map.entry("airline", Category.Travel),
            Map.entry("indigo", Category.Travel),
            Map.entry("air india", Category.Travel),
            Map.entry("redbus", Category.Travel),
            Map.entry("bus", Category.Travel),
            Map.entry("cab", Category.Travel),
            Map.entry("taxi", Category.Travel),
            // Shopping
            Map.entry("amazon", Category.Shopping),
            Map.entry("flipkart", Category.Shopping),
            Map.entry("myntra", Category.Shopping),
            Map.entry("ajio", Category.Shopping),
            Map.entry("meesho", Category.Shopping),
            Map.entry("zara", Category.Shopping),
            Map.entry("h&m", Category.Shopping),
            Map.entry("croma", Category.Shopping),
            Map.entry("reliance digital", Category.Shopping),
            Map.entry("apple", Category.Shopping),
            Map.entry("decathlon", Category.Shopping),
            Map.entry("store", Category.Shopping),
            Map.entry("mall", Category.Shopping),
            Map.entry("clothing", Category.Shopping),
            // Bills
            Map.entry("electricity", Category.Bills),
            Map.entry("bescom", Category.Bills),
            Map.entry("tneb", Category.Bills),
            Map.entry("bses", Category.Bills),
            Map.entry("water", Category.Bills),
            Map.entry("gas", Category.Bills),
            Map.entry("broadband", Category.Bills),
            Map.entry("wifi", Category.Bills),
            Map.entry("rent", Category.Bills),
            Map.entry("bill", Category.Bills),
            Map.entry("maintenance", Category.Bills),
            // Recharge
            Map.entry("airtel", Category.Recharge),
            Map.entry("jio", Category.Recharge),
            Map.entry("vi", Category.Recharge),
            Map.entry("vodafone", Category.Recharge),
            Map.entry("recharge", Category.Recharge),
            Map.entry("dth", Category.Recharge),
            Map.entry("tata play", Category.Recharge),
            // Healthcare
            Map.entry("hospital", Category.Healthcare),
            Map.entry("clinic", Category.Healthcare),
            Map.entry("pharmacy", Category.Healthcare),
            Map.entry("medical", Category.Healthcare),
            Map.entry("apollo", Category.Healthcare),
            Map.entry("netmeds", Category.Healthcare),
            Map.entry("pharmeasy", Category.Healthcare),
            Map.entry("1mg", Category.Healthcare),
            Map.entry("doctor", Category.Healthcare),
            // Entertainment
            Map.entry("cinema", Category.Entertainment),
            Map.entry("movie", Category.Entertainment),
            Map.entry("pvr", Category.Entertainment),
            Map.entry("inox", Category.Entertainment),
            Map.entry("cinepolis", Category.Entertainment),
            Map.entry("bookmyshow", Category.Entertainment),
            Map.entry("netflix", Category.Entertainment),
            Map.entry("prime video", Category.Entertainment),
            Map.entry("hotstar", Category.Entertainment),
            Map.entry("spotify", Category.Entertainment),
            Map.entry("youtube", Category.Entertainment),
            Map.entry("game", Category.Entertainment)
    );

    public ReceiptScanResponseDto scanReceipt(String base64Image) {
        try {
            String cleanedImage = cleanBase64(base64Image);
            String prompt = "You are an expert OCR receipt parser. Examine this image carefully.\n" +
                    "First check: Is this image actually a bill, purchase receipt, tax invoice, or payment voucher?\n" +
                    "If the image is NOT a receipt or bill (for example: a random selfie, animal, scenery, person, meme, object, non-bill document, blank, or completely blurry/unreadable image):\n" +
                    "Return ONLY this raw JSON:\n" +
                    "{\"isValid\": false, \"message\": \"No receipt detected. The uploaded image does not appear to be a valid bill or receipt. Please upload a clear photo of a printed receipt or invoice.\"}\n\n" +
                    "If it IS a valid receipt:\n" +
                    "Return raw JSON with keys:\n" +
                    "{\"isValid\": true, \"merchantName\": (string), \"date\": (YYYY-MM-DD string), \"totalAmount\": (number), \"taxAmount\": (number), \"category\": (one of Food, Travel, Shopping, Bills, Recharge, Entertainment, Healthcare, Others), \"message\": null}.\n" +
                    "Carefully inspect items, store name, and type to accurately categorize the expense. Return raw JSON only.";

            String jsonResponse = callGeminiApiWithImage(cleanedImage, prompt);
            JsonNode root = objectMapper.readTree(jsonResponse);

            boolean isValid = root.path("isValid").asBoolean(true);
            double total = root.path("totalAmount").asDouble(0.0);

            if (!isValid || total <= 0) {
                String errMsg = root.hasNonNull("message") ? root.path("message").asText() :
                        "No receipt detected. The uploaded image does not appear to be a bill or receipt.";
                return ReceiptScanResponseDto.builder()
                        .valid(false)
                        .message(errMsg)
                        .merchantName(null)
                        .totalAmount(0.0)
                        .originalImageBase64(base64Image)
                        .autoCategorized(Category.Others)
                        .build();
            }

            String merchant = root.path("merchantName").asText("Store");
            String dateStr = root.path("date").asText(LocalDate.now().toString());
            double tax = root.path("taxAmount").asDouble(0.0);
            String rawCategory = root.hasNonNull("category") ? root.path("category").asText() : null;

            LocalDate date;
            try {
                date = LocalDate.parse(dateStr);
            } catch (Exception e) {
                date = LocalDate.now();
            }

            return ReceiptScanResponseDto.builder()
                    .valid(true)
                    .message("Receipt parsed successfully")
                    .merchantName(merchant)
                    .date(date)
                    .totalAmount(total)
                    .taxAmount(tax)
                    .originalImageBase64(base64Image)
                    .autoCategorized(resolveCategory(rawCategory, merchant))
                    .build();

        } catch (Exception e) {
            log.warn("Gemini OCR parsing encountered issue: {}. Returning truthful error.", e.getMessage());
            return fallbackReceiptScan(base64Image);
        }
    }

    private ReceiptScanResponseDto fallbackReceiptScan(String base64Image) {
        return ReceiptScanResponseDto.builder()
                .valid(false)
                .message("Could not detect any receipt details in the uploaded image. Please ensure you upload a clear, well-lit photo of a receipt or bill.")
                .merchantName(null)
                .totalAmount(0.0)
                .originalImageBase64(base64Image)
                .autoCategorized(Category.Others)
                .build();
    }

    public UpiScanResponseDto scanUpiScreenshot(String base64Image) {
        try {
            String cleanedImage = cleanBase64(base64Image);
            String prompt = "You are an expert UPI payment receipt analyzer. Examine this image carefully.\n" +
                    "First check: Is this image a payment confirmation screenshot (from Google Pay, PhonePe, Paytm, BHIM, CRED, or bank UPI apps showing a completed transaction)?\n" +
                    "If the image is NOT a payment confirmation screenshot (for example: a random photo, personal picture, scenery, social media chat, or non-payment screen):\n" +
                    "Return ONLY this raw JSON:\n" +
                    "{\"isValid\": false, \"message\": \"No payment details found. The uploaded image does not appear to be a UPI payment confirmation screenshot. Please upload a clear screenshot of your completed transaction.\"}\n\n" +
                    "If it IS a valid payment screenshot:\n" +
                    "Return raw JSON with keys:\n" +
                    "{\"isValid\": true, \"paidAmount\": (number), \"receiverName\": (string), \"dateTime\": (YYYY-MM-DD string), \"transactionId\": (string), \"category\": (one of Food, Travel, Shopping, Bills, Recharge, Entertainment, Healthcare, Others), \"message\": null}.\n" +
                    "Accurately infer category from receiver name, payment note/remarks, or merchant logos. Return raw JSON only.";

            String jsonResponse = callGeminiApiWithImage(cleanedImage, prompt);
            JsonNode root = objectMapper.readTree(jsonResponse);

            boolean isValid = root.path("isValid").asBoolean(true);
            double amount = root.path("paidAmount").asDouble(0.0);

            if (!isValid || amount <= 0) {
                String errMsg = root.hasNonNull("message") ? root.path("message").asText() :
                        "No payment details found. The uploaded image does not appear to be a UPI payment confirmation screenshot.";
                return UpiScanResponseDto.builder()
                        .valid(false)
                        .message(errMsg)
                        .receiverName(null)
                        .paidAmount(0.0)
                        .originalImageBase64(base64Image)
                        .autoCategorized(Category.Others)
                        .build();
            }

            String receiver = root.path("receiverName").asText("Recipient");
            String dateStr = root.path("dateTime").asText(LocalDate.now().toString());
            String txnId = root.path("transactionId").asText("N/A");
            String rawCategory = root.hasNonNull("category") ? root.path("category").asText() : null;

            LocalDate date;
            try {
                date = LocalDate.parse(dateStr.substring(0, Math.min(10, dateStr.length())));
            } catch (Exception e) {
                date = LocalDate.now();
            }

            return UpiScanResponseDto.builder()
                    .valid(true)
                    .message("UPI payment details parsed successfully")
                    .paidAmount(amount)
                    .receiverName(receiver)
                    .dateTime(date)
                    .transactionId(txnId)
                    .originalImageBase64(base64Image)
                    .autoCategorized(resolveCategory(rawCategory, receiver))
                    .build();

        } catch (Exception e) {
            log.warn("Gemini UPI screenshot parsing encountered issue: {}. Returning truthful error.", e.getMessage());
            return fallbackUpiScan(base64Image);
        }
    }

    private UpiScanResponseDto fallbackUpiScan(String base64Image) {
        return UpiScanResponseDto.builder()
                .valid(false)
                .message("Could not detect any UPI payment details in the uploaded image. Please upload a clear screenshot of a completed payment.")
                .receiverName(null)
                .paidAmount(0.0)
                .originalImageBase64(base64Image)
                .autoCategorized(Category.Others)
                .build();
    }

    public InsightsResponseDto generateInsights(List<Expense> expenses) {
        try {
            List<Map<String, Object>> summary = new ArrayList<>();
            for (Expense e : expenses) {
                Map<String, Object> map = new HashMap<>();
                map.put("amount", e.getAmount());
                map.put("category", e.getCategory().name());
                map.put("date", e.getDate() != null ? e.getDate().toString() : "");
                summary.add(map);
            }

            String prompt = "Analyze these expense items. Return a raw JSON object with an array of strings under key \"insights\". Data: " + objectMapper.writeValueAsString(summary);
            String jsonResponse = callGeminiApiTextOnly(prompt);
            JsonNode root = objectMapper.readTree(jsonResponse);

            List<String> insights = new ArrayList<>();
            JsonNode arr = root.path("insights");
            if (arr.isArray()) {
                for (JsonNode n : arr) {
                    insights.add(n.asText());
                }
            }

            if (insights.isEmpty()) {
                insights.add("Keep monitoring your expenses daily to discover financial optimization opportunities!");
            }

            return InsightsResponseDto.builder().insights(insights).build();

        } catch (Exception e) {
            log.error("Error generating insights with Gemini 3.6", e);
            return InsightsResponseDto.builder()
                    .insights(List.of("Unable to generate insights at this moment. Please try again later."))
                    .build();
        }
    }

    public NotificationDetectResponseDto parsePaymentNotification(NotificationDetectRequestDto request) {
        String msg = request != null && request.getMessage() != null ? request.getMessage() : "";
        String sender = request != null && request.getSender() != null ? request.getSender() : "UPI";

        try {
            String prompt = "You are an intelligent financial ledger parser. Parse this payment notification or SMS.\n" +
                    "First check: Does this message describe a real financial transaction, payment, debit, or credit?\n" +
                    "If the message is NOT a payment notification (e.g., OTP message, personal chat, marketing ad, balance inquiry without transaction, or random text):\n" +
                    "Return ONLY this raw JSON:\n" +
                    "{\"isValid\": false, \"message\": \"No payment transaction details found in this message.\"}\n\n" +
                    "If it IS a real payment transaction, return raw JSON with keys:\n" +
                    "{\"isValid\": true, \"amount\": (number), \"merchant\": (string), \"category\": (one of Food, Travel, Shopping, Bills, Recharge, Entertainment, Healthcare, Others), \"paymentApp\": (string), \"transactionId\": (string or N/A), \"isDebit\": (boolean), \"date\": (YYYY-MM-DD string), \"message\": null}.\n" +
                    "Sender: \"" + sender + "\", Message: \"" + msg.replace("\"", "\\\"") + "\". Return raw JSON only.";

            String jsonResponse = callGeminiApiTextOnly(prompt);
            JsonNode root = objectMapper.readTree(jsonResponse);

            boolean isValid = root.path("isValid").asBoolean(true);
            double amount = root.path("amount").asDouble(0.0);

            if (!isValid || amount <= 0) {
                String errMsg = root.hasNonNull("message") ? root.path("message").asText() :
                        "No payment details detected. This message does not appear to be a transaction notification.";
                return NotificationDetectResponseDto.builder()
                        .valid(false)
                        .message(errMsg)
                        .paidAmount(0.0)
                        .merchant("None")
                        .paymentApp(sender)
                        .rawMessage(msg)
                        .summary("No transaction detected")
                        .build();
            }

            String merchant = root.path("merchant").asText("Merchant");
            String catStr = root.path("category").asText("Others");
            String paymentApp = root.path("paymentApp").asText(sender);
            String txnId = root.path("transactionId").asText("N/A");
            boolean isDebit = root.path("isDebit").asBoolean(true);
            String dateStr = root.path("date").asText(LocalDate.now().toString());

            LocalDate date;
            try {
                date = LocalDate.parse(dateStr.substring(0, Math.min(10, dateStr.length())));
            } catch (Exception e) {
                date = LocalDate.now();
            }

            return NotificationDetectResponseDto.builder()
                    .valid(true)
                    .message("Payment detected")
                    .paidAmount(amount)
                    .merchant(merchant)
                    .paymentApp(paymentApp)
                    .transactionId(txnId)
                    .dateTime(date)
                    .autoCategorized(resolveCategory(catStr, merchant))
                    .isDebit(isDebit)
                    .rawMessage(msg)
                    .summary(String.format("Auto-detected %s payment of ₹%.2f to %s", paymentApp, amount, merchant))
                    .build();

        } catch (Exception e) {
            log.warn("Gemini notification parse failed ({}), using regex heuristic fallback", e.getMessage());
            return fallbackNotificationParse(request);
        }
    }

    private NotificationDetectResponseDto fallbackNotificationParse(NotificationDetectRequestDto request) {
        String msg = request != null && request.getMessage() != null ? request.getMessage() : "";
        String sender = request != null && request.getSender() != null ? request.getSender() : "UPI";

        double amount = 0.0;
        String merchant = "Merchant";
        String txnId = "N/A";
        boolean isDebit = true;

        // Detect credit vs debit
        String lower = msg.toLowerCase();
        if (lower.contains("credited") || lower.contains("received") || lower.contains("deposited")) {
            isDebit = false;
        }

        // Amount regex
        java.util.regex.Pattern amtPattern = java.util.regex.Pattern.compile("(?:rs\\.?|inr|₹)\\s*([\\d,]+(?:\\.\\d{1,2})?)", java.util.regex.Pattern.CASE_INSENSITIVE);
        java.util.regex.Matcher amtMatcher = amtPattern.matcher(msg);
        if (amtMatcher.find()) {
            try {
                String amtStr = amtMatcher.group(1).replace(",", "");
                amount = Double.parseDouble(amtStr);
            } catch (Exception ignored) {}
        }

        // If no amount was found in text, do NOT invent fake data
        if (amount <= 0) {
            return NotificationDetectResponseDto.builder()
                    .valid(false)
                    .message("No payment amount detected in this message. Cannot log as transaction.")
                    .paidAmount(0.0)
                    .merchant("None")
                    .paymentApp(sender)
                    .rawMessage(msg)
                    .summary("No payment detected")
                    .build();
        }

        txnId = "UPI/" + (1000000000L + (long)(Math.random() * 8999999999L));

        // Merchant regex
        java.util.regex.Pattern merchPattern = java.util.regex.Pattern.compile("(?:to|at|paid to|transfer to)\\s+([A-Za-z0-9\\s&'-]+?)(?:\\s+on|\\s+ref|\\s+via|\\s+using|\\s+upi|\\.|,|$)", java.util.regex.Pattern.CASE_INSENSITIVE);
        java.util.regex.Matcher merchMatcher = merchPattern.matcher(msg);
        if (merchMatcher.find()) {
            String found = merchMatcher.group(1).trim();
            if (found.length() > 1 && found.length() < 35) {
                merchant = found;
            }
        } else if (lower.contains("swiggy")) {
            merchant = "Swiggy";
        } else if (lower.contains("zomato")) {
            merchant = "Zomato";
        } else if (lower.contains("uber")) {
            merchant = "Uber";
        } else if (lower.contains("ola")) {
            merchant = "Ola";
        } else if (lower.contains("amazon")) {
            merchant = "Amazon";
        } else if (lower.contains("flipkart")) {
            merchant = "Flipkart";
        }

        // Payment app inference
        String paymentApp = sender;
        if (lower.contains("google pay") || lower.contains("gpay")) {
            paymentApp = "Google Pay";
        } else if (lower.contains("phonepe")) {
            paymentApp = "PhonePe";
        } else if (lower.contains("paytm")) {
            paymentApp = "Paytm";
        } else if (lower.contains("cred")) {
            paymentApp = "CRED";
        } else if (lower.contains("hdfc")) {
            paymentApp = "HDFC Bank";
        } else if (lower.contains("sbi")) {
            paymentApp = "SBI";
        } else if (lower.contains("icici")) {
            paymentApp = "ICICI Bank";
        }

        Category autoCat = resolveCategory(null, merchant);

        return NotificationDetectResponseDto.builder()
                .valid(true)
                .message("Payment detected")
                .paidAmount(amount)
                .merchant(merchant)
                .paymentApp(paymentApp)
                .transactionId(txnId)
                .dateTime(LocalDate.now())
                .autoCategorized(autoCat)
                .isDebit(isDebit)
                .rawMessage(msg)
                .summary(String.format("Auto-detected %s payment of ₹%.2f to %s", paymentApp, amount, merchant))
                .build();
    }

    private String callGeminiApiWithImage(String base64Data, String promptText) throws Exception {
        String url = String.format("https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s", modelName, getApiKey());

        Map<String, Object> inlineData = Map.of(
                "mimeType", "image/jpeg",
                "data", base64Data
        );
        Map<String, Object> imagePart = Map.of("inlineData", inlineData);
        Map<String, Object> textPart = Map.of("text", promptText);

        Map<String, Object> content = Map.of("parts", List.of(imagePart, textPart));
        Map<String, Object> genConfig = Map.of("responseMimeType", "application/json");

        Map<String, Object> payload = Map.of(
                "contents", List.of(content),
                "generationConfig", genConfig
        );

        String jsonBody = objectMapper.writeValueAsString(payload);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(jsonBody))
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        return extractTextFromResponse(response.body());
    }

    private String callGeminiApiTextOnly(String promptText) throws Exception {
        String url = String.format("https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s", modelName, getApiKey());

        Map<String, Object> textPart = Map.of("text", promptText);
        Map<String, Object> content = Map.of("parts", List.of(textPart));
        Map<String, Object> genConfig = Map.of("responseMimeType", "application/json");

        Map<String, Object> payload = Map.of(
                "contents", List.of(content),
                "generationConfig", genConfig
        );

        String jsonBody = objectMapper.writeValueAsString(payload);

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(jsonBody))
                .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        return extractTextFromResponse(response.body());
    }

    private String extractTextFromResponse(String rawResponseBody) throws Exception {
        JsonNode root = objectMapper.readTree(rawResponseBody);
        JsonNode candidates = root.path("candidates");
        if (candidates.isArray() && candidates.size() > 0) {
            JsonNode parts = candidates.get(0).path("content").path("parts");
            if (parts.isArray() && parts.size() > 0) {
                for (JsonNode part : parts) {
                    if (part.hasNonNull("text") && !part.path("thought").asBoolean(false)) {
                        String text = part.path("text").asText("");
                        if (!text.isBlank()) {
                            return text.replaceAll("```json|```", "").trim();
                        }
                    }
                }
                String text = parts.get(0).path("text").asText("");
                return text.replaceAll("```json|```", "").trim();
            }
        }
        throw new RuntimeException("Empty response from Gemini API: " + rawResponseBody);
    }

    private String cleanBase64(String base64) {
        return base64.replaceAll("^data:image\\/(png|jpeg|jpg|webp);base64,", "");
    }

    public Category resolveCategory(String rawCategory, String fallbackText) {
        if (rawCategory != null && !rawCategory.isBlank()) {
            String trimmed = rawCategory.trim();
            for (Category c : Category.values()) {
                if (c.name().equalsIgnoreCase(trimmed)) {
                    if (c != Category.Uncategorized && c != Category.Others) {
                        return c;
                    }
                }
            }
            // Check synonyms
            String lower = trimmed.toLowerCase();
            if (lower.contains("food") || lower.contains("dining") || lower.contains("restaurant") || lower.contains("cafe") || lower.contains("grocer") || lower.contains("supermarket") || lower.contains("mart")) {
                return Category.Food;
            }
            if (lower.contains("travel") || lower.contains("transport") || lower.contains("flight") || lower.contains("cab") || lower.contains("taxi") || lower.contains("fuel") || lower.contains("petrol") || lower.contains("diesel")) {
                return Category.Travel;
            }
            if (lower.contains("shop") || lower.contains("retail") || lower.contains("cloth") || lower.contains("electronic")) {
                return Category.Shopping;
            }
            if (lower.contains("bill") || lower.contains("electric") || lower.contains("water") || lower.contains("gas") || lower.contains("broadband") || lower.contains("wifi") || lower.contains("rent")) {
                return Category.Bills;
            }
            if (lower.contains("recharge") || lower.contains("mobile") || lower.contains("dth")) {
                return Category.Recharge;
            }
            if (lower.contains("health") || lower.contains("med") || lower.contains("pharmacy") || lower.contains("hospital") || lower.contains("clinic") || lower.contains("doctor")) {
                return Category.Healthcare;
            }
            if (lower.contains("entertain") || lower.contains("movie") || lower.contains("cinema") || lower.contains("game")) {
                return Category.Entertainment;
            }
        }

        // Fallback to keyword matching on merchant/receiver text
        Category autoCat = autoCategorize(fallbackText);
        if (autoCat != Category.Uncategorized) {
            return autoCat;
        }

        return (rawCategory != null && rawCategory.equalsIgnoreCase("Others")) ? Category.Others : Category.Food;
    }

    private Category autoCategorize(String text) {
        if (text == null) return Category.Uncategorized;
        String lower = text.toLowerCase();
        for (Map.Entry<String, Category> entry : KEYWORD_CATEGORIES.entrySet()) {
            if (lower.contains(entry.getKey())) {
                return entry.getValue();
            }
        }
        return Category.Uncategorized;
    }
}

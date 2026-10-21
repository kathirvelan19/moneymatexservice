package com.moneytrace.dto;

import java.util.List;

public class InsightsResponseDto {
    private List<String> insights;

    public InsightsResponseDto() {}

    public InsightsResponseDto(List<String> insights) {
        this.insights = insights;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {
        private List<String> insights;

        public Builder insights(List<String> insights) { this.insights = insights; return this; }

        public InsightsResponseDto build() {
            return new InsightsResponseDto(insights);
        }
    }

    public List<String> getInsights() { return insights; }
    public void setInsights(List<String> insights) { this.insights = insights; }
}

package com.example.cavityapiserver.dto;

import lombok.*;

@Setter
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PredictionGetRequest {
    private String device_token;
    private Long request_id;
}

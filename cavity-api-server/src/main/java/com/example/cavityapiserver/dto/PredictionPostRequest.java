package com.example.cavityapiserver.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PredictionPostRequest {
    private String device_token;
    private Long request_id;
    private DataDTO data;
}

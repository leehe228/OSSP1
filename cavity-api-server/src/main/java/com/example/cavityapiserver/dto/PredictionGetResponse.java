package com.example.cavityapiserver.dto;

import lombok.*;

import java.util.List;

@Setter
@Getter
@NoArgsConstructor
@AllArgsConstructor
public class PredictionGetResponse {
    List<Prediction> pred;
}

package com.example.cavityapiserver.dto;

import lombok.*;

import java.util.List;

@Setter
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Prediction {
    List<List<Integer>> bbox;
    String cls;
    Double prob;
}

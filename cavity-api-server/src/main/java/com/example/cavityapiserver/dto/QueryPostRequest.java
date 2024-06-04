package com.example.cavityapiserver.dto;

import lombok.*;

@Setter
@Getter
@NoArgsConstructor
@AllArgsConstructor
@ToString
@Builder
public class QueryPostRequest {
    private String device_token;
    private Long request_id;
    private String image_url;
}

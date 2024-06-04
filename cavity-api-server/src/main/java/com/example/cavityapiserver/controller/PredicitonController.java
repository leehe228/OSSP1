package com.example.cavityapiserver.controller;

import com.example.cavityapiserver.common.response.BaseResponse;
import com.example.cavityapiserver.dto.*;
import com.example.cavityapiserver.service.ImageService;
import com.example.cavityapiserver.service.PredicitonService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequiredArgsConstructor
public class PredicitonController {

    private final PredicitonService predicitonService;

    /*
    모델 서버로부터 결과를 받는 메소드
     */
    @PostMapping("request/{requestId}/result")
    public BaseResponse<String> pushResult(
            @PathVariable Long requestId,
            @RequestBody PredictionPostRequest patchRequest
    ){
        predicitonService.addResult(patchRequest);
        return new BaseResponse<>("ok");
    }

    /*
    앱에게 결과를 전송하기 위한 메소드
     */
    @GetMapping("result")
    public BaseResponse<PredictionGetResponse> sendResult(HttpServletRequest request){
        PredictionGetRequest getRequest = PredictionGetRequest.builder()
                .device_token(request.getParameter("device_token"))
                .request_id(Long.parseLong(request.getParameter("request_id")))
                .build();
        PredictionGetResponse result = predicitonService.getResult(getRequest);
        return new BaseResponse<>(result);
    }
}

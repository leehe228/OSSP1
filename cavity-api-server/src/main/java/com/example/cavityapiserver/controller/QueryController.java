package com.example.cavityapiserver.controller;

import com.example.cavityapiserver.common.response.BaseResponse;
import com.example.cavityapiserver.dto.*;
import com.example.cavityapiserver.service.ImageService;
import com.example.cavityapiserver.service.QueryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping("request")
public class QueryController {
    private final ImageService imageService;

    private final QueryService queryService;
    /*
    앱으로부터 사진을 업로드 받는 메소드
     */
    @PostMapping(consumes = { "multipart/form-data" })
    public BaseResponse<QueryPostResponse> query(@RequestParam MultipartFile image, @RequestParam  String device_token, @RequestParam  Long request_id){
        log.info("QueryController::query");
        String image_file_name = imageService.uploadImage(image);
        QueryPostRequest postRequest = QueryPostRequest.builder()
                .request_id(request_id)
                .device_token(device_token)
                .image_url(image_file_name)
                .build();
        Long queryId = queryService.addQuery(postRequest);
        return new BaseResponse(new QueryPostResponse(queryId));
    }
}

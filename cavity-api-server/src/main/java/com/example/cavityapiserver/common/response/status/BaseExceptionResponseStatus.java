package com.example.cavityapiserver.common.response.status;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@RequiredArgsConstructor
public enum BaseExceptionResponseStatus implements ResponseStatus {

    /**
     * 1000: 요청 성공 (OK)
     */
    SUCCESS(1000, HttpStatus.OK.value(), "요청에 성공하였습니다."),

    /**
     * 2000: Request 오류 (BAD_REQUEST)
     */
    BAD_REQUEST(2000, HttpStatus.BAD_REQUEST.value(), "유효하지 않은 요청입니다."),
    URL_NOT_FOUND(2001, HttpStatus.BAD_REQUEST.value(), "유효하지 않은 URL 입니다."),
    METHOD_NOT_ALLOWED(2002, HttpStatus.METHOD_NOT_ALLOWED.value(), "해당 URL에서는 지원하지 않는 HTTP Method 입니다."),

    /**
     * 3000: Server, Database 오류 (INTERNAL_SERVER_ERROR)
     */
    SERVER_ERROR(3000, HttpStatus.INTERNAL_SERVER_ERROR.value(), "서버에서 오류가 발생하였습니다."),
    DATABASE_ERROR(3001, HttpStatus.INTERNAL_SERVER_ERROR.value(), "데이터베이스에서 오류가 발생하였습니다."),
    BAD_SQL_GRAMMAR(3002, HttpStatus.INTERNAL_SERVER_ERROR.value(), "SQL에 오류가 있습니다."),


    /**
     * 4000: QUERY 오류
     */

    IMAGE_UPLOAD_FAIL(4000, HttpStatus.INSUFFICIENT_STORAGE.value(), "서버에 이미지를 업로드하는데 실패했습니다."),
    DUPLICATE_QUERY(4001, HttpStatus.BAD_REQUEST.value(), "중복된 업로드 요청입니다."),

    /**
     * 5000: PREDICTION 오류
     */

    RESULT_NOT_FOUND(5001, HttpStatus.BAD_REQUEST.value(), "서버에 아직 결과가 도착하지 않았습니다."),
    QUERY_NOT_FOUND(5002, HttpStatus.BAD_REQUEST.value(), "존재하지 않는 요청에 대한 예측결과 입니다."),
    QUERY_FINISHED(5003, HttpStatus.BAD_REQUEST.value(), "이미 결과를 받은 요청입니다.");



    private final int code;
    private final int status;
    private final String message;

    @Override
    public int getCode() {
        return code;
    }

    @Override
    public int getStatus() {
        return status;
    }

    @Override
    public String getMessage() {
        return message;
    }

}

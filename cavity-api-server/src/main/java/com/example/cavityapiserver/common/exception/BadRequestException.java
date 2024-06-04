package com.example.cavityapiserver.common.exception;

import com.example.cavityapiserver.common.response.status.ResponseStatus;
import lombok.Getter;

@Getter
public class BadRequestException extends RuntimeException {

    private final ResponseStatus exceptionStatus;

    public BadRequestException(ResponseStatus exceptionStatus) {
        super(exceptionStatus.getMessage());
        this.exceptionStatus = exceptionStatus;
    }

}

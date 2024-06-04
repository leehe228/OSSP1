package com.example.cavityapiserver.common.exception;

import com.example.cavityapiserver.common.response.status.ResponseStatus;
import lombok.Getter;

@Getter
public class InternalServerErrorException extends RuntimeException {

    private final ResponseStatus exceptionStatus;

    public InternalServerErrorException(ResponseStatus exceptionStatus) {
        super(exceptionStatus.getMessage());
        this.exceptionStatus = exceptionStatus;
    }

}

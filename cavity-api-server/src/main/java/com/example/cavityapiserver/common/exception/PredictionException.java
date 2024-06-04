package com.example.cavityapiserver.common.exception;

import com.example.cavityapiserver.common.response.status.ResponseStatus;
import lombok.Getter;

@Getter
public class PredictionException extends RuntimeException {

    private final ResponseStatus exceptionStatus;

    public PredictionException(ResponseStatus exceptionStatus) {
        super(exceptionStatus.getMessage());
        this.exceptionStatus = exceptionStatus;
    }

    public PredictionException(ResponseStatus exceptionStatus, String message) {
        super(message);
        this.exceptionStatus = exceptionStatus;
    }

}

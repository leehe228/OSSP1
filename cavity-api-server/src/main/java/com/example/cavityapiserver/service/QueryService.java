package com.example.cavityapiserver.service;

import com.example.cavityapiserver.common.exception.PredictionException;
import com.example.cavityapiserver.dao.QueryDAO;
import com.example.cavityapiserver.dto.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import static com.example.cavityapiserver.common.response.status.BaseExceptionResponseStatus.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class QueryService {

    private final QueryDAO queryDao;
    public long addQuery(QueryPostRequest postRequest) {
        if(queryDao.hasDuplicateQuery(postRequest)){
            throw new PredictionException(DUPLICATE_QUERY);
        }
        return queryDao.addQuery(postRequest);
    }
}

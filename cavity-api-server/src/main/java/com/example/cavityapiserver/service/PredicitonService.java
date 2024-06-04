package com.example.cavityapiserver.service;

import com.example.cavityapiserver.common.exception.DatabaseException;
import com.example.cavityapiserver.common.exception.PredictionException;
import com.example.cavityapiserver.dao.PredictionDAO;
import com.example.cavityapiserver.dao.QueryDAO;
import com.example.cavityapiserver.dto.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

import static com.example.cavityapiserver.common.response.status.BaseExceptionResponseStatus.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class PredicitonService {

    private final PredictionDAO predDao;

    private final QueryDAO queryDao;

    public PredictionGetResponse getResult(PredictionGetRequest getRequest) {
        if(!predDao.hasResult(getRequest)){
            throw new PredictionException(RESULT_NOT_FOUND);
        }
        List<Prediction> prediction = predDao.getPrediction(getRequest);
        return new PredictionGetResponse(prediction);
    }

    @Transactional
    public void addResult(PredictionPostRequest patchRequest) {
        Optional<Long> optional = queryDao.findQueryId(patchRequest);

        if(optional.isEmpty()){
            throw new PredictionException(QUERY_NOT_FOUND);
        }

        if(queryDao.queryIsfinished(patchRequest)){
            throw new PredictionException(QUERY_FINISHED);
        }
        //

        List<Prediction> pred = patchRequest.getData().getPred();
        pred.forEach(prediction -> {
            int affectedRow = predDao.addResult(patchRequest, optional.get(), prediction);
            if(affectedRow == -1){
                throw new DatabaseException(DATABASE_ERROR);
            }
        });

        int affectedRow = queryDao.modifyStatus_finished(optional.get());
        if(affectedRow == -1){
            throw new DatabaseException(DATABASE_ERROR);
        }
    }
}

package com.example.cavityapiserver.dao;

import com.example.cavityapiserver.dto.Prediction;
import com.example.cavityapiserver.dto.PredictionGetRequest;
import com.example.cavityapiserver.dto.PredictionPostRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.util.*;

@Slf4j
@Repository
public class PredictionDAO {
    private final NamedParameterJdbcTemplate jdbcTemplate;

    public PredictionDAO(DataSource dataSource){
        jdbcTemplate = new NamedParameterJdbcTemplate(dataSource);
    }


    public boolean hasResult(PredictionGetRequest getRequest) {
        String sql = "SELECT EXISTS(SELECT * FROM predictions " +
                "WHERE device_token = :device_token AND request_id = :request_id)";

        Map<String, Object> param = Map.of(
                "device_token", getRequest.getDevice_token(),
                "request_id", getRequest.getRequest_id()
        );

        return Boolean.TRUE.equals(jdbcTemplate.queryForObject(sql, param, boolean.class));
    }

    public String getResultUrl(PredictionGetRequest getRequest) {
        String sql = "SELECT result_url FROM predictions " +
                "WHERE device_token = :device_token AND request_id = :request_id AND status='finished' LIMIT 1";

        Map<String, Object> param = Map.of(
                "device_token", getRequest.getDevice_token(),
                "request_id", getRequest.getRequest_id()
        );

        return jdbcTemplate.queryForObject(sql, param, String.class);
    }

    public boolean requestExists(PredictionPostRequest patchRequest) {
        String sql = "SELECT EXISTS(SELECT * FROM predictions" +
                " WHERE device_token = :device_token AND request_id = :request_id)";

        Map<String, Object> param = Map.of(
                "device_token", patchRequest.getDevice_token(),
                "request_id", patchRequest.getRequest_id()
        );

        return Boolean.TRUE.equals(jdbcTemplate.queryForObject(sql, param, boolean.class));
    }

    public int addResult(PredictionPostRequest patchRequest, Long queryId, Prediction prediction) {
        String sql = "INSERT INTO predictions(object_class, cavity_probability, x1, y1, x2, y2, query_id, device_token, request_id)" +
                "  VALUES (:object_class, :cavity_probability, :x1, :y1, :x2, :y2, :query_id, :device_token, :request_id)";

        Map<String, Object> param = Map.of(
                "object_class", prediction.getCls(),
                "cavity_probability", prediction.getProb(),
                "x1", prediction.getBbox().get(0).get(0),
                "y1", prediction.getBbox().get(0).get(1),
                "x2", prediction.getBbox().get(1).get(0),
                "y2", prediction.getBbox().get(1).get(1),
                "query_id", queryId,
                "device_token", patchRequest.getDevice_token(),
                "request_id", patchRequest.getRequest_id()
        );

        return jdbcTemplate.update(sql, param);

    }

    public Prediction getClassAndProbability(PredictionGetRequest getRequest) {
        String sql = "SELECT object_class, cavity_probability FROM predictions " +
                "WHERE device_token = :device_token AND request_id = :request_id AND status='finished' LIMIT 1";

        Map<String, Object> param = Map.of(
                "device_token", getRequest.getDevice_token(),
                "request_id", getRequest.getRequest_id()
        );

        return jdbcTemplate.queryForObject(sql, param, Prediction.class);
    }

    public List<List<Integer>> getBboxPoints(PredictionGetRequest getRequest) {
        String sql = "SELECT b.x, b.y FROM bbox_points as b, predictions as p " +
                "WHERE b.prediction_id = p.prediction_id AND p.device_token = :device_token AND p.request_id = :request_id";

        Map<String, Object> param = Map.of(
                "device_token", getRequest.getDevice_token(),
                "request_id", getRequest.getRequest_id()
        );

        return jdbcTemplate.query(sql, param, (rs, rowNum)->{
            List<Integer> point = new ArrayList<>(
                    Arrays.asList(
                            Integer.parseInt(rs.getString("b.x")),
                            Integer.parseInt(rs.getString("b.x"))
                    )
            );
            return point;
        });
    }

    public List<Prediction> getPrediction(PredictionGetRequest getRequest) {
        String sql = "select * " +
                "from predictions where device_token = :device_token AND request_id = :request_id ;";

        Map<String, Object> param = Map.of(
                "device_token", getRequest.getDevice_token(),
                "request_id", getRequest.getRequest_id()
        );

        return jdbcTemplate.query(sql, param,
                (rs, rowNum) -> {
                    Integer x1 = Integer.parseInt(rs.getString("x1"));
                    Integer y1 = Integer.parseInt(rs.getString("y1"));
                    Integer x2 = Integer.parseInt(rs.getString("x2"));
                    Integer y2 = Integer.parseInt(rs.getString("y2"));
                    List<List<Integer>> bbox = new ArrayList<>(List.of(List.of(x1, y1), List.of(x2, y2)));
                    Prediction prediction = Prediction.builder()
                            .bbox(bbox)
                            .cls(rs.getString("object_class"))
                            .prob(Double.parseDouble(rs.getString("cavity_probability")))
                            .build();
                    return prediction;
                }
        );
    }
}

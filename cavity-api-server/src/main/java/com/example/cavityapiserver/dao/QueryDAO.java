package com.example.cavityapiserver.dao;

import com.example.cavityapiserver.dto.*;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.namedparam.BeanPropertySqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.util.*;

import static java.util.List.of;

@Slf4j
@Repository
public class QueryDAO {
    private final NamedParameterJdbcTemplate jdbcTemplate;

    public QueryDAO(DataSource dataSource){
        jdbcTemplate = new NamedParameterJdbcTemplate(dataSource);
    }

    public long addQuery(QueryPostRequest postRequest) {
        log.info("QueryDAO::add");
        log.info("postRequestDTO=" + postRequest.toString());

        String sql = "insert into querys(device_token, request_id, image_url)" +
                " values(:device_token, :request_id, :image_url)";

        SqlParameterSource param = new BeanPropertySqlParameterSource(postRequest);
        KeyHolder keyHolder = new GeneratedKeyHolder();
        jdbcTemplate.update(sql, param, keyHolder);

        return Objects.requireNonNull(keyHolder.getKey()).longValue();
    }

    public boolean hasDuplicateQuery(QueryPostRequest postRequest) {
        String sql = "SELECT EXISTS(SELECT * FROM querys" +
                " WHERE device_token = :device_token AND request_id = :request_id)";

        Map<String, Object> param = Map.of(
                "device_token", postRequest.getDevice_token(),
                "request_id", postRequest.getRequest_id()
        );

        return Boolean.TRUE.equals(jdbcTemplate.queryForObject(sql, param, boolean.class));

    }

    public boolean hasResult(PredictionGetRequest getRequest) {
        String sql = "SELECT EXISTS(SELECT * FROM predictions " +
                "WHERE device_token = :device_token AND request_id = :request_id AND status='finished')";

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

    public Optional<Long> findQueryId(PredictionPostRequest patchRequest) {
        log.info("QueryDAO::findQueryId");
        log.info("patchRequestDTO=" + patchRequest.toString());
        String sql = "SELECT query_id FROM querys" +
                " WHERE device_token = :device_token AND request_id = :request_id";

        Map<String, Object> param = Map.of(
                "device_token", patchRequest.getDevice_token(),
                "request_id", patchRequest.getRequest_id()
        );

        try{
            Long queryId = jdbcTemplate.queryForObject(sql, param, Long.class);
            return Optional.of(queryId);
        }
        catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }

}

    public int addResult(PredictionPostRequest patchRequest) {
        String sql = "UPDATE predictions SET object_class = :class, cavity_probability=:prob, status='finished'" +
                " WHERE request_id = :request_id AND device_token = :device_token";

        Map<String, Object> param = Map.of(
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

    public int modifyStatus_finished(Long queryId) {
        String sql = "UPDATE querys SET status='finished'" +
                " WHERE query_id = :query_id";

        Map<String, Object> param = Map.of(
                "query_id", queryId
        );

        return jdbcTemplate.update(sql, param);
    }

    public boolean queryIsfinished(PredictionPostRequest patchRequest) {
        String sql = "SELECT EXISTS(SELECT * FROM querys " +
                "WHERE device_token = :device_token AND request_id = :request_id AND status='finished')";

        Map<String, Object> param = Map.of(
                "device_token", patchRequest.getDevice_token(),
                "request_id", patchRequest.getRequest_id()
        );

        return Boolean.TRUE.equals(jdbcTemplate.queryForObject(sql, param, boolean.class));
    }
}

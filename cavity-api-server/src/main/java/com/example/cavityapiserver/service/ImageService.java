package com.example.cavityapiserver.service;

import com.example.cavityapiserver.common.exception.PredictionException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.util.UUID;

import static com.example.cavityapiserver.common.response.status.BaseExceptionResponseStatus.IMAGE_UPLOAD_FAIL;

@Slf4j
@Service
public class ImageService {
    private final String imageDir = "/Users/apple/Documents/file/";

    public String uploadImage(MultipartFile image) {
        log.info("ImageService::uploadImage");
        final String extension = image.getContentType().split("/")[1];
        final String imageName = UUID.randomUUID() + "." + extension;

        log.info("extension=" + extension + ", imageName=" + imageName);

        try {
            final File file = new File(imageDir + imageName);
            image.transferTo(file);
        } catch (Exception e) {
            throw new PredictionException(IMAGE_UPLOAD_FAIL);
        }
        return imageName;
    }
}

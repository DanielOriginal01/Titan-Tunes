package dan.com.titan_tune.service;

import io.minio.GetObjectArgs;
import io.minio.MinioClient;
import io.minio.StatObjectArgs;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.InputStream;

@Service
@RequiredArgsConstructor
public class MinioStorageService {

    private final MinioClient minioClient;

    @Value("${minio.bucket}")
    private String bucket;

    public boolean exists(String objectName) {
        try {
            minioClient.statObject(StatObjectArgs.builder().bucket(bucket).object(objectName).build());
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public InputStream getObject(String objectName) throws Exception {
        return minioClient.getObject(GetObjectArgs.builder().bucket(bucket).object(objectName).build());
    }
}

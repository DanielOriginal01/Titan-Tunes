package dan.com.titan_tune.service;

import io.minio.StatObjectResponse;
import org.springframework.web.multipart.MultipartFile;
import java.io.InputStream;

public interface MinioService {
    String uploadFile(MultipartFile file, String bucketName);
    String getPresignedUrl(String objectName, String bucketName);
    void deleteFile(String objectName, String bucketName);
    InputStream getObject(String objectName, String bucketName);
    InputStream getObjectRange(String objectName, String bucketName, Long offset, Long length);
    StatObjectResponse statObject(String objectName, String bucketName);
}

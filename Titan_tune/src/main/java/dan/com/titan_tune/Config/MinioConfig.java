package dan.com.titan_tune.config;

import io.minio.MinioClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MinioConfig {

    @Value("${minio.endpoint:${minio.url:http://localhost:9000}}")
    private String minioUrl;

    @Value("${minio.access-key:${MINIO_ACCESS_KEY:minioadmin}}")
    private String accessKey;

    @Value("${minio.secret-key:${MINIO_SECRET_KEY:Titan@tunes2026}}")
    private String secretKey;

    @Bean
    public MinioClient minioClient() {
        return MinioClient.builder()
                .endpoint(minioUrl)
                .credentials(accessKey, secretKey)
                .build();
    }
}
package dan.com.titan_tune.service.impl;

import dan.com.titan_tune.exception.BusinessException;
import dan.com.titan_tune.service.MinioService;
import io.minio.*;
import io.minio.http.Method;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@RequiredArgsConstructor
public class MinioServiceImpl implements MinioService {

    private final MinioClient minioClient;

    @Value("${minio.public-url:http://localhost:9000}")
    private String publicUrl;

    @Override
    public String uploadFile(MultipartFile file, String bucketName) {
        if (file == null || file.isEmpty()) {
            throw new BusinessException("Fichier fourni vide");
        }

        try {
            boolean bucketExists = minioClient.bucketExists(BucketExistsArgs.builder().bucket(bucketName).build());
            if (!bucketExists) {
                minioClient.makeBucket(MakeBucketArgs.builder().bucket(bucketName).build());
                log.info("Bucket MinIO '{}' créé avec succès.", bucketName);
            }
        } catch (Exception e) {
            log.warn("Vérification/Création du bucket MinIO '{}' : {}", bucketName, e.getMessage());
        }

        var originalFilename = file.getOriginalFilename() != null ? file.getOriginalFilename() : "image.jpg";
        var fileName = UUID.randomUUID() + "_" + originalFilename;

        try (var inputStream = file.getInputStream()) {
            minioClient.putObject(
                    PutObjectArgs.builder()
                            .bucket(bucketName)
                            .object(fileName)
                            .stream(inputStream, file.getSize(), -1)
                            .contentType(file.getContentType())
                            .build()
            );
            return fileName;
        } catch (Exception e) {
            log.error("Erreur lors de l'upload du fichier MinIO : {}", e.getMessage());
            throw new BusinessException("Impossible de téléverser le fichier sur MinIO");
        }
    }

    @Override
    public String getPresignedUrl(String objectName, String bucketName) {
        if (objectName == null || objectName.isBlank()) {
            return null;
        }

        if (objectName.startsWith("http://") || objectName.startsWith("https://")) {
            return objectName;
        }

        try {
            var internalUrl = minioClient.getPresignedObjectUrl(
                    GetPresignedObjectUrlArgs.builder()
                            .method(Method.GET)
                            .bucket(bucketName)
                            .object(objectName)
                            .expiry(1, TimeUnit.HOURS)
                            .build()
            );

            return internalUrl.replaceAll("^http://[^/]+", publicUrl);
        } catch (Exception e) {
            log.error("Erreur de génération de Presigned URL : {}", e.getMessage());
            throw new BusinessException("Erreur de génération du lien d'accès");
        }
    }

    @Override
    public void deleteFile(String objectName, String bucketName) {
        if (objectName == null || objectName.isBlank() || objectName.startsWith("http://") || objectName.startsWith("https://")) {
            return;
        }

        try {
            minioClient.removeObject(
                    RemoveObjectArgs.builder()
                            .bucket(bucketName)
                            .object(objectName)
                            .build()
            );
            log.info("Fichier MinIO supprimé : bucket={}, object={}", bucketName, objectName);
        } catch (Exception e) {
            log.warn("Impossible de supprimer le fichier MinIO '{}' du bucket '{}' : {}", objectName, bucketName, e.getMessage());
        }
    }

    @Override
    public InputStream getObject(String objectName, String bucketName) {
        if (objectName == null || objectName.isBlank()) return null;
        try {
            return minioClient.getObject(
                    GetObjectArgs.builder()
                            .bucket(bucketName)
                            .object(objectName)
                            .build()
            );
        } catch (Exception e) {
            log.error("Erreur récupération objet MinIO bucket={} object={}: {}", bucketName, objectName, e.getMessage());
            return null;
        }
    }

    @Override
    public InputStream getObjectRange(String objectName, String bucketName, Long offset, Long length) {
        if (objectName == null || objectName.isBlank()) return null;
        try {
            GetObjectArgs.Builder builder = GetObjectArgs.builder()
                    .bucket(bucketName)
                    .object(objectName);
            if (offset != null && offset >= 0) {
                if (length != null && length > 0) {
                    builder.offset(offset).length(length);
                } else {
                    builder.offset(offset);
                }
            }
            return minioClient.getObject(builder.build());
        } catch (Exception e) {
            log.error("Erreur récupération range MinIO bucket={} object={}: {}", bucketName, objectName, e.getMessage());
            return null;
        }
    }

    @Override
    public StatObjectResponse statObject(String objectName, String bucketName) {
        if (objectName == null || objectName.isBlank()) return null;
        try {
            return minioClient.statObject(
                    StatObjectArgs.builder()
                            .bucket(bucketName)
                            .object(objectName)
                            .build()
            );
        } catch (Exception e) {
            log.warn("Objet MinIO non trouvé bucket={} object={}: {}", bucketName, objectName, e.getMessage());
            return null;
        }
    }
}

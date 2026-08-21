package dan.com.titan_tune.controller;

import dan.com.titan_tune.service.MinioService;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.InputStreamResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.InputStream;

@RestController
@RequestMapping("/api/v1/media")
@RequiredArgsConstructor
public class MediaController {

    private final MinioService minioService;

    @GetMapping("/{bucket}/{fileName:.+}")
    public ResponseEntity<Resource> getMediaFile(
            @PathVariable String bucket,
            @PathVariable String fileName) {
        try {
            InputStream is = minioService.getObject(fileName, bucket);
            String contentType = determineContentType(fileName);

            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(contentType))
                    .header(HttpHeaders.CACHE_CONTROL, "public, max-age=86400")
                    .body(new InputStreamResource(is));
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    private String determineContentType(String filename) {
        if (filename == null) return MediaType.APPLICATION_OCTET_STREAM_VALUE;
        String lower = filename.toLowerCase();
        if (lower.endsWith(".mp3")) return "audio/mpeg";
        if (lower.endsWith(".wav")) return "audio/wav";
        if (lower.endsWith(".ogg")) return "audio/ogg";
        if (lower.endsWith(".m4a") || lower.endsWith(".mp4")) return "audio/mp4";
        if (lower.endsWith(".png")) return MediaType.IMAGE_PNG_VALUE;
        if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) return MediaType.IMAGE_JPEG_VALUE;
        if (lower.endsWith(".webp")) return "image/webp";
        if (lower.endsWith(".gif")) return MediaType.IMAGE_GIF_VALUE;
        return MediaType.APPLICATION_OCTET_STREAM_VALUE;
    }
}

package dan.com.titan_tune.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DownloadResponseDTO {
    private Long trackId;
    private String filename;
    private String contentType;
    private String message;
}

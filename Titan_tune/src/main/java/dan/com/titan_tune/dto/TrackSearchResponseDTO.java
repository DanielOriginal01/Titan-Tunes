package dan.com.titan_tune.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TrackSearchResponseDTO {
    private Long id;
    private String title;
    private String artist;
    private String album;
    private String genre;
    private Integer duration;
}

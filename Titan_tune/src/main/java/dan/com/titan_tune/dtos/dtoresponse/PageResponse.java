package dan.com.titan_tune.dtos.dtoresponse;

import org.springframework.data.domain.Page;

import java.util.List;
import java.util.function.Function;

/**
 * Enveloppe standardisée pour toutes les réponses paginées de l'API.
 */
public record PageResponse<T>(
    List<T> content,
    int page,
    int size,
    long totalElements,
    int totalPages,
    boolean first,
    boolean last,
    boolean empty
) {
    /**
     * Crée un PageResponse à partir d'une Page Spring Data sans transformation d'élément.
     */
    public static <T> PageResponse<T> from(Page<T> page) {
        return new PageResponse<>(
                page.getContent(),
                page.getNumber(),
                page.getSize(),
                page.getTotalElements(),
                page.getTotalPages(),
                page.isFirst(),
                page.isLast(),
                page.isEmpty()
        );
    }

    /**
     * Crée un PageResponse en appliquant une fonction de mapping (ex: Entity -> DTO).
     */
    public static <T, R> PageResponse<R> from(Page<T> page, Function<T, R> mapper) {
        List<R> mappedList = page.getContent().stream().map(mapper).toList();
        return new PageResponse<>(
                mappedList,
                page.getNumber(),
                page.getSize(),
                page.getTotalElements(),
                page.getTotalPages(),
                page.isFirst(),
                page.isLast(),
                page.isEmpty()
        );
    }
}

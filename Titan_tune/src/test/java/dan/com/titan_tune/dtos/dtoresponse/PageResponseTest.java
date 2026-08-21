package dan.com.titan_tune.dtos.dtoresponse;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class PageResponseTest {

    @Test
    @DisplayName("PageResponse.from(Page) doit construire correctement les métadonnées de pagination")
    void testFromPage() {
        List<String> items = List.of("item1", "item2", "item3");
        Page<String> page = new PageImpl<>(items, PageRequest.of(0, 10), 25);

        PageResponse<String> response = PageResponse.from(page);

        assertThat(response.content()).containsExactly("item1", "item2", "item3");
        assertThat(response.page()).isEqualTo(0);
        assertThat(response.size()).isEqualTo(10);
        assertThat(response.totalElements()).isEqualTo(25);
        assertThat(response.totalPages()).isEqualTo(3);
        assertThat(response.first()).isTrue();
        assertThat(response.last()).isFalse();
        assertThat(response.empty()).isFalse();
    }

    @Test
    @DisplayName("PageResponse.from(Page, mapper) doit mapper les entités en DTOs")
    void testFromPageWithMapper() {
        List<Integer> numbers = List.of(1, 2, 3);
        Page<Integer> page = new PageImpl<>(numbers, PageRequest.of(1, 3), 6);

        PageResponse<String> response = PageResponse.from(page, n -> "NUM_" + n);

        assertThat(response.content()).containsExactly("NUM_1", "NUM_2", "NUM_3");
        assertThat(response.page()).isEqualTo(1);
        assertThat(response.size()).isEqualTo(3);
        assertThat(response.totalElements()).isEqualTo(6);
        assertThat(response.totalPages()).isEqualTo(2);
        assertThat(response.first()).isFalse();
        assertThat(response.last()).isTrue();
    }
}

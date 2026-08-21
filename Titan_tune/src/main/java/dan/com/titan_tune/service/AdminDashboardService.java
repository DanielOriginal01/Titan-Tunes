package dan.com.titan_tune.service;

import java.util.Map;

public interface AdminDashboardService {
    Map<String, Object> getMetricsGlobales();
    Map<String, Object> getFinancesAndRoyalty();
}

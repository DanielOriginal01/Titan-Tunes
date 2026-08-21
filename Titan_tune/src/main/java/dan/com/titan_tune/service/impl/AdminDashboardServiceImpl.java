package dan.com.titan_tune.service.impl;

import dan.com.titan_tune.enums.Role;
import dan.com.titan_tune.repository.PaiementRepository;
import dan.com.titan_tune.repository.UtilisateurRepository;
import dan.com.titan_tune.service.AdminDashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;

@Service
@RequiredArgsConstructor
public class AdminDashboardServiceImpl implements AdminDashboardService {

    private final UtilisateurRepository utilisateurRepository;
    private final PaiementRepository paiementRepository;

    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getMetricsGlobales() {
        long totalUtilisateurs = utilisateurRepository.count();
        long totalArtistes     = utilisateurRepository.countByRole(Role.ROLE_ARTISTE);
        long totalAuditeurs    = utilisateurRepository.countByRole(Role.ROLE_AUDITEUR);
        long totalAdmins       = utilisateurRepository.countByRole(Role.ROLE_ADMIN);

        return Map.of(
                "totalUtilisateurs", totalUtilisateurs,
                "totalArtistes",     totalArtistes,
                "totalAuditeurs",    totalAuditeurs,
                "totalAdmins",       totalAdmins
        );
    }

    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> getFinancesAndRoyalty() {
        var paiements = paiementRepository.findAll();

        double totalRevenus = paiements.stream()
                .mapToDouble(p -> p.getMontant() != null ? p.getMontant() : 0.0)
                .sum();

        long totalTransactions = paiements.size();

        // Royalties artistes = 70 % des revenus (modèle standard streaming)
        double royaltiesArtistes = totalRevenus * 0.70;
        double revenusNets       = totalRevenus * 0.30;

        return Map.of(
                "totalRevenus",       totalRevenus,
                "totalTransactions",  totalTransactions,
                "royaltiesArtistes",  royaltiesArtistes,
                "revenusNets",        revenusNets
        );
    }
}

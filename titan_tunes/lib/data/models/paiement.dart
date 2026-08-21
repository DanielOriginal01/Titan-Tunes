enum PaiementMethod { flooz, tMoney, creditCard, mobileMoney }

class Paiement {
  final String id;
  final String userId;
  final double amount;
  final PaiementMethod method;
  final DateTime date;
  final bool success;

  Paiement({
    required this.id,
    required this.userId,
    required this.amount,
    required this.method,
    required this.date,
    required this.success,
  });

  factory Paiement.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'];
    final parsedDate = rawDate is String
        ? DateTime.tryParse(rawDate) ?? DateTime.now()
        : DateTime.now();

    final methodValue = (json['method'] as String?)?.toLowerCase();
    final method = PaiementMethod.values.firstWhere(
      (value) => value.name == methodValue,
      orElse: () => PaiementMethod.mobileMoney,
    );

    return Paiement(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      method: method,
      date: parsedDate,
      success: json['success'] as bool? ?? false,
    );
  }
}

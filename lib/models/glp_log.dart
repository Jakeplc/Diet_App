class GlpLog {
  final String id;
  final double doseAmount;
  final String doseUnit;
  final DateTime date;
  final String? notes;

  GlpLog({
    required this.id,
    required this.doseAmount,
    required this.doseUnit,
    required this.date,
    this.notes,
  });
}

import '../common/widgets/custom_statuschip.dart';

class TransactionItem {
  final String reference;
  final String dateTime;
  final String name;
  final String amount;
  final String status;
  final StatusType statusType;

  const TransactionItem({
    required this.reference,
    required this.dateTime,
    required this.name,
    required this.amount,
    required this.status,
    required this.statusType,
  });
}
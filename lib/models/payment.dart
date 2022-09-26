class Payment{
  final String username;
  final String entryStatus;
  final String paymentStatus;
  final String ticket;
  final String cancelDateTime;
  final String phoneNumber;

  Payment(this.username, this.entryStatus, this.paymentStatus, this.ticket, this.cancelDateTime, this.phoneNumber);
}

class AllPayment{
  final String username;
  final String entryStatus;
  final String paymentStatus;
  final String ticket;
  final String cancelDateTime;
  final String phoneNumber;
  final String className;
  final String classDate;

  AllPayment(this.username, this.entryStatus, this.paymentStatus, this.ticket, this.cancelDateTime, this.phoneNumber, this.className, this.classDate);
}
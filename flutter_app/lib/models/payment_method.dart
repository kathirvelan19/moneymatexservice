enum PaymentMethod {
  Cash,
  UPI,
  Card;

  String toShortString() {
    return name;
  }

  static PaymentMethod fromString(String val) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => PaymentMethod.Cash,
    );
  }
}

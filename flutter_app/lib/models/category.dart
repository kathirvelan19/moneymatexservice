enum Category {
  Food,
  Travel,
  Shopping,
  Bills,
  Recharge,
  Entertainment,
  Healthcare,
  Others,
  Uncategorized;

  String toShortString() {
    return name;
  }

  static Category fromString(String val) {
    final lower = val.trim().toLowerCase();
    for (final e in Category.values) {
      if (e.name.toLowerCase() == lower) return e;
    }
    if (lower.contains('food') || lower.contains('dine') || lower.contains('restaurant') || lower.contains('cafe') || lower.contains('grocer') || lower.contains('supermarket')) {
      return Category.Food;
    }
    if (lower.contains('travel') || lower.contains('transport') || lower.contains('fuel') || lower.contains('petrol') || lower.contains('cab') || lower.contains('taxi') || lower.contains('flight')) {
      return Category.Travel;
    }
    if (lower.contains('shop') || lower.contains('retail') || lower.contains('cloth') || lower.contains('electronic')) {
      return Category.Shopping;
    }
    if (lower.contains('bill') || lower.contains('electric') || lower.contains('water') || lower.contains('gas') || lower.contains('broadband')) {
      return Category.Bills;
    }
    if (lower.contains('recharge') || lower.contains('mobile') || lower.contains('dth')) {
      return Category.Recharge;
    }
    if (lower.contains('health') || lower.contains('med') || lower.contains('pharmacy') || lower.contains('doctor') || lower.contains('hospital')) {
      return Category.Healthcare;
    }
    if (lower.contains('entertain') || lower.contains('movie') || lower.contains('cinema') || lower.contains('game')) {
      return Category.Entertainment;
    }
    return Category.Food;
  }
}

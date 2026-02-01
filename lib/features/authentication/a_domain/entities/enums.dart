enum Sex {
  male,
  female;

  // Helper để convert string từ DB ('male') về Enum
  static Sex fromString(String value) {
    return Sex.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => Sex.male,
    );
  }

  // Helper convert sang chuỗi để lưu xuống DB/Json
  String toJson() => name;
}

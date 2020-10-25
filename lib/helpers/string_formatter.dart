class StringFormatter {
  String getNameAgeLabel(String name, int age) {
    if (name == null && age == null) return null;
    if (name != null && age == null) return name;
    if (name == null && age != null) return age.toString();
    return '$name, ${age.toString()}';
  }
}

enum Gender {
  male("Male"),
  female("Female");

  const Gender(this.gender);
  final String gender;
}

enum DiagnosisType {
  xray("X-Ray"),
  mri("MRI");

  const DiagnosisType(this.diagnosis);
  final String diagnosis;
}

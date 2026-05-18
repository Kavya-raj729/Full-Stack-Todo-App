class PortfolioModel {
  final String aboutMe;
  final String developerType;
  final String experienceLevel;
  final String atsScore;

  final List<dynamic> strengths;
  final List<dynamic> weaknesses;
  final List<dynamic> careerRoles;

  PortfolioModel({
    required this.aboutMe,
    required this.developerType,
    required this.experienceLevel,
    required this.atsScore,
    required this.strengths,
    required this.weaknesses,
    required this.careerRoles,
  });

  factory PortfolioModel.fromJson(Map<String, dynamic> json) {
    return PortfolioModel(
      aboutMe: json['about_me'] ?? '',
      developerType: json['developer_type'] ?? '',
      experienceLevel: json['experience_level'] ?? '',
      atsScore: json['ats_score'].toString(),

      strengths: json['strengths'] ?? [],
      weaknesses: json['weaknesses'] ?? [],
      careerRoles: json['career_roles'] ?? [],
    );
  }
}
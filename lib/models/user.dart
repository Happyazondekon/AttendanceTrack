class User {
  final int id;
  final String matricule;
  final String nom;
  final String prenoms;
  final String email;
  final DateTime dateNaissance;
  final String lieuNaissance;
  final String sexe;
  final String nationalite;
  final String telephone;
  final String anneeEtude;
  final String dateValidation;
  final bool? isResponsable;
  final int classeId;

  User({
    required this.id,
    required this.matricule,
    required this.nom,
    required this.prenoms,
    required this.email,
    required this.dateNaissance,
    required this.lieuNaissance,
    required this.sexe,
    required this.nationalite,
    required this.telephone,
    required this.anneeEtude,
    required this.dateValidation,
    this.isResponsable,
    required this.classeId,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    matricule: json['matricule'],
    nom: json['nom'],
    prenoms: json['prenoms'],
    email: json['email'],
    dateNaissance: DateTime.parse(json['date_naissance']),
    lieuNaissance: json['lieu_naissance'],
    sexe: json['sexe'],
    nationalite: json['nationalite'],
    telephone: json['telephone'],
    anneeEtude: json['annee_etude'],
    dateValidation: json['date_validation'],
    isResponsable: json['is_responsable'],
    classeId: json['classe_id'],
  );
}

class SetModel {
  int? id; // ID for database entry
  String exercise;
  double weight;
  int repetitions;

  SetModel({this.id, required this.exercise, required this.weight, required this.repetitions});

  // Convert a SetModel into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise': exercise,
      'weight': weight,
      'repetitions': repetitions,
    };
  }

  // Convert a Map into a SetModel
  factory SetModel.fromMap(Map<String, dynamic> map) {
    return SetModel(
      id: map['id'],
      exercise: map['exercise'],
      weight: map['weight'],
      repetitions: map['repetitions'],
    );
  }
}

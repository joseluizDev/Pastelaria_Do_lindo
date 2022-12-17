class BeepModel {
  final bool isbeep;

  BeepModel({required this.isbeep});

  factory BeepModel.fromJson(Map<String, dynamic> json) {
    return BeepModel(isbeep: json['beep']);
  }

  Map<String, dynamic> toJson() {
    return {
      'beep': isbeep,
    };
  }
}

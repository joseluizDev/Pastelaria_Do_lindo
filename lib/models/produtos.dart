<<<<<<< Updated upstream
=======
import 'package:map_fields/map_fields.dart';

>>>>>>> Stashed changes
class Produto {
  final String nome;
  late final double unitario;
  final double estoque;
  final String? tipo;
<<<<<<< Updated upstream
=======
  List<Produto>? adicionais;
>>>>>>> Stashed changes
  Produto(
      {required this.nome,
      required this.unitario,
      required this.estoque,
<<<<<<< Updated upstream
      this.tipo});

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
        nome: json['nome'] as String,
        unitario: double.parse(json['unitario'].toString()),
        estoque: double.parse(json['estoque'].toString()),
        tipo: json['tipo'] as String?);
=======
      this.tipo,
      this.adicionais});

  factory Produto.fromJson(Map<String, dynamic> json) {
    final map = MapFields.load(json);
    return Produto(
      nome: map.getString('nome', ''),
      unitario: map.getDouble('unitario', 0),
      estoque: map.getDouble('estoque', 0),
      tipo: map.getStringNullable('tipo'),
      adicionais: map.getListNullable('adicionais'),
    );
>>>>>>> Stashed changes
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'unitario': unitario,
      'estoque': estoque,
<<<<<<< Updated upstream
      'tipo': tipo
=======
      'tipo': tipo,
      'adicionais': adicionais?.map((e) => e.toJson()).toList(),
>>>>>>> Stashed changes
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Produto && other.nome == nome && other.unitario == unitario;
  }

  @override
  int get hashCode => nome.hashCode ^ unitario.hashCode;
}

import 'package:map_fields/map_fields.dart';

class Produto {
  final String nome;
  late final double unitario;
  final double estoque;
  final String? tipo;
  List<Produto>? adicionais;
  Produto(
      {required this.nome,
      required this.unitario,
      required this.estoque,
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
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'unitario': unitario,
      'estoque': estoque,
      'tipo': tipo,
      'adicionais': adicionais?.map((e) => e.toJson()).toList(),
    };
  }
}

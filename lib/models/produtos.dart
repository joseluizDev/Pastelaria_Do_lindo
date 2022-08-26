class Produto {
  final String nome;
  late final double unitario;
  final double estoque;
  final String? tipo;
  Produto(
      {required this.nome,
      required this.unitario,
      required this.estoque,
      this.tipo});

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
        nome: json['nome'] as String,
        unitario: double.parse(json['unitario'].toString()),
        estoque: double.parse(json['estoque'].toString()),
        tipo: json['tipo'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'unitario': unitario,
      'estoque': estoque,
      'tipo': tipo
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

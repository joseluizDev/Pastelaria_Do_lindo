import 'package:map_fields/map_fields.dart';
import 'package:pastelaria/models/enum_categoria.dart';
import 'package:pastelaria/models/enum_pagamento.dart';

class Pedidos {
  final String cliente;
  final DateTime data;
  final String mesa;
  final List<ProdutoPedido> produtos;
  final int finalizado;
  final List<ProdutoPedido> produtosAdicionais;
  final String? funcionario;
  final TipoPedido? tipopedido;
  final TipoPagamento? tipopagamento;
  final String? numeroPedido;

  Pedidos({
    required this.cliente,
    required this.data,
    required this.mesa,
    required this.produtos,
    required this.finalizado,
    required this.produtosAdicionais,
    this.numeroPedido,
    this.tipopagamento,
    this.tipopedido,
    this.funcionario,
  });

  double get total =>
      produtos.fold(0, (total, produto) => total + produto.total);
  double get totalAdicionais =>
      produtosAdicionais.fold(0, (total, produto) => total + produto.total);

  factory Pedidos.fromJson(Map<String, dynamic> json) {
    final data = DateTime.parse(json['data'] as String);

    final mapFild = MapFields.load(json);

    return Pedidos(
      cliente: mapFild.getString('cliente'),
      data: data.isUtc ? data.toLocal() : data,
      mesa: mapFild.getString('mesa'),
      produtosAdicionais: (json['produtosAdicionais'] as List<dynamic>)
          .map((produto) =>
              ProdutoPedido.fromJson(produto as Map<String, dynamic>))
          .toList(),
      produtos: (json['produtos'] as List<dynamic>)
          .map((produto) =>
              ProdutoPedido.fromJson(produto as Map<String, dynamic>))
          .toList(),
      finalizado: json['finalizado'] as int,
      funcionario: mapFild.getStringNullable('funcionario'),
      tipopedido: mapFild.getStringNullable('tipopedido') == null
          ? null
          : TipoPedido.values.firstWhere(
              (e) => e.toString() == mapFild.getStringNullable('tipopedido'),
            ),
      tipopagamento: mapFild.getStringNullable('tipopagamento') == null
          ? null
          : TipoPagamento.values.firstWhere(
              (e) => e.toString() == mapFild.getStringNullable('tipopagamento'),
            ),
      numeroPedido: mapFild.getStringNullable('numeroPedido'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cliente': cliente,
      'data': data.toUtc().toIso8601String(),
      'mesa': mesa,
      'produtos': produtos.map((p) => p.toJson()).toList(),
      'finalizado': finalizado,
      'produtosAdicionais': produtosAdicionais.map((p) => p.toJson()).toList(),
      'funcionario': funcionario,
      'tipopedido': tipopedido.toString(),
      'tipopagamento': tipopagamento.toString(),
      'numeroPedido': numeroPedido
    };
  }

  Map<String, dynamic> toJsonadd() {
    return {
      'finalizado': finalizado,
      'produtos': produtos.map((p) => p.toJson()).toList(),
      'produtosAdicionais': produtosAdicionais.map((p) => p.toJson()).toList(),
      'funcionario': funcionario,
    };
  }
}

class ProdutoPedido {
  final String nome;
  final double qtde;
  final double unitario;
  final String? tipo;

  ProdutoPedido({
    required this.nome,
    required this.qtde,
    required this.unitario,
    this.tipo,
  });

  double get total => qtde * unitario;

  factory ProdutoPedido.fromJson(Map<String, dynamic> json) {
    final MapFields mapFild = MapFields.load(json);
    return ProdutoPedido(
      nome: json['nome'] as String,
      qtde: double.parse(json['qtde'].toString()),
      unitario: double.parse(json['unitario'].toString()),
      tipo: mapFild.getStringNullable('tipo'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'qtde': qtde,
      'unitario': unitario,
      'tipo': tipo,
    };
  }
}

import 'package:map_fields/map_fields.dart';
import 'package:pastelaria/models/enum_categoria.dart';
import 'package:pastelaria/models/enum_pagamento.dart';
import 'package:pastelaria/models/produtos.dart';

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
  final String localDaEntrga;
  final int numeroPedido;

  Pedidos({
    required this.cliente,
    required this.data,
    required this.mesa,
    required this.produtos,
    required this.finalizado,
    required this.produtosAdicionais,
    required this.numeroPedido,
    required this.localDaEntrga,
    this.tipopagamento,
    this.tipopedido,
    this.funcionario,
  });

  double get total => total2 + totalAdicionais + pedidosadicionais;

  double get total2 =>
      produtos.fold(0, (total, produto) => total + produto.total);

  double get pedidosadicionais {
    double total = 0;
    produtos.map((e) => e.adicionais).forEach((element) {
      element?.forEach((element) {
        total += element.unitario;
      });
    });
    return total;
  }

  double get totalAdicionais =>
      produtosAdicionais.fold(0, (total, produto) => total + produto.total);

  factory Pedidos.fromJson(Map<String, dynamic> json) {
    final mapFild = MapFields.load(json);
    final data = mapFild.getDateTime('data', DateTime.now());

    return Pedidos(
      cliente: mapFild.getString('cliente', ""),
      data: data.isUtc ? data.toLocal() : data,
      mesa: mapFild.getString('mesa', ""),
      localDaEntrga: mapFild.getString('localDaEntrga', ""),
      produtosAdicionais: mapFild
          .getList('produtosAdicionais', <dynamic>[])
          .map((produto) =>
              ProdutoPedido.fromJson(produto as Map<String, dynamic>))
          .toList(),
      produtos: mapFild
          .getList('produtos', <dynamic>[])
          .map((produto) =>
              ProdutoPedido.fromJson(produto as Map<String, dynamic>))
          .toList(),
      finalizado: mapFild.getInt('finalizado', 0),
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
      numeroPedido: mapFild.getInt('numeroPedido', 0),
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
      'localDaEntrga': localDaEntrga,
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
  final List<Produto>? adicionais;

  ProdutoPedido({
    required this.nome,
    required this.qtde,
    required this.unitario,
    this.tipo,
    required this.adicionais,
  });

  double get total => qtde * unitario;

  factory ProdutoPedido.fromJson(Map<String, dynamic> json) {
    final MapFields mapFild = MapFields.load(json);
    return ProdutoPedido(
      nome: json['nome'] as String,
      qtde: double.parse(json['qtde'].toString()),
      unitario: double.parse(json['unitario'].toString()),
      tipo: mapFild.getStringNullable('tipo'),
      adicionais: mapFild
          .getList('adicionais', <dynamic>[])
          .map((produto) => Produto.fromJson(produto as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'qtde': qtde,
      'unitario': unitario,
      'tipo': tipo,
      'adicionais': adicionais?.map((p) => p.toJson()).toList() ?? [],
    };
  }
}

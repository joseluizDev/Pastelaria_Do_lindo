import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:pastelaria/components/text_field_custom.dart';
import 'package:pastelaria/utils/extensions.dart';

import '../../global/login_data.dart';
import '../../models/enum_categoria.dart';
import '../../models/enum_pagamento.dart';
import '../../models/pedidos.dart';
import '../../models/produtos.dart';
import '../../utils/shared_preferences.dart';
import 'components/adicionar_produto_dialog.dart';
import 'components/confirmacao_pedido.dart';

// ignore: must_be_immutable
class AdicionarPedidoPage extends StatefulWidget {
  Pedidos? pedido;
  final pedidoData;
  final bool? addnovo;
  final bool? unir;
  AdicionarPedidoPage(
      {Key? key, this.pedido, this.pedidoData, this.addnovo, this.unir})
      : super(key: key);

  @override
  State<AdicionarPedidoPage> createState() => _AdicionarPedidoPageState();
}

class _AdicionarPedidoPageState extends State<AdicionarPedidoPage> {
  List<Produto> produtosPedido = [];
  List<Produto> produtosPedidoComprovante = [];
  TipoPedido tipoPedido = TipoPedido.naoDefinido;
  TipoPagamento tipoPagamento = TipoPagamento.naoDefinido;
  List<Produto> unirProdutos = [];
  final mesaController = TextEditingController();
  final clienteController = TextEditingController();
  final localDaEntrega = TextEditingController();
  bool isloading = false;
  @override
  void initState() {
    try {} catch (e) {
      print(e);
    }
    _init();
    if (widget.unir == true) {
      unir();
    }
    super.initState();
  }

  void unir() {
    for (var produto in widget.pedido!.produtos) {
      for (var i = 1; i <= (produto.qtde.toInt()); i++) {
        unirProdutos.add(Produto(
          nome: produto.nome,
          unitario: produto.unitario,
          estoque: produto.qtde,
        ));
      }
    }
    for (var produto in widget.pedido!.produtosAdicionais) {
      for (var i = 1; i <= (produto.qtde.toInt()); i++) {
        unirProdutos.add(Produto(
          nome: produto.nome,
          unitario: produto.unitario,
          estoque: produto.qtde,
        ));
      }
    }
  }

  void _init() {
    if (widget.addnovo == true) {
      mesaController.text = widget.pedido!.mesa;
      clienteController.text = widget.pedido!.cliente;
      localDaEntrega.text = widget.pedido!.localDaEntrga;
      tipoPedido = widget.pedido!.tipopedido!;
    } else if (widget.pedido != null) {
      mesaController.text = widget.pedido!.mesa;
      clienteController.text = widget.pedido!.cliente;
      localDaEntrega.text = widget.pedido!.localDaEntrga;
      tipoPedido = widget.pedido!.tipopedido!;
      for (var produto in widget.pedido!.produtos) {
        for (var i = 1; i <= (produto.qtde.toInt()); i++) {
          produtosPedido.add(Produto(
            nome: produto.nome,
            unitario: produto.unitario,
            estoque: produto.qtde,
          ));
        }
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Pedido'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            TextFieldCustom(
              label: 'Mesa',
              keyboardType: TextInputType.number,
              controller: mesaController,
            ),
            TextFieldCustom(
              label: 'Cliente',
              controller: clienteController,
            ),
            tipoPedido.index == 1
                ? TextFieldCustom(
                    label: 'Local da Entrega',
                    controller: localDaEntrega,
                  )
                : const SizedBox(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 65, 90),
                        border: Border.all(
                          color: Colors.black,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        shape: BoxShape.rectangle,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<TipoPedido>(
                          value: tipoPedido,
                          icon: const Icon(
                            Icons.arrow_downward,
                            color: Colors.white,
                          ),
                          iconSize: 24,
                          elevation: 16,
                          alignment: Alignment.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          underline: Container(
                            height: 2,
                            color: Colors.red,
                          ),
                          onChanged: (TipoPedido? newValue) {
                            setState(() {
                              tipoPedido = newValue!;
                            });
                          },
                          items: TipoPedido.values
                              .map<DropdownMenuItem<TipoPedido>>(
                            (TipoPedido value) {
                              return DropdownMenuItem<TipoPedido>(
                                value: value,
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    value.name == 'naoDefinido'
                                        ? 'Pedido'
                                        : value.name == 'delivery'
                                            ? 'Delivery'
                                            : 'Local',
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 65, 90),
                        border: Border.all(
                          color: Colors.black,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        shape: BoxShape.rectangle,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<TipoPagamento>(
                          value: tipoPagamento,
                          icon: const Icon(
                            Icons.attach_money,
                            color: Colors.white,
                          ),
                          iconSize: 24,
                          elevation: 16,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          underline: Container(
                            height: 2,
                            color: Colors.red,
                          ),
                          onChanged: (TipoPagamento? newValue) {
                            setState(() {
                              tipoPagamento = newValue!;
                            });
                          },
                          items: TipoPagamento.values
                              .map<DropdownMenuItem<TipoPagamento>>(
                            (TipoPagamento value) {
                              return DropdownMenuItem<TipoPagamento>(
                                value: value,
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    value.name == 'naoDefinido'
                                        ? 'Tipo de Pagamento'
                                        : value.name == 'dinherio'
                                            ? 'Dinheiro'
                                            : value.name == 'cartao'
                                                ? 'Cartão'
                                                : 'Pix',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 18),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream:
                  FirebaseFirestore.instance.collection('produtos').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Erro ao carregar produtos'),
                  );
                }
                if (!snapshot.hasData) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final data = snapshot.data?.docs ?? [];
                List<Produto> produtos = data.map((e) {
                  final produto = Produto.fromJson(e.data());
                  return produto;
                }).toList();
                return GroupedListView<dynamic, String>(
                  shrinkWrap: true,
                  elements: produtos,
                  groupBy: (element) => element.tipo,
                  groupComparator: (value1, value2) => value2.compareTo(value1),
                  itemComparator: (item1, item2) =>
                      item1.toString().compareTo(item2.toString()),
                  order: GroupedListOrder.DESC,
                  useStickyGroupSeparators: true,
                  groupSeparatorBuilder: (String value) {
                    if (value == 'add') {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        value.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                  itemBuilder: (c, element) {
                    final produto = element as Produto;

                    final quantidade = produtosPedido
                        .where((p) =>
                            p.nome == produto.nome && p.tipo == produto.tipo)
                        .length;
                    if (produto.tipo == 'add') {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        child: ListTile(
                          title: Text(produto.nome),
                          subtitle: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(produto.unitario.formatted),
                              Builder(builder: (context) {
                                final restantes = produto.estoque - quantidade;
                                return Text(
                                  'Restante: ${restantes.toInt()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              }),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: FloatingActionButton(
                                  child: const Icon(Icons.remove),
                                  onPressed: () {
                                    final i = produtosPedido.indexOf(produto);

                                    final j = produtosPedidoComprovante
                                        .indexOf(produto);
                                    setState(() {
                                      if (i != -1) {
                                        produtosPedido.removeAt(i);
                                        produtosPedidoComprovante.removeAt(j);
                                      }
                                    });
                                  },
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  quantidade.toString(),
                                  style: const TextStyle(
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              AspectRatio(
                                aspectRatio: 1,
                                child: FloatingActionButton(
                                  onPressed: quantidade < produto.estoque
                                      ? () async {
                                          print(produto.tipo.toString());
                                          if (produto.tipo
                                              .toString()
                                              .toUpperCase()
                                              .contains("GUARA")) {
                                            List<Produto>? produtodd;

                                            produtodd =
                                                await showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                actionsAlignment:
                                                    MainAxisAlignment.center,
                                                title: Text(
                                                  produto.nome.toString(),
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                content: Container(
                                                  height: MediaQuery.of(context)
                                                      .size
                                                      .height,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: AdicionarProdutoDialog(
                                                    produtosAdicionais:
                                                        produtos,
                                                  ),
                                                ),
                                              ),
                                            );
                                            final produtofinal = Produto(
                                              nome: produto.nome,
                                              estoque: produto.estoque,
                                              tipo: produto.tipo,
                                              unitario: produto.unitario,
                                              adicionais: produtodd,
                                            );
                                            print(produtofinal.adicionais);
                                            setState(
                                              () {
                                                produtosPedido
                                                    .add(produtofinal);
                                                produtosPedidoComprovante
                                                    .add(produtofinal);
                                              },
                                            );
                                          } else {
                                            setState(() {
                                              produtosPedido.add(produto);
                                              produtosPedidoComprovante
                                                  .add(produto);
                                            });
                                          }
                                        }
                                      : null,
                                  child: const Icon(Icons.add),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Produtos: ${produtosPedido.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Builder(builder: (context) {
                      double valorProdutos = produtosPedido.fold<double>(
                              0, (total, p) => total + p.unitario) +
                          produtosPedido.fold<double>(
                              0,
                              (total, p) =>
                                  total +
                                  (p.adicionais?.fold<double?>(
                                          0,
                                          (total, p) =>
                                              total ?? 0 + p.unitario) ??
                                      0.0));
                      double valorAdicionais = produtosPedido
                          .map((e) => e.adicionais?.fold<double>(
                              0, (total, p) => total + p.unitario))
                          .fold<double>(0, (total, p) => total + (p ?? 0));

                      double valorTotal = valorProdutos + valorAdicionais;
                      return Text(
                        'Total: ${valorTotal.formatted}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                height: MediaQuery.of(context).size.height * 0.06,
                width: MediaQuery.of(context).size.width * 0.3,
                child: const Text(
                  'Salvar Pedido',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        onPressed: produtosPedidoComprovante.isEmpty
            ? null
            : () async {
                bool valuevolt = false;

                int numeropedido = await countDay();

                showDialog(
                  context: context,
                  
                  builder: (BuildContext cxt) {


                    double valorProdutos = produtosPedido.fold<double>(
                            0, (total, p) => total + p.unitario) +
                        produtosPedido.fold<double>(
                            0,
                            (total, p) =>
                                total +
                                (p.adicionais?.fold<double?>(
                                        0,
                                        (total, p) =>
                                            total ?? 0 + p.unitario) ??
                                    0.0));
                    double valorAdicionais = produtosPedido
                        .map((e) => e.adicionais
                            ?.fold<double>(0, (total, p) => total + p.unitario))
                        .fold<double>(0, (total, p) => total + (p ?? 0));

                    double valorTotal = valorProdutos + valorAdicionais;
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.all(0),
                      insetPadding: const EdgeInsets.all(20),
                      content: SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ConfirmacaoPedido(
                            cliente: clienteController.text,
                            localDaEntrega: localDaEntrega.text,
                            valorTotal: valorTotal,
                            produtos: produtosPedido,
                            pagamento: tipoPagamento,
                            numeroPedido: numeropedido.toString(),
                          ),
                        ),
                      ),
                      actions: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            ElevatedButton(
                              onPressed: isloading
                                  ? null
                                  : () async {
                                      final unique =
                                          produtosPedido.toSet().toList();
                                      final produtos = unique
                                          .map(
                                            (p) => ProdutoPedido(
                                              nome: p.nome,
                                              qtde: double.parse(produtosPedido
                                                  .where((p2) => p2 == p)
                                                  .length
                                                  .toString()),
                                              unitario: p.unitario,
                                              tipo: p.tipo ?? '',
                                              adicionais: p.adicionais,
                                            ),
                                          )
                                          .toList();
                                      //tirar produtos do estoque
                                      final produtosPedidoComprovanteFirebase =
                                          produtosPedidoComprovante
                                              .toSet()
                                              .toList();

                                      for (Produto i
                                          in produtosPedidoComprovanteFirebase) {
                                        await FirebaseFirestore.instance
                                            .collection('produtos')
                                            .where('nome', isEqualTo: i.nome)
                                            .get()
                                            .then(
                                          (value) async {
                                            for (var element in value.docs) {
                                              final qtidade =
                                                  produtosPedidoComprovante
                                                      .where((element) =>
                                                          element.nome ==
                                                          i.nome)
                                                      .length;
                                              await FirebaseFirestore.instance
                                                  .collection('produtos')
                                                  .doc(element.id)
                                                  .update(
                                                {
                                                  'estoque':
                                                      FieldValue.increment(
                                                          -qtidade),
                                                },
                                              );
                                            }
                                          },
                                        );
                                      }

                                      if (widget.addnovo == false) {
                                        final pedido = Pedidos(
                                          mesa: mesaController.text,
                                          localDaEntrga: localDaEntrega.text,
                                          data: widget.pedido!.data,
                                          cliente: clienteController.text,
                                          tipopedido: tipoPedido,
                                          tipopagamento: tipoPagamento,
                                          produtos: produtos,
                                          finalizado: 0,
                                          produtosAdicionais: [],
                                          funcionario:
                                              LoginData().getUsuario().nome ??
                                                  'Não informado',
                                          numeroPedido:
                                              widget.pedido!.numeroPedido,
                                        );
                                        final data = pedido.toJson();
                                        FirebaseFirestore.instance
                                            .collection('pedidos')
                                            .doc(widget.pedidoData!.id)
                                            .update(data)
                                            .then(
                                          (doc) {
                                            valuevolt = true;
                                            Navigator.of(context).pop();
                                          },
                                        );
                                      } else if (widget.addnovo == true) {
                                        final unir =
                                            unirProdutos.toSet().toList();
                                        final produtosadicionaislist = unir
                                            .map((p) => ProdutoPedido(
                                                  nome: p.nome,
                                                  qtde: double.parse(
                                                      unirProdutos
                                                          .where(
                                                              (p2) => p2 == p)
                                                          .length
                                                          .toString()),
                                                  unitario: p.unitario,
                                                  tipo: p.tipo ?? '',
                                                  adicionais: p.adicionais,
                                                ))
                                            .toList();
                                        final pedidoadicionais = Pedidos(
                                          mesa: mesaController.text,
                                          localDaEntrga: localDaEntrega.text,
                                          data: DateTime.now(),
                                          cliente: clienteController.text,
                                          produtos: produtosadicionaislist,
                                          tipopedido: tipoPedido,
                                          tipopagamento: tipoPagamento,
                                          finalizado: 0,
                                          produtosAdicionais: produtos,
                                          funcionario:
                                              LoginData().getUsuario().nome ??
                                                  'Não informado',
                                          numeroPedido:
                                              widget.pedido!.numeroPedido,
                                        );

                                        final data2 =
                                            pedidoadicionais.toJsonadd();
                                        FirebaseFirestore.instance
                                            .collection('pedidos')
                                            .doc(widget.pedidoData!.id)
                                            .update(data2)
                                            .then(
                                          (doc) {
                                            valuevolt = true;
                                            Navigator.of(context).pop();
                                          },
                                        );
                                      } else {
                                        final _numeroPedido =
                                            await countDay(save: true);

                                        final pedido = Pedidos(
                                          mesa: mesaController.text,
                                          localDaEntrga: localDaEntrega.text,
                                          data: DateTime.now(),
                                          cliente: clienteController.text,
                                          tipopedido: tipoPedido,
                                          tipopagamento: tipoPagamento,
                                          produtos: produtos,
                                          finalizado: 0,
                                          produtosAdicionais: [],
                                          funcionario:
                                              LoginData().getUsuario().nome ??
                                                  'Não informado',
                                          numeroPedido: _numeroPedido,
                                        );
                                        final data = pedido.toJson();
                                        await FirebaseFirestore.instance
                                            .collection('pedidos')
                                            .add(data)
                                            .then(
                                          (doc) {
                                            valuevolt = true;
                                            Navigator.of(context).pop();
                                          },
                                        );
                                      }
                                    },
                              child: const Text(
                                "Salvar Pedido",
                                style: TextStyle(
                                    color: Colors.green, fontSize: 20),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'Cancelar',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 20),
                              ),
                            ),
                          ],
                        )
                      ],
                    );
                  },
                ).then(
                  (value) {
                    if (valuevolt) {
                      Future.delayed(
                        const Duration(milliseconds: 200),
                        () {
                          Navigator.of(context).pop();
                        },
                      );
                    }
                  },
                );
              },
      ),
    );
  }
}

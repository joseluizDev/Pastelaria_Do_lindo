// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pastelaria/components/text_field_custom.dart';
import 'package:pastelaria/models/produtos.dart';

class ProdutoEditAdd extends StatefulWidget {
  final String? id;
  final Produto? produto;
  const ProdutoEditAdd({
    Key? key,
    this.id,
    this.produto,
  }) : super(key: key);

  @override
  State<ProdutoEditAdd> createState() => _ProdutoEditAddState();
}

class _ProdutoEditAddState extends State<ProdutoEditAdd> {
  final nomeController = TextEditingController();
  final unitarioController = TextEditingController();
  final qtdeController = TextEditingController();
  final tipoController = TextEditingController();
  double precoController = 0.0;
  double estoqueController = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      nomeController.text = widget.produto?.nome ?? '';
      unitarioController.text =
          (widget.produto?.unitario ?? 0).toStringAsFixed(2);
      qtdeController.text = (widget.produto?.estoque ?? 0).toStringAsFixed(0);
      precoController = widget.produto?.unitario ?? 0.0;
      estoqueController = widget.produto?.estoque ?? 0.0;
      tipoController.text = widget.produto?.tipo ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produto'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          TextFieldCustom(
            label: 'Nome',
            controller: nomeController,
          ),
          TextFieldCustom(
            label: 'Preço',
            controller: unitarioController,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                precoController =
                    double.tryParse(value.replaceAll(',', '.')) ?? 0;
              });
            },
          ),
          TextFieldCustom(
            
            label: 'Estoque',
            controller: qtdeController,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                estoqueController =
                    double.tryParse(value.replaceAll(',', '.')) ?? 0;
              });
            },
          ),
          TextFieldCustom(
            label: 'Tipo',
            controller: tipoController,
            keyboardType: TextInputType.text,
            onChanged: (value) {
              setState(() {
                estoqueController =
                    double.tryParse(value.replaceAll(',', '.')) ?? 0;
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
                final Produto produto = Produto(
                  nome: nomeController.text.trimRight(),
                  unitario:
                      double.tryParse(unitarioController.text.trimRight()) ?? 0,
                  estoque:
                      double.tryParse(qtdeController.text.trimRight()) ?? 0,
                  tipo: tipoController.text.trimRight(),
                );
                if (widget.id == null) {
                  await FirebaseFirestore.instance
                      .collection('produtos')
                      .add(produto.toJson());
                } else {
                  await FirebaseFirestore.instance
                      .collection('produtos')
                      .doc(widget.id)
                      .update(produto.toJson());
                }
                Navigator.pop(context);
              },
        child: const Icon(Icons.save),
      ),
    );
  }
}

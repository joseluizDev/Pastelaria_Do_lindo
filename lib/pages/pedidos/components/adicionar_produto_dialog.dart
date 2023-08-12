import 'package:flutter/material.dart';
import 'package:pastelaria/models/produtos.dart';

class AdicionarProdutoDialog extends StatefulWidget {
  final List<Produto> produtosAdicionais;

  const AdicionarProdutoDialog({
    Key? key,
    required this.produtosAdicionais,
  }) : super(key: key);

  @override
  State<AdicionarProdutoDialog> createState() => _AdicionarProdutoDialogState();
}

class _AdicionarProdutoDialogState extends State<AdicionarProdutoDialog> {
  List<Produto> produtosAdd = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.produtosAdicionais.length,
                itemBuilder: (context, index) {
                  final produto = widget.produtosAdicionais[index];
                  bool contains = produtosAdd.contains(produto);
                  print(produto.tipo.toString().toUpperCase());
                  if (produto.tipo.toString().toUpperCase() == "ADD") {
                    return CheckboxListTile(
                      title: Text("R\$" +
                          produto.unitario.toStringAsFixed(2) +
                          " - " +
                          produto.nome),
                      value: contains,
                      onChanged: (value) {
                        setState(() {
                          if (value!) {
                            produtosAdd.add(produto);
                          } else {
                            produtosAdd.remove(produto);
                          }
                        });
                      },
                    );
                  }
                  return SizedBox();
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancelar")),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(produtosAdd);
                    },
                    child: Text(
                      "Adicionar",
                      style: TextStyle(color: Colors.green),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

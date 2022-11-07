import 'package:flutter/material.dart';

import '../pedidos/pedidos_page.dart';
import '../produtos/produto_list.dart';
import '../usuarios/usuario_list.dart';
import '../vendas/vendas_total.dart';

class HomeAdmin extends StatelessWidget {
  const HomeAdmin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Admin'),
        centerTitle: true,
      ),
      body: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          direction: Axis.horizontal,
          runSpacing: 30,
          spacing: 10,
          children: [
            const SizedBox(height: 8),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2.20,
              height: 180,
              child: Card(
                child: ListTile(
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.list,
                        size: 70,
                      ),
                      Center(child: Text('Pedidos')),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PedidosPage()),
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2.15,
              height: 180,
              child: Card(
                child: ListTile(
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.person,
                        size: 70,
                      ),
                      Center(child: Text('Usuários')),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const UsuarioList()),
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2.15,
              height: 180,
              child: Card(
                child: ListTile(
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.shopping_cart,
                        size: 70,
                      ),
                      Center(child: Text('Produtos')),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProdutoList()),
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2.15,
              height: 180,
              child: Card(
                child: ListTile(
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.attach_money_outlined,
                        size: 70,
                      ),
                      Center(child: Text('Relatório de Vendas')),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const VendasTotal()),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

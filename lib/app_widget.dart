import 'package:flutter/material.dart';
import 'package:pastelaria/pages/splash/splash_page.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
      //home: const PedidosWeb(),

      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
    );
  }
}

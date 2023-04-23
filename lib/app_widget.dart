import 'package:flutter/material.dart';
import 'package:pastelaria/pages/splash/splash_page.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //  home: const SplashPage(),
      home: const SplashPage(),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.red)
            .copyWith(background: const Color.fromARGB(255, 236, 236, 236))
            .copyWith(secondary: const Color.fromARGB(255, 243, 243, 243)),
        scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255),
        dialogTheme: DialogTheme(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          iconColor: Color.fromARGB(255, 0, 0, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

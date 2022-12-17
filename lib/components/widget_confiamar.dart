import 'package:flutter/material.dart';

class WidgetConfiamar extends StatefulWidget {
  const WidgetConfiamar({super.key});

  @override
  State<WidgetConfiamar> createState() => _WidgetConfiamarState();
}

class _WidgetConfiamarState extends State<WidgetConfiamar> {
  @override
  Widget build(BuildContext context) {
    return const FractionallySizedBox(
      heightFactor: 0.8,
      widthFactor: 0.8,
      child: Card(
        child: Center(
          child: Text('Confirmação'),
        ),
      ),
    );
  }
}

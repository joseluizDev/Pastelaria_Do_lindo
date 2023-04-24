import 'dart:convert';

import 'package:blue_print_pos/blue_print_pos.dart';
import 'package:blue_print_pos/models/blue_device.dart';
import 'package:blue_print_pos/models/connection_status.dart';
import 'package:blue_print_pos/receipt/receipt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pastelaria/utils/extensions.dart';

import '../../../models/enum_pagamento.dart';
import '../../../models/produtos.dart';
import 'diveder_custom.dart';
import 'informacoes_pedido.dart';

class ConfirmacaoPedido extends StatefulWidget {
  final String cliente;
  final List<Produto> produtos;
  final double valorTotal;
  final TipoPagamento pagamento;
  final int numeroPedido;
  final String localEntrega;

  const ConfirmacaoPedido({
    super.key,
    required this.cliente,
    required this.localEntrega,
    required this.produtos,
    required this.valorTotal,
    required this.pagamento,
    required this.numeroPedido,
  });

  @override
  State<ConfirmacaoPedido> createState() => _ConfirmacaoPedidoState();
}

class _ConfirmacaoPedidoState extends State<ConfirmacaoPedido> {
  final String data = DateTime.now().toString().substring(0, 10);
  final String hora = DateTime.now().toString().substring(11, 16);

  final BluePrintPos _bluePrintPos = BluePrintPos.instance;
  List<BlueDevice> _blueDevices = <BlueDevice>[];
  BlueDevice? _selectedDevice;
  bool _isLoading = false;
  int _loadingAtIndex = -1;

  @override
  void initState() {
    super.initState();
    initFuture();
  }

  Future initFuture() async {
    await _onScanPressed();
    for (BlueDevice device in _blueDevices) {
      if (device.name == 'KP-1025') {
        _selectedDevice = device;
        break;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 20,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(
                        top: 15,
                      ),
                      child: Text(
                        'Comprovante',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/iconp.png',
                      height: 100,
                      width: 100,
                      color: Colors.black87,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(
                        left: 15,
                        right: 15,
                      ),
                      child: DividerCustom(),
                    ),
                    TituloComprovante(
                      hora: hora,
                      cliente: widget.cliente,
                      localEntrega: widget.localEntrega,
                      numeroPedido: '',
                      data: data,
                      pagamento: widget.pagamento,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(
                        left: 15,
                        right: 15,
                      ),
                      child: DividerCustom(),
                    ),
                    Builder(
                      builder: (context) {
                        // adicionar so um produto sem repetir

                        final produtosUnicos = widget.produtos.toSet().toList();
                        return Column(
                          children: [
                            ...List.generate(
                              produtosUnicos.length,
                              (index) {
                                final produto = produtosUnicos[index];
                                final quantidade = widget.produtos
                                    .where((element) =>
                                        element.nome == produto.nome)
                                    .length;
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 15,
                                        right: 15,
                                        top: 2,
                                        bottom: 2,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '$quantidade X  ',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            produto.nome,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            (produto.unitario * quantidade)
                                                .formatted,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (index == produtosUnicos.length - 1) ...[
                                      const Padding(
                                        padding: EdgeInsets.only(
                                          left: 15,
                                          right: 15,
                                        ),
                                        child: DividerCustom(),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        children: [
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            'Total: ${widget.valorTotal.formatted}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Center(
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                            left: 15,
                                            right: 15,
                                            top: 5,
                                            bottom: 5,
                                          ),
                                          color: Colors.black,
                                          child: Text(
                                            widget.numeroPedido.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                    ]
                                  ],
                                );
                              },
                            ),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                  margin: const EdgeInsets.only(
                    left: 25,
                    right: 25,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      ...List<Widget>.generate(_blueDevices.length,
                          (int index) {
                        final BlueDevice blueDevice = _blueDevices[index];

                        return ListTile(
                          title: Text(
                            blueDevice.name,
                            style: TextStyle(
                              color: blueDevice.name == _selectedDevice?.name
                                  ? Colors.red
                                  : Colors.black,
                            ),
                          ),
                          onTap: () {
                            try {
                              _onSelectDevice(index);
                            } catch (e) {}
                            setState(() {});
                          },
                        );
                      }),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onScanPressed() async {
    setState(() => _isLoading = true);
    _bluePrintPos.scan().then((List<BlueDevice> devices) {
      if (devices.isNotEmpty) {
        setState(() {
          _blueDevices = devices;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    });
  }

  void _onDisconnectDevice() {
    _bluePrintPos.disconnect().then((ConnectionStatus status) {
      if (status == ConnectionStatus.disconnect) {
        setState(() {
          _selectedDevice = null;
        });
      }
    });
  }

  void _onSelectDevice(int index) {
    setState(() {
      _isLoading = true;
      _loadingAtIndex = index;
    });
    final BlueDevice blueDevice = _blueDevices[index];
    _bluePrintPos.connect(blueDevice).then((ConnectionStatus status) {
      if (status == ConnectionStatus.connected) {
        setState(() => _selectedDevice = blueDevice);
      } else if (status == ConnectionStatus.timeout) {
        _onDisconnectDevice();
      } else {
        print('$runtimeType - something wrong');
      }
      setState(() => _isLoading = false);
    });
  }

  Future<void> _onPrintReceipt() async {
    /// Example for Print Image
    final ByteData logoBytes = await rootBundle.load(
      'assets/logo.jpg',
    );

    /// Example for Print Text
    final ReceiptSectionText receiptText = ReceiptSectionText();
    receiptText.addImage(
      base64.encode(Uint8List.view(logoBytes.buffer)),
      width: 150,
    );
    receiptText.addSpacer();
    receiptText.addText(
      'MY STORE',
      size: ReceiptTextSizeType.medium,
      style: ReceiptTextStyleType.bold,
    );
    receiptText.addText(
      'Black White Street, Jakarta, Indonesia',
      size: ReceiptTextSizeType.small,
    );
    receiptText.addSpacer(useDashed: true);
    receiptText.addLeftRightText('Time', '04/06/21, 10:00');
    receiptText.addSpacer(useDashed: true);
    receiptText.addLeftRightText(
      'Apple 1kg',
      'Rp30.000',
      leftStyle: ReceiptTextStyleType.normal,
      rightStyle: ReceiptTextStyleType.bold,
    );
    receiptText.addSpacer(useDashed: true);
    receiptText.addLeftRightText(
      'TOTAL',
      'Rp30.000',
      leftStyle: ReceiptTextStyleType.normal,
      rightStyle: ReceiptTextStyleType.bold,
    );
    receiptText.addSpacer(useDashed: true);
    receiptText.addLeftRightText(
      'Payment',
      'Cash',
      leftStyle: ReceiptTextStyleType.normal,
      rightStyle: ReceiptTextStyleType.normal,
    );
    receiptText.addSpacer(count: 2);

    await _bluePrintPos.printReceiptText(receiptText);

    /// Example for print QR
    await _bluePrintPos.printQR('www.google.com', size: 250);

    /// Text after QR
    final ReceiptSectionText receiptSecondText = ReceiptSectionText();
    receiptSecondText.addText('Powered by ayeee',
        size: ReceiptTextSizeType.small);
    receiptSecondText.addSpacer();
    await _bluePrintPos.printReceiptText(receiptSecondText, feedCount: 1);
  }
}

<<<<<<< Updated upstream
import 'dart:convert';

import 'package:blue_print_pos/blue_print_pos.dart';
import 'package:blue_print_pos/models/blue_device.dart';
import 'package:blue_print_pos/models/connection_status.dart';
import 'package:blue_print_pos/receipt/receipt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
=======
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_scan_bluetooth/flutter_scan_bluetooth.dart';
import 'package:image/image.dart' as img;
>>>>>>> Stashed changes
import 'package:pastelaria/utils/extensions.dart';

import '../../../models/enum_pagamento.dart';
import '../../../models/produtos.dart';
<<<<<<< Updated upstream
=======
import '../../../printer/impressora.dart';
>>>>>>> Stashed changes
import 'diveder_custom.dart';
import 'informacoes_pedido.dart';

class ConfirmacaoPedido extends StatefulWidget {
<<<<<<< Updated upstream
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
=======
  final String? cliente;
  final List<Produto> produtos;
  final double valorTotal;
  final TipoPagamento pagamento;
  final String numeroPedido;
  final String localDaEntrega;
  @override
  const ConfirmacaoPedido({
    super.key,
    this.cliente,
>>>>>>> Stashed changes
    required this.produtos,
    required this.valorTotal,
    required this.pagamento,
    required this.numeroPedido,
<<<<<<< Updated upstream
=======
    required this.localDaEntrega,
>>>>>>> Stashed changes
  });

  @override
  State<ConfirmacaoPedido> createState() => _ConfirmacaoPedidoState();
}

class _ConfirmacaoPedidoState extends State<ConfirmacaoPedido> {
<<<<<<< Updated upstream
  final String data = DateTime.now().toString().substring(0, 10);
  final String hora = DateTime.now().toString().substring(11, 16);

  final BluePrintPos _bluePrintPos = BluePrintPos.instance;
  List<BlueDevice> _blueDevices = <BlueDevice>[];
  BlueDevice? _selectedDevice;
  bool _isLoading = false;
  int _loadingAtIndex = -1;
=======
  final String datahorario = DateTime.now().toString().substring(0, 10);
  final String hora = DateTime.now().toString().substring(11, 16);
  var thumbnail;
  ByteData? logoBytes;
  bool pdv = true;
  final FlutterScanBluetooth _bluetooth = FlutterScanBluetooth();
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];

  init() async {
    final ByteData data = await rootBundle.load('assets/iconp.png');
    final Uint8List bytesImage = data.buffer.asUint8List();
    final image = img.decodeImage(bytesImage)!;
    thumbnail = img.copyResize(image, width: 100);
  }
>>>>>>> Stashed changes

  @override
  void initState() {
    super.initState();
<<<<<<< Updated upstream
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
=======
    init();
    _bluetooth.startScan(pairedDevices: true);
    printerManager.scanResults.listen((devices) async {
      setState(() {
        _devices = devices;
      });
    });
    _bluetooth.stopScan();
    _startScanDevices();
  }

  void _startScanDevices() {
    setState(() {
      _devices = [];
    });
    printerManager.startScan(const Duration(seconds: 4));
  }

  Future<List<int>> demoReceipt(
      PaperSize paper, CapabilityProfile profile) async {
    final Generator ticket = Generator(paper, profile);
    List<int> bytes = [];
    //imagem
    bytes += ticket.beep();

    bytes += ticket.text(
      "COMPROVANTE",
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    bytes += ticket.image(thumbnail);
    bytes += ticket.hr();

    final client = widget.cliente == '' ? 'Nao definido' : widget.cliente!;
    bytes += ticket.text(
      "Cliente:" + client,
      styles: const PosStyles(
        align: PosAlign.left,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );

    bytes += ticket.text(
      "Data:" + datahorario + " " + hora,
      styles: const PosStyles(
        align: PosAlign.left,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );

    final pagamento = widget.pagamento.index == 0
        ? 'Nao definido'
        : widget.pagamento.index == 1
            ? 'Dinheiro'
            : widget.pagamento.index == 2
                ? 'Cartao'
                : 'Pix';
    bytes += ticket.text(
      "Pagamento: $pagamento",
      styles: const PosStyles(
        align: PosAlign.left,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );

    if (widget.localDaEntrega != '') {
      bytes += ticket.text(
        "Endereco: " + widget.localDaEntrega,
        styles: const PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      );
    }

    bytes += ticket.hr();
    List<Produto> produtos = widget.produtos.toSet().toList();
    for (var i = 0; i < produtos.length; i++) {
      final nome = widget.produtos[i].nome;
      final qtd =
          widget.produtos.where((element) => element.nome == nome).length;
      final valor = widget.produtos[i].unitario;
      bytes += ticket.row([
        PosColumn(
          text: qtd.toString() + 'x',
          width: 1,
          styles: const PosStyles(
            align: PosAlign.right,
          ),
        ),
        PosColumn(
          text: nome,
          width: 8,
          styles: const PosStyles(
            align: PosAlign.center,
          ),
        ),
        PosColumn(
          text: valor.formatted,
          width: 3,
          styles: const PosStyles(
            align: PosAlign.right,
          ),
        ),
      ]);
      if (widget.produtos[i].adicionais != null) {
        //widget.produtos[i].adicionais!.length
        for (var j = 0; j < widget.produtos[i].adicionais!.length; j++) {
          final nomeAdicional = widget.produtos[i].adicionais![j].nome;
          final qtdAdicional = widget.produtos[i].adicionais!
              .where((element) => element.nome == nomeAdicional)
              .length;
          final valorAdicional = widget.produtos[i].adicionais![j].unitario;
          bytes += ticket.row([
            PosColumn(
              text: qtdAdicional.toString() + 'x',
              width: 1,
              styles: const PosStyles(
                align: PosAlign.right,
              ),
            ),
            PosColumn(
              text: nomeAdicional,
              width: 8,
              styles: const PosStyles(
                align: PosAlign.center,
              ),
            ),
            PosColumn(
              text: valorAdicional.formatted,
              width: 3,
              styles: const PosStyles(
                align: PosAlign.right,
              ),
            ),
          ]);
        }
      }
    }
    bytes += ticket.hr();

    bytes += ticket.row([
      PosColumn(
        text: 'Total',
        width: 8,
        styles: const PosStyles(
          align: PosAlign.right,
        ),
      ),
      PosColumn(
        text: widget.valorTotal.formatted,
        width: 4,
        styles: const PosStyles(
          align: PosAlign.right,
        ),
      ),
    ]);
    bytes += ticket.text(
      widget.numeroPedido,
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += ticket.hr(ch: ' ', linesAfter: 2);
    bytes += ticket.feed(2);

    return bytes;
  }

  void _testPrint(PrinterBluetooth printer) async {
    try {
      printerManager.selectPrinter(printer);
      const PaperSize paper = PaperSize.mm58;
      final profile = await CapabilityProfile.load();
      final impressao = await demoReceipt(paper, profile);
      await printerManager.printTicket(impressao);
    } catch (e) {
      print("erro$e");
    }
>>>>>>> Stashed changes
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< Updated upstream
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
=======
    return Column(
      children: [
        SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black87, width: 2),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                    cliente: widget.cliente ?? '',
                    numeroPedido: '',
                    data: datahorario,
                    pagamento: widget.pagamento,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(
                      left: 15,
                      right: 15,
                    ),
                    child: DividerCustom(),
                  ),
                  Builder(builder: (context) {
                    // adicionar so um produto sem repetir
                    final produtosUnicos = widget.produtos.toSet().toList();

                    return ListView.builder(
                      itemCount: produtosUnicos.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (_, index) {
                        final produto = produtosUnicos[index];
                        final quantidade = widget.produtos
                            .where((element) => element.nome == produto.nome)
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
                                    (produto.unitario * quantidade).formatted,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (produto.adicionais != null)
                              ...List.generate(
                                  produto.adicionais!.length,
                                  (index) => Padding(
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
                                              '1 X  ',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              produto.adicionais![index].nome,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              (produto.adicionais![index]
                                                          .unitario *
                                                      1)
                                                  .formatted,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
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
                                    widget.numeroPedido,
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
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        StreamBuilder<bool>(
          stream: printerManager.isScanningStream,
          initialData: false,
          builder: (c, snapshot) {
            if (snapshot.data!) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (_devices.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async {
                      comproventePrint(
                        widget.cliente,
                        widget.produtos,
                        widget.valorTotal,
                        widget.pagamento,
                        widget.numeroPedido,
                        widget.localDaEntrega,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: const Text('Imprimir PDV'),
                    ),
                  ),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: _devices.length,
              itemBuilder: (BuildContext context, int index) {
                if (_devices[index].name != 'KP-1025') {
                  return const SizedBox();
                }
                return InkWell(
                  onTap: () async {
                    _testPrint(_devices[index]);
                  },
                  child: Card(
                    child: Container(
                      height: 60,
                      padding: const EdgeInsets.only(left: 10),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.print),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(_devices[index].name ?? ''),
                              Text(_devices[index].address!),
                              Text(
                                'Clique para imprimir',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
>>>>>>> Stashed changes
}

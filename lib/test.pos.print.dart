import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

import 'enums.dart';
import 'mobile.esc.pos.printer.dart';

Future<void> testPosPrint() async {
  EasyLoading.show(status: 'Printing slip...');
  const PaperSize paper = PaperSize.mm80;
  final profile = await CapabilityProfile.load();
  final printer = NetworkPrinter(paper, profile);

  final PosPrintResult res = await printer.connect('192.168.1.100', port: 9100);

  if (res == PosPrintResult.success) {
    await testReceipt(printer)
        .then((_) async => await printDemoReceipt(printer))
        .then((_) {
      printer.disconnect();
      EasyLoading.dismiss();
    });
  } else {
    EasyLoading.showError(res.msg);
  }
  debugPrint('Print result: ${res.msg}');
}

Future<void> testReceipt(NetworkPrinter printer) async {
  printer.text(
      'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
  printer.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
      styles: const PosStyles(codeTable: 'CP1252'));
  printer.text('Special 2: blåbærgrød',
      styles: const PosStyles(codeTable: 'CP1252'));

  printer.text('Bold text', styles: const PosStyles(bold: true));
  printer.text('Reverse text', styles: const PosStyles(reverse: true));
  printer.text('Underlined text',
      styles: const PosStyles(underline: true), linesAfter: 1);
  printer.text('Align left', styles: const PosStyles(align: PosAlign.left));
  printer.text('Align center', styles: const PosStyles(align: PosAlign.center));
  printer.text('Align right',
      styles: const PosStyles(align: PosAlign.right), linesAfter: 1);

  printer.row([
    PosColumn(
      text: 'col3',
      width: 3,
      styles: const PosStyles(align: PosAlign.center, underline: true),
    ),
    PosColumn(
      text: 'col6',
      width: 6,
      styles: const PosStyles(align: PosAlign.center, underline: true),
    ),
    PosColumn(
      text: 'col3',
      width: 3,
      styles: const PosStyles(align: PosAlign.center, underline: true),
    ),
  ]);

  printer.text('Text size 200%',
      styles: const PosStyles(
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ));

  // Print image
  final ByteData data = await rootBundle.load('assets/pos/favourite.png');
  final Uint8List bytes = data.buffer.asUint8List();
  final img.Image? image = img.decodeImage(bytes);
  printer.image(image!);
  // Print image using alternative commands
  // printer.imageRaster(image);
  // printer.imageRaster(image, imageFn: PosImageFn.graphics);

  // Print barcode
  final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
  printer.barcode(Barcode.upcA(barData));

  // Print mixed (chinese + latin) text. Only for printers supporting Kanji mode
  // printer.text(
  //   'hello ! 中文字 # world @ éphémère &',
  //   styles: PosStyles(codeTable: PosCodeTable.westEur),
  //   containsChinese: true,
  // );

  printer.feed(2);
  printer.cut();
}

Future<void> printDemoReceipt(NetworkPrinter printer) async {
  // Print image
  final ByteData data = await rootBundle.load('assets/pos/rabbit_black.jpg');
  final Uint8List bytes = data.buffer.asUint8List();
  final img.Image? image = img.decodeImage(bytes);
  if (image != null) printer.image(image);

  printer.text('GROCERYLY',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1);

  printer.text('889  Watson Lane',
      styles: const PosStyles(align: PosAlign.center));
  printer.text('New Braunfels, TX',
      styles: const PosStyles(align: PosAlign.center));
  printer.text('Tel: 830-221-1234',
      styles: const PosStyles(align: PosAlign.center));
  printer.text('Web: www.example.com',
      styles: const PosStyles(align: PosAlign.center), linesAfter: 1);

  printer.hr();
  printer.row([
    PosColumn(text: 'Qty', width: 1),
    PosColumn(text: 'Item', width: 7),
    PosColumn(
        text: 'Price',
        width: 2,
        styles: const PosStyles(align: PosAlign.right)),
    PosColumn(
        text: 'Total',
        width: 2,
        styles: const PosStyles(align: PosAlign.right)),
  ]);

  printer.row([
    PosColumn(text: '2', width: 1),
    PosColumn(text: 'ONION RINGS', width: 7),
    PosColumn(
        text: '0.99', width: 2, styles: const PosStyles(align: PosAlign.right)),
    PosColumn(
        text: '1.98', width: 2, styles: const PosStyles(align: PosAlign.right)),
  ]);
  printer.row([
    PosColumn(text: '1', width: 1),
    PosColumn(text: 'PIZZA', width: 7),
    PosColumn(
        text: '3.45', width: 2, styles: const PosStyles(align: PosAlign.right)),
    PosColumn(
        text: '3.45', width: 2, styles: const PosStyles(align: PosAlign.right)),
  ]);
  printer.row([
    PosColumn(text: '1', width: 1),
    PosColumn(text: 'SPRING ROLLS', width: 7),
    PosColumn(
        text: '2.99', width: 2, styles: const PosStyles(align: PosAlign.right)),
    PosColumn(
        text: '2.99', width: 2, styles: const PosStyles(align: PosAlign.right)),
  ]);
  printer.row([
    PosColumn(text: '3', width: 1),
    PosColumn(text: 'CRUNCHY STICKS', width: 7),
    PosColumn(
        text: '0.85', width: 2, styles: const PosStyles(align: PosAlign.right)),
    PosColumn(
        text: '2.55', width: 2, styles: const PosStyles(align: PosAlign.right)),
  ]);
  printer.hr();

  printer.row([
    PosColumn(
        text: 'TOTAL',
        width: 6,
        styles: const PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        )),
    PosColumn(
        text: '\$10.97',
        width: 6,
        styles: const PosStyles(
          align: PosAlign.right,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        )),
  ]);

  printer.hr(ch: '=', linesAfter: 1);

  printer.row([
    PosColumn(
        text: 'Cash',
        width: 8,
        styles:
            const PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    PosColumn(
        text: '\$15.00',
        width: 4,
        styles:
            const PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
  ]);
  printer.row([
    PosColumn(
        text: 'Change',
        width: 8,
        styles:
            const PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    PosColumn(
        text: '\$4.03',
        width: 4,
        styles:
            const PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
  ]);

  printer.feed(2);
  printer.text('Thank you!',
      styles: const PosStyles(align: PosAlign.center, bold: true));

  final now = DateTime.now();
  final formatter = DateFormat('MM/dd/yyyy H:m');
  final String timestamp = formatter.format(now);
  printer.text(timestamp,
      styles: const PosStyles(align: PosAlign.center), linesAfter: 2);

  // Print QR Code from image
  // try {
  //   const String qrData = 'example.com';
  //   const double qrSize = 200;
  //   final uiImg = await QrPainter(
  //     data: qrData,
  //     version: QrVersions.auto,
  //     gapless: false,
  //   ).toImageData(qrSize);
  //   final dir = await getTemporaryDirectory();
  //   final pathName = '${dir.path}/qr_tmp.png';
  //   final qrFile = File(pathName);
  //   final imgFile = await qrFile.writeAsBytes(uiImg.buffer.asUint8List());
  //   final img = decodeImage(imgFile.readAsBytesSync());

  //   printer.image(img);
  // } catch (e) {
  //   print(e);
  // }

  // Print QR Code using native function
  printer.qrcode('example.com');

  printer.feed(1);
  printer.cut();
}

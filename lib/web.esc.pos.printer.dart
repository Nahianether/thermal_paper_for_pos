// /*
//  * esc_pos_printer
//  * Created by Andrey Ushakov
//  * 
//  * Copyright (c) 2019-2020. All rights reserved.
//  * See LICENSE for distribution and usage details.
//  */

// import 'package:http/http.dart' as http;
// import 'dart:typed_data' show Uint8List;

// import 'package:flutter/material.dart' as mw;
// import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
// import 'package:image/image.dart';

// import 'enums.dart';

// /// Network Printer
// class NetworkPrinterMobile {
//   NetworkPrinterMobile(this._paperSize, this._profile,
//       {int spaceBetweenRows = 5}) {
//     _generator =
//         Generator(paperSize, profile, spaceBetweenRows: spaceBetweenRows);
//   }

//   final PaperSize _paperSize;
//   final CapabilityProfile _profile;
//   String? _host;
//   int? _port;
//   late Generator _generator;
//   // late Socket _socket;

//   int? get port => _port;
//   String? get host => _host;
//   PaperSize get paperSize => _paperSize;
//   CapabilityProfile get profile => _profile;

//   Future<PosPrintResult> connect(String host,
//       {int port = 91000, Duration timeout = const Duration(seconds: 5)}) async {
//     _host = host;
//     _port = port;

//     try {
//       // Use the http package to make an HTTP POST request
//       final response = await http.post(Uri.parse('http://$host:$port'),
//           body: _generator.reset()); // Replace with appropriate API endpoint

//       if (response.statusCode == 200) {
//         mw.debugPrint('>>>>>> Successfully connected to printer');
//         return Future<PosPrintResult>.value(PosPrintResult.success);
//       } else {
//         mw.debugPrint('>>>>>> Failed to connect to printer');
//         return Future<PosPrintResult>.value(PosPrintResult.timeout);
//       }
//     } catch (e) {
//       mw.debugPrint('>>>>>> Exception while connecting: $e');
//       return Future<PosPrintResult>.value(PosPrintResult.timeout);
//     }
//   }

//   /// [delayMs]: milliseconds to wait after destroying the socket
//   Future<void> disconnect({int? delayMs}) async {
//     // Send the disconnect request to the printer's API endpoint
//     await http.post(
//       Uri.parse('http://$_host:$_port/disconnect'),
//       body: _generator.reset(), // You can adjust the body as needed
//     );

//     if (delayMs != null) {
//       await Future.delayed(Duration(milliseconds: delayMs));
//     }
//   }

//   // ************************ Printer Commands ************************
//   void reset() {
//     http.post(Uri.parse('http://$_host:$_port/reset'),
//         body: _generator.reset());
//   }

//   void text(
//     String text, {
//     PosStyles styles = const PosStyles(),
//     int linesAfter = 0,
//     bool containsChinese = false,
//     int? maxCharsPerLine,
//   }) {
//     http.post(
//       Uri.parse('http://$_host:$_port/text'),
//       body: _generator.text(
//         text,
//         styles: styles,
//         linesAfter: linesAfter,
//         containsChinese: containsChinese,
//         maxCharsPerLine: maxCharsPerLine,
//       ),
//     );
//   }

//   void setGlobalCodeTable(String codeTable) {
//     http.post(
//       Uri.parse('http://$_host:$_port/setGlobalCodeTable'),
//       body: _generator.setGlobalCodeTable(codeTable),
//     );
//   }

//   void setGlobalFont(PosFontType font, {int? maxCharsPerLine}) {
//     http.post(
//       Uri.parse('http://$_host:$_port/setGlobalFont'),
//       body: _generator.setGlobalFont(font, maxCharsPerLine: maxCharsPerLine),
//     );
//   }

//   void setStyles(PosStyles styles, {bool isKanji = false}) {
//     http.post(
//       Uri.parse('http://$_host:$_port/setStyles'),
//       body: _generator.setStyles(styles, isKanji: isKanji),
//     );
//   }

//   void rawBytes(List<int> cmd, {bool isKanji = false}) {
//     http.post(
//       Uri.parse('http://$_host:$_port/rawBytes'),
//       body: _generator.rawBytes(cmd, isKanji: isKanji),
//     );
//   }

//   void emptyLines(int n) {
//     http.post(
//       Uri.parse('http://$_host:$_port/emptyLines'),
//       body: _generator.emptyLines(n),
//     );
//   }

//   void feed(int n) {
//     http.post(
//       Uri.parse('http://$_host:$_port/feed'),
//       body: _generator.feed(n),
//     );
//   }

//   void cut({PosCutMode mode = PosCutMode.full}) {
//     http.post(
//       Uri.parse('http://$_host:$_port/cut'),
//       body: _generator.cut(mode: mode),
//     );
//   }

//   void printCodeTable({String? codeTable}) {
//     http.post(
//       Uri.parse('http://$_host:$_port/printCodeTable'),
//       body: _generator.printCodeTable(codeTable: codeTable),
//     );
//   }

//   void beep({int n = 3, PosBeepDuration duration = PosBeepDuration.beep450ms}) {
//     http.post(
//       Uri.parse('http://$_host:$_port/beep'),
//       body: _generator.beep(n: n, duration: duration),
//     );
//   }

//   void reverseFeed(int n) {
//     http.post(
//       Uri.parse('http://$_host:$_port/reverseFeed'),
//       body: _generator.reverseFeed(n),
//     );
//   }

//   void row(List<PosColumn> cols) {
//     http.post(
//       Uri.parse('http://$_host:$_port/row'),
//       body: _generator.row(cols),
//     );
//   }

//   void image(Image imgSrc, {PosAlign align = PosAlign.center}) {
//     http.post(
//       Uri.parse('http://$_host:$_port/image'),
//       body: _generator.image(imgSrc, align: align),
//     );
//   }

//   void imageRaster(
//     Image image, {
//     PosAlign align = PosAlign.center,
//     bool highDensityHorizontal = true,
//     bool highDensityVertical = true,
//     PosImageFn imageFn = PosImageFn.bitImageRaster,
//   }) {
//     http.post(
//       Uri.parse('http://$_host:$_port/imageRaster'),
//       body: _generator.imageRaster(
//         image,
//         align: align,
//         highDensityHorizontal: highDensityHorizontal,
//         highDensityVertical: highDensityVertical,
//         imageFn: imageFn,
//       ),
//     );
//   }

//   void barcode(
//     Barcode barcode, {
//     int? width,
//     int? height,
//     BarcodeFont? font,
//     BarcodeText textPos = BarcodeText.below,
//     PosAlign align = PosAlign.center,
//   }) {
//     http.post(
//       Uri.parse('http://$_host:$_port/barcode'),
//       body: _generator.barcode(
//         barcode,
//         width: width,
//         height: height,
//         font: font,
//         textPos: textPos,
//         align: align,
//       ),
//     );
//   }

//   void qrcode(
//     String text, {
//     PosAlign align = PosAlign.center,
//     QRSize size = QRSize.size4,
//     QRCorrection cor = QRCorrection.L,
//   }) {
//     http.post(
//       Uri.parse('http://$_host:$_port/qrcode'),
//       body: _generator.qrcode(text, align: align, size: size, cor: cor),
//     );
//   }

//   void drawer({PosDrawer pin = PosDrawer.pin2}) {
//     http.post(
//       Uri.parse('http://$_host:$_port/drawer'),
//       body: _generator.drawer(pin: pin),
//     );
//   }

//   void hr({String ch = '-', int? len, int linesAfter = 0}) {
//     http.post(
//       Uri.parse('http://$_host:$_port/hr'),
//       body: _generator.hr(ch: ch, len: len, linesAfter: linesAfter),
//     );
//   }

//   void textEncoded(
//     Uint8List textBytes, {
//     PosStyles styles = const PosStyles(),
//     int linesAfter = 0,
//     int? maxCharsPerLine,
//   }) {
//     http.post(
//       Uri.parse('http://$_host:$_port/textEncoded'),
//       body: _generator.textEncoded(
//         textBytes,
//         styles: styles,
//         linesAfter: linesAfter,
//         maxCharsPerLine: maxCharsPerLine,
//       ),
//     );
//   }
//   // ************************ (end) Printer Commands ************************
// }

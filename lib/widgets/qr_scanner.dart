import 'dart:developer';
import 'dart:io';
import 'package:acs_check/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:acs_check/widgets/big_text.dart';
import 'package:acs_check/widgets/small_text.dart';


class QRScanner extends StatefulWidget {
  const QRScanner({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  bool? isFlashOn;

  @override
  void initState() {
    super.initState();
    _getFlashStatus(); 
  }

  Future<void> _getFlashStatus() async {
    bool? status = await controller?.getFlashStatus();
    setState(() {
      isFlashOn = status;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                    SizedBox(height: Dimensions.height5),
                    BigText(text: 'สแกนจุดตรวจ', size: Dimensions.font18),
                    Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                     Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller?.toggleFlash();
                            await _getFlashStatus(); 
                          },
                          child: SmallText(
                            text: isFlashOn == true ? "แฟลช: เปิด" : "แฟลช: ปิด",
                            size: Dimensions.font18, 
                            color: AppColors.darkGreyColor
                          ),
                        ),
                      ),

                       Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); 
                          },
                          child: SmallText(
                            text: "ยกเลิก", 
                            size: Dimensions.font20,
                            color: AppColors.darkGreyColor
                          ),
                        ),
                       )
                    ],
                  ),
                  SizedBox(height: Dimensions.height5)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
  var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
    ? MediaQuery.of(context).size.width * 0.8
    : MediaQuery.of(context).size.width * 0.6;
   
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    setState(() {
      result = null;
    });

    controller.scannedDataStream.listen((scanData) {
      if (scanData != null) {
        if (result == null) {
          setState(() {
            result = scanData;
          });

          if (result!.code != null) {
            Navigator.pop(context, result!.code);
          }
        }
      }
    });
  }


  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
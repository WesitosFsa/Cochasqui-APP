import 'package:cochasqui_park/features/ar_experience/models/ARModel.dart';
import 'package:cochasqui_park/features/ar_experience/museum_screen.dart';
import 'package:cochasqui_park/shared/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  final ARModel model;

  const QRScannerScreen({super.key, required this.model});

  @override
  // ignore: library_private_types_in_public_api
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isProcessing = false;
  String? scannedCode;

  void _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null) {
        setState(() {
          _isProcessing = true;
          scannedCode = code;
        });

        await Future.delayed(const Duration(seconds: 2));

        setState(() => _isProcessing = false);
        break;
      }
    }
  }

  void _handleUnlock() {
    if (scannedCode == null) return;

    final scanned = scannedCode!.trim().toLowerCase();
    final correct = widget.model.answer.trim().toLowerCase();

    if (scanned == correct) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MuseumScreen(model: widget.model.copyWith(unlocked: true)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Respuesta incorrecta, intenta de nuevo')),
      );
      setState(() => scannedCode = null); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.blanco,
              AppColors.azulOscuro,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch, 
              children: [
  
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 60.0, 20.0, 20.0), 
                  child: Text(
                    widget.model.riddle,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),

     
                Center( 
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.negroAzulado, width: 4),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    child: MobileScanner(
                      onDetect: _onBarcodeDetected,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (scannedCode != null) ...[
                  const Center(child: Icon(Icons.qr_code, size: 80, color: Colors.white)), 
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      scannedCode!,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const Spacer(), 
              ],
            ),

            Positioned(
              bottom: 60,
              left: 30,
              right: 30,
              child: ElevatedButton(
                onPressed: scannedCode != null ? _handleUnlock : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.azulMedio,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Responder',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension ARModelCopy on ARModel {
  ARModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? key,
    String? riddle,
    String? answer,
    bool? unlocked,
  }) {
    return ARModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      key: key ?? this.key,
      riddle: riddle ?? this.riddle,
      answer: answer ?? this.answer,
      unlocked: unlocked ?? this.unlocked,
    );
  }
}
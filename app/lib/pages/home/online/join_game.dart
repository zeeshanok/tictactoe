import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tictactoe/common/utils.dart';
import 'package:tictactoe/common/widgets/default_dialog.dart';
import 'package:tictactoe/services/multiplayer_service.dart';

class JoinGameDialog extends StatefulWidget {
  const JoinGameDialog({super.key});

  @override
  State<JoinGameDialog> createState() => _JoinGameDialogState();
}

class _JoinGameDialogState extends State<JoinGameDialog> {
  final _controller = TextEditingController();
  final _scannerController = MobileScannerController(returnImage: false);
  bool _enabled = false;

  void onSubmit() {
    setState(() {
      _enabled = false;
    });
    GetIt.instance<MultiplayerService>()
        .joinGame(int.parse(_controller.text))
        .then((manager) => manager.ready.then((success) {
              if (success) {
                debugPrint("yes");
                Navigator.of(context, rootNavigator: true).pop(manager);
              } else {
                globalNotify("Game not found");
              }
            }));
  }

  bool _validate(String text) => text.length == 6;

  @override
  Widget build(BuildContext context) {
    return DefaultDialog(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Enter game code", style: TextStyle(fontSize: 30)),
            const SizedBox(height: 16),
            if (defaultTargetPlatform == TargetPlatform.android)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  height: 220,
                  child: ClipRRect(
                    borderRadius: defaultBorderRadius,
                    child: MobileScanner(
                      controller: _scannerController,
                      onDetect: (capture) {
                        for (final barcode in capture.barcodes) {
                          if (barcode.rawValue != null) {
                            final match = RegExp(r'^ttt-(\d{6})$')
                                .firstMatch(barcode.rawValue!);
                            final digits = match?.group(1);
                            if (digits != null) {
                              _controller.text = digits;
                              onSubmit();
                            }
                          }
                        }
                      },
                      placeholderBuilder: (context, _) =>
                          const Center(child: Icon(Icons.camera_alt_rounded)),
                    ),
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Code",
                      alignLabelWithHint: true,
                    ),
                    textAlign: TextAlign.center,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      if (_validate(value)) {
                        setState(() => _enabled = true);
                      } else {
                        setState(() => _enabled = false);
                      }
                    },
                    onFieldSubmitted: (value) {
                      if (_validate(value)) {
                        onSubmit();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 4),
                IconButton.filled(
                  onPressed: _enabled ? onSubmit : null,
                  icon: AnimatedSwitcher(
                    duration: 400.ms,
                    child: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              "Ask your friend to press 'Create game' and share the game code with you.",
              style: TextStyle(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            )
          ],
        ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scannerController.dispose();
    super.dispose();
  }
}

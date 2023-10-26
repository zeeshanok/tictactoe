import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tictactoe/common/widgets/choose_side.dart';
import 'package:tictactoe/common/widgets/copyable_text.dart';
import 'package:tictactoe/common/widgets/default_dialog.dart';
import 'package:tictactoe/common/widgets/loading.dart';
import 'package:tictactoe/managers/multiplayer_game.dart';
import 'package:tictactoe/services/multiplayer_service.dart';

class CreateGameDialog extends StatefulWidget {
  const CreateGameDialog({super.key});

  @override
  State<CreateGameDialog> createState() => _CreateGameDialogState();
}

class _CreateGameDialogState extends State<CreateGameDialog> {
  Future<MultiplayerGameManager?>? _future;

  final _controller = PageController();

  Future<void> _next() {
    return _controller.nextPage(duration: 300.ms, curve: Curves.easeInOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultDialog(
      height: 400,
      width: 500,
      child: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        allowImplicitScrolling: false,
        children: [
          Center(
            child: ChooseSide(
              onChoose: (p) async {
                await _next();
                setState(() {
                  _future = context.read<MultiplayerService>().createGame(p);
                });
              },
            ),
          ),
          Center(
            child: FutureBuilder(
              future: _future,
              builder: (context, snapshot) => AnimatedSwitcher(
                duration: 200.ms,
                child: snapshot.hasData
                    ? ShowGameCode(gameManager: snapshot.data!)
                    : const LoadingWidget(),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ShowGameCode extends StatefulWidget {
  const ShowGameCode({super.key, required this.gameManager});

  final MultiplayerGameManager gameManager;

  @override
  State<ShowGameCode> createState() => _ShowGameCodeState();
}

class _ShowGameCodeState extends State<ShowGameCode> {
  void _onGameManagerChange() {
    if (widget.gameManager.hasGameStarted) {
      Navigator.of(context, rootNavigator: true).pop(widget.gameManager);
    }
  }

  @override
  void initState() {
    super.initState();
    widget.gameManager.addListener(_onGameManagerChange);
  }

  @override
  Widget build(BuildContext context) {
    final gameCode = widget.gameManager.gameCode.toString();

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Waiting for opponent...',
          style: TextStyle(fontSize: 26),
        ),
        const SizedBox(height: 12),
        const Center(
          child: LoadingWidget(width: 200),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: QrImageView(
              data: 'ttt-$gameCode',
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              dataModuleStyle: QrDataModuleStyle(
                color: Theme.of(context).colorScheme.onBackground,
                dataModuleShape: QrDataModuleShape.square,
              ),
            ),
          ),
        ),
        CopyableText(
          gameCode,
          style: const TextStyle(fontSize: 40),
        ),
        const SizedBox(height: 4),
        const Text(
          "Give this code to your friend and ask them to click `Join Game`",
          style: TextStyle(fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  @override
  void dispose() {
    widget.gameManager.removeListener(_onGameManagerChange);
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/common/responsive_builder.dart';
import 'package:tictactoe/common/widgets/choose_side.dart';
import 'package:tictactoe/common/widgets/labelled_outlined_button.dart';
import 'package:tictactoe/common/widgets/loading.dart';
import 'package:tictactoe/services/multiplayer_service.dart';

class JoinOrCreateGame extends StatelessWidget {
  const JoinOrCreateGame({super.key, required this.onCreate});

  final void Function() onCreate;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LabeledOutlinedButton(
          label: "Join game",
          icon: Icons.language_rounded,
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        LabeledOutlinedButton(
          label: "Create game",
          icon: Icons.add_rounded,
          onPressed: onCreate,
        ),
      ],
    );
  }
}

class CreateGameDialog extends StatefulWidget {
  const CreateGameDialog({super.key});

  @override
  State<CreateGameDialog> createState() => _CreateGameDialogState();
}

class _CreateGameDialogState extends State<CreateGameDialog> {
  Future? _future;

  final _controller = PageController();

  Future<void> _next() {
    return _controller.nextPage(duration: 300.ms, curve: Curves.easeInOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: 300,
        width: 500,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: PageView(
            controller: _controller,
            children: [
              Center(
                child: ChooseSide(
                  onChoose: (p) async {
                    await _next();
                    setState(() {
                      _future =
                          context.read<MultiplayerService>().createGame(p);
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
                        ? ShowGameCode(code: snapshot.data.toString())
                        : const LoadingWidget(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ShowGameCode extends StatelessWidget {
  const ShowGameCode({super.key, required this.code});

  final String code;

  Widget buildMobileLayout(BuildContext context) => Container();
  Widget buildDesktopLayout(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Waiting for opponent...',
            style: TextStyle(fontSize: 26),
          ),
          const Spacer(),
          const Center(
            child: LoadingWidget(),
          ),
          const Spacer(),
          Text(
            code,
            style: const TextStyle(fontSize: 40),
          ),
          const Text(
            "Give this code to your friend and ask them to click `Join Game`",
            style: TextStyle(fontStyle: FontStyle.italic),
          )
        ],
      );

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
        mobileBuilder: buildMobileLayout, desktopBuilder: buildDesktopLayout);
  }
}

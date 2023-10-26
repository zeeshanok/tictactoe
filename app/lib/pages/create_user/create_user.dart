import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:tictactoe/common/debouncer.dart';
import 'package:tictactoe/common/responsive_builder.dart';
import 'package:tictactoe/common/widgets/circular_network_image.dart';
import 'package:tictactoe/models/user.dart';
import 'package:tictactoe/services/user_service.dart';

class CreateUser extends StatelessWidget {
  const CreateUser({super.key});

  Widget buildDesktopLayout(BuildContext context, User user) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (user.profileUrl != null)
            Padding(
              padding: const EdgeInsets.only(right: 30),
              child: CircularNetworkImage(
                imageUrl: user.profileUrl!,
                radius: 50,
              ),
            ),
          const SizedBox(
            width: 500,
            child: CreateUserForm(),
          )
        ],
      );

  Widget buildMobileLayout(BuildContext context, User user) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularNetworkImage(
              imageUrl: user.profileUrl,
              radius: 50,
            ),
            const SizedBox(height: 14),
            const CreateUserForm(),
          ],
        ),
      );
  @override
  Widget build(BuildContext context) {
    final user = context.read<UserService>().currentUser!;

    return Scaffold(
      body: Center(
        child: ResponsiveBuilder(
          desktopBuilder: (context) => buildDesktopLayout(context, user),
          mobileBuilder: (context) => buildMobileLayout(context, user),
        ),
      ),
    );
  }
}

class CreateUserForm extends StatefulWidget {
  const CreateUserForm({
    super.key,
    this.onSuccess,
    this.bio,
    this.username,
  });

  final void Function()? onSuccess;
  final String? bio, username;
  @override
  State<CreateUserForm> createState() => _CreateUserFormState();
}

class _CreateUserFormState extends State<CreateUserForm> {
  final _formKey = GlobalKey<FormState>();
  late final _usernameController = TextEditingController(text: widget.username);
  late final _bioController = TextEditingController(text: widget.bio);

  bool _isUsernameLoading = false;
  bool _isSubmitLoading = false;
  String? _existingUsername;

  late final debounceUsernameExists =
      getDeboucer<String>(const Duration(seconds: 1), (username) async {
    if (username.isNotEmpty) {
      final exists =
          await GetIt.instance<UserService>().doesUsernameExist(username);
      _existingUsername = exists ? username : null;
      _formKey.currentState!.validate();
    }
    setState(() {
      _isUsernameLoading = false;
    });
  });

  void onSubmit() {
    setState(() => _isSubmitLoading = true);
    GetIt.instance<UserService>()
        .updateCurrentUserInfo(
      username: _usernameController.text,
      bio: _bioController.text,
    )
        .then((result) {
      setState(() => _isSubmitLoading = false);
      if (result == null) {
        widget.onSuccess?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: "Username",
              labelStyle: const TextStyle(fontSize: 30),
              suffixIcon: _isUsernameLoading
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox.square(
                        dimension: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : null,
            ),
            style: const TextStyle(fontSize: 30),
            cursorOpacityAnimates: true,
            validator: (value) {
              if (value == widget.username) return null;
              if (value?.isEmpty ?? false) {
                return 'Username must not be empty';
              }
              if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(value!)) {
                return 'Username must have only letters and numbers';
              }
              if (value == _existingUsername) {
                return 'This username is taken';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                if (_formKey.currentState!.validate()) {
                  _isUsernameLoading = true;
                  debounceUsernameExists(value);
                }
              });
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _bioController,
            decoration: const InputDecoration(
              labelText: 'Bio',
            ),
            maxLines: 10,
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: _isSubmitLoading ||
                    _isUsernameLoading ||
                    !(_formKey.currentState?.validate() ?? false)
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      onSubmit();
                    }
                  },
            child: SizedBox(
              height: 20,
              child: _isSubmitLoading
                  ? const SizedBox(
                      width: 20,
                      child: CircularProgressIndicator(),
                    )
                  : const Text("Continue"),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}

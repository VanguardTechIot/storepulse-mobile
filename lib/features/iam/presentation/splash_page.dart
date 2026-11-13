import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'session_view_model.dart';
import 'widgets/iam_header.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    context.read<SessionViewModel>().restore();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IamHeader(
                  title: 'StorePulse Mobile',
                  subtitle: 'Verificando tu sesión...',
                ),
                SizedBox(height: 32),
                CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

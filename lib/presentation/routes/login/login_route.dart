import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tutor_app/blocs/config/config_bloc.dart';
import 'package:tutor_app/blocs/login/login_bloc.dart';

class LoginRoute extends StatelessWidget {
  const LoginRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(),
      child: BlocListener<LoginBloc, LoginState>(
        listenWhen: (previous, current) =>
            previous.error != current.error && current.error != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Something went wrong: ${state.error}'),
              duration: const Duration(seconds: 10),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () {},
              ),
            ),
          );
        },
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      "assets/background/nuu.jpg"), // <-- BACKGROUND IMAGE
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black45, // Adjust transparency and color
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.sizeOf(context).height * 0.15),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.15,
                          child: Image.asset('assets/icons/tutor.png'),
                        ),
                        // Title directly above the box
                        Text(
                          'NUU Tutoring Services',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: context.read<ConfigBloc>().state.theme ==
                                    'light'
                                ? Colors.amber[600]
                                : Colors.white,
                          ),
                        ),

                        const SizedBox(
                            height:
                                12), // Minimal spacing between title and box

                        // Box with login options and elevated shadow
                        Container(
                            width: MediaQuery.sizeOf(context).width *
                                0.6, // 60% of screen width

                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: context.read<ConfigBloc>().state.theme ==
                                      'light'
                                  ? Colors.amber[100]
                                  : Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 12,
                                  offset: const Offset(
                                      0, 6), // Subtle shadow offset
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Sign in to continue',
                                  style: TextStyle(
                                    color: Colors.amber[500],
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Builder(
                                  builder: (context) {
                                    return SizedBox(
                                      width: MediaQuery.sizeOf(context).width *
                                          0.3,
                                      height: 60,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          side: BorderSide(
                                            color: Colors.grey.shade300,
                                            width: 2,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          elevation: 2,
                                        ),
                                        onPressed: () {
                                          context
                                              .read<LoginBloc>()
                                              .add(LoginGoogleLoggedIn());
                                        },
                                        icon: Image.asset(
                                            'assets/icons/google_icon.png'),
                                        label: const Text(
                                          'Sign in with Google',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width * 0.4,
                                  child: const Divider(),
                                ),
                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width * 0.3,
                                  height: 60,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 2,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 2,
                                    ),
                                    onPressed: () {},
                                    icon:
                                        Image.asset('assets/icons/github.png'),
                                    label: const Text(
                                      'Sign in with Github',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width * 0.4,
                                  child: const Divider(),
                                ),
                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width * 0.3,
                                  height: 60,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 2,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 2,
                                    ),
                                    onPressed: () {},
                                    icon: Image.asset('assets/icons/apple.png'),
                                    label: const Text(
                                      'Sign in with Apple',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
              ),
              floatingActionButton: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      '[Privacy Policy]',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      '[Contact us]',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                  const Text(
                    'v0.2.0',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

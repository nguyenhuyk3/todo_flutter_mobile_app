import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:todo_flutter_mobile_app/features/todo/presentations/pages/add_todo_screen.dart';

import 'core/constants/keys.dart';
import 'features/authentication/data/datasources/authentication_remote_data_source.dart';
import 'features/authentication/data/repositories/authentication_service.dart';
import 'features/authentication/domain/repositories/authentication.dart';
import 'features/authentication/domain/usecases/authentication_use_case.dart';
import 'features/authentication/presentations/forgot_password/bloc/bloc.dart';
import 'features/authentication/presentations/login/bloc/bloc.dart';
import 'features/authentication/presentations/registration/bloc/bloc.dart';

/* 
  Trong Flutter, MaterialApp là widget gốc (root widget) dùng để cấu hình toàn bộ ứng dụng theo Material Design.
  Nếu ví Scaffold là khung của một màn hình, thì MaterialApp là khung của cả ứng dụng.
*/
Future<void> main() async {
  // Nó đảm bảo Flutter đã sẵn sàng trước khi chạy code bất đồng bộ hoặc dùng plugin.
  WidgetsFlutterBinding.ensureInitialized();
  // Tải file .env
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env[SUPABASE_URL]!,
    anonKey: dotenv.env[SUPABASE_ANON_KEY]!,
  );

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final IAuthenticationRepository _authenticationRepository;

  @override
  void initState() {
    super.initState();

    final authenticationRemoteDataSource = AuthenticationRemoteDataSource(
      supabaseClient: Supabase.instance.client,
    );

    _authenticationRepository = AuthenticationService(
      authenticationRemoteDataSource: authenticationRemoteDataSource,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [RepositoryProvider.value(value: _authenticationRepository)],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (_) => RegistrationBloc(
                  registerUseCase: RegisterUseCase(
                    authenticationRepository: _authenticationRepository,
                  ),
                  resendOTPUseCase: ResendOTPUseCase(
                    authenticationRepository: _authenticationRepository,
                  ),
                  verifyOTPUseCase: VerifyOTPUseCase(
                    authenticationRepository: _authenticationRepository,
                  ),
                ),
          ),
          BlocProvider(
            create:
                (_) => ForgotPasswordBloc(
                  checkEmailExistsUseCase: CheckEmailExistsUseCase(
                    authenticationRepository: _authenticationRepository,
                  ),
                  sendForgotPasswordOTPUseCase: SendForgotPasswordOTPUseCase(
                    authenticationRepository: _authenticationRepository,
                  ),
                  resendOTPUseCase: ResendOTPUseCase(
                    authenticationRepository: _authenticationRepository,
                  ),
                  verifyOTPUseCase: VerifyOTPUseCase(
                    authenticationRepository: _authenticationRepository,
                  ),
                  updatePasswordUseCase: UpdatePasswordUseCase(
                    authenticationRepository: _authenticationRepository,
                  ),
                ),
          ),
          BlocProvider(
            create:
                (_) => LoginBloc(
                  loginUseCase: LoginUseCase(
                    authenticationRepository: _authenticationRepository,
                  ),
                ),
          ),
        ],
        child: MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              surfaceTintColor: Colors.transparent,
              scrolledUnderElevation: 0,
            ),
          ),
          home: AddTodoPage(),
        ),
      ),
    );
  }
}

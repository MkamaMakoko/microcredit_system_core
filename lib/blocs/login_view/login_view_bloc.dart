import 'package:bloc/bloc.dart';
import 'package:email_validator/email_validator.dart';
import 'package:meta/meta.dart';
import 'package:microcredit_system_core/blocs/auth/auth_bloc.dart';
import 'package:microcredit_system_core/functions/phone_number_validator.dart';
import 'package:microcredit_system_core/functions/password_validator.dart' as f;

part 'login_view_event.dart';
part 'login_view_state.dart';

class LoginViewBloc extends Bloc<LoginViewEvent, LoginViewState> {
  final AuthBloc _authBloc;
  LoginViewBloc(this._authBloc) : super(const InitialState()) {
    _authBloc.stream.listen((authState) => add(_AuthEvent()));
    on<_AuthEvent>((event, emit) => _onAuthEvent(emit));
    on<ChangePasswordVisibility>(
        (event, emit) => emit(PasswordVisibilityUpdated(state)));
    on<WritePassword>(
        (event, emit) => emit(PasswordUpdated(state, event.password)));
    on<WriteContactCredential>((event, emit) =>
        emit(ContactCredentialUpdated(state, event.contactCredential)));
    on<LoginAttempt>((event, emit) => _onLoginAttempt(emit));
  }

  void _onLoginAttempt(Emitter<LoginViewState> emit) {
    if (state.canLogin) {
      _authBloc.add(state.isEmailAddress
          ? EmailSignInEvent(state.contactCredential, state.password)
          : PhoneSignInEvent(state.contactCredential));
    } else {
      emit(InvalidCredentials(state));
    }
  }

  void _onAuthEvent(Emitter<LoginViewState> emit) {
    final authState = _authBloc.state;
    if (authState is SigningIn) {
      emit(LoggingIn(state));
    } else if (authState is AuthError) {
      emit(LoginError(state, authState.error));
    } else if (authState is UserAvailable) {
      emit(LoggedIn(state));
    }
  }
}

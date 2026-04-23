class AuthActionResult {
  final bool isSuccess;
  final String message;
  final bool requiresEmailConfirmation;
  final bool launchedExternalFlow;

  const AuthActionResult._({
    required this.isSuccess,
    required this.message,
    this.requiresEmailConfirmation = false,
    this.launchedExternalFlow = false,
  });

  const AuthActionResult.success(
    String message, {
    bool requiresEmailConfirmation = false,
    bool launchedExternalFlow = false,
  }) : this._(
          isSuccess: true,
          message: message,
          requiresEmailConfirmation: requiresEmailConfirmation,
          launchedExternalFlow: launchedExternalFlow,
        );

  const AuthActionResult.failure(String message)
      : this._(
          isSuccess: false,
          message: message,
        );
}

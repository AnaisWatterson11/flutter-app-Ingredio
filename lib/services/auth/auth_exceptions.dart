//login exceptions
class InvalidCredentialException implements Exception {}

//register exceptions
class WeakPasswordException implements Exception {}
class EmailAlreadyInUseException implements Exception {}
class InvalidEmailException implements Exception {}

//generic exceptions
class GenericAuthException implements Exception {}
class UserNotLoggedInAuthException implements Exception {}



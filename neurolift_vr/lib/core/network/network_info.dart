/// Abstraction for checking network connectivity.
///
/// In production, integrate with the `connectivity_plus` package.
/// Currently defaults to `true` for development purposes.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // TODO: Integrate connectivity_plus for production
    return true;
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Fakes a server response for the [HttpTestClient].
typedef RequestCallback = FutureOr<HttpTestResponse> Function(
    HttpClientRequest, HttpTestClient);

/// A callback to simulate authentication.
///
/// See [HttpClient.authenticate].
///
/// This is not invoked automatically be the test client if set, but
/// it can be accessed in the [RequestCallback] method.
typedef AuthenticateCallback = Future<bool> Function(Uri, String, String);

/// A callback to simulate proxy authentication.
///
/// See [HttpClient.authenticateProxy].
///
/// This is not invoked automatically be the test client if set, but
/// it can be accessed in the [RequestCallback] method.
typedef AuthenticateProxyCallback = Future<bool> Function(
    String, int, String, String);

/// A callback to simulate a bad certificate.
///
/// See [HttpClient.badCertificateCallback].
///
/// This is not invoked automatically be the test client if set, but
/// it can be accessed in the [RequestCallback] method.
typedef BadCertificateCallback = Function(X509Certificate, String, int);

/// Callback which can be invoked to resolve a proxy [Uri].
///
/// See [HttpClient.findProxy].
///
/// This is not invoked automatically be the test client if set, but
/// it can be accessed in the [RequestCallback] method.
typedef FindProxyCallback = String Function(Uri);

/// A fake [HttpClient] for testing Flutter or Dart VM applications.
///
/// Using [HttpOverrides.global] and an [HttpTestClient], you can test code which
/// uses [new HttpClient()] without dependency injection. All you need to do
/// is create a new test client and specify how you want it to respond using a
/// [RequestCallback].
///
/// Currently the test client only supports the following HTTP methods:
///
///   * [getUrl]
///   * [postUrl]
///   * [headUrl]
///   * [patchUrl]
///   * [deleteUrl]
///   * [openUrl]
///   * [patchUrl]
///
/// Any of the non *Url methods will throw.  The other members from the
/// http client can be read in the [RequestCallback] but won't be used
/// otherwise. Currently [close], [addCredentials] and [addProxyCredentials]
/// do nothing.
///
/// The following example forces all HTTP requests to return a
/// successful empty response.
///
///     class MyHttpOverrides extends HttpOverrides {
///       HttpClient() createClient(_) {
///         return new HttpTestClient((HttpRequest request, HttpTestClient client) {
///           return new HttpTestResponse();
///         });
///       }
///     }
///
///     void main() {
///       // overrides all HttpClients.
///       HttpOverrides.global = new MyHttpOverrides();
///
///       group('Widget tests', () {
///         test('returns 200', () async {
///            // this is actually an instance of [HttpTestClient].
///            final client = new HttpClient();
///            final request = client.getUrl(new Uri.https('google.com'));
///            final response = await request.close();
///
///            expect(response.statusCode, HttpStatus.OK);
///         });
///       });
///     }
///
/// If you don't want to override all HttpClients, you can also use
/// [HttpOverrides.runZoned].  Anything which executes in the provided callback
/// will use the provided http client.
///
/// See also:
///
///   * [HttpClient]
///   * [HttpTestResponse]
///   * [HttpOverrides]
class HttpTestClient implements HttpClient {
  HttpTestClient(this._requestCallback);

  final RequestCallback _requestCallback;

  @override
  bool autoUncompress;

  @override
  Duration idleTimeout;

  @override
  int maxConnectionsPerHost;

  @override
  String userAgent;

  @override
  void addCredentials(
      Uri url, String realm, HttpClientCredentials credentials) {}

  @override
  void addProxyCredentials(
      String host, int port, String realm, HttpClientCredentials credentials) {}

  @override
  AuthenticateCallback authenticate;

  @override
  AuthenticateProxyCallback authenticateProxy;

  @override
  FindProxyCallback findProxy;

  @override
  BadCertificateCallback badCertificateCallback;

  @override
  void close({bool force: false}) {}

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) {
    throw new UnsupportedError('');
  }

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) {
    final HttpClientRequest response = new HttpTestClientRequest._(
      this,
      'DELETE',
      url,
      new HttpTestHeaders.__(<String, List<String>>{}),
    );
    return new Future.value(response);
  }

  @override
  Future<HttpClientRequest> get(String host, int port, String path) {
    throw new UnsupportedError('');
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) {
    final HttpClientRequest response = new HttpTestClientRequest._(
      this,
      'GET',
      url,
      new HttpTestHeaders.__(<String, List<String>>{}),
    );
    return new Future.value(response);
  }

  @override
  Future<HttpClientRequest> head(String host, int port, String path) {
    throw new UnsupportedError('');
  }

  @override
  Future<HttpClientRequest> headUrl(Uri url) {
    final HttpClientRequest response = new HttpTestClientRequest._(
      this,
      'HEAD',
      url,
      new HttpTestHeaders.__(<String, List<String>>{}),
    );
    return new Future.value(response);
  }

  @override
  Future<HttpClientRequest> open(
      String method, String host, int port, String path) {
    throw new UnsupportedError('');
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) {
    final HttpClientRequest response = new HttpTestClientRequest._(
      this,
      method.toUpperCase(),
      url,
      new HttpTestHeaders.__(<String, List<String>>{}),
    );
    return new Future.value(response);
  }

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) {
    throw new UnsupportedError('');
  }

  @override
  Future<HttpClientRequest> patchUrl(Uri url) {
    final HttpClientRequest response = new HttpTestClientRequest._(
      this,
      'PATCH',
      url,
      new HttpTestHeaders.__(<String, List<String>>{}),
    );
    return new Future.value(response);
  }

  @override
  Future<HttpClientRequest> post(String host, int port, String path) {
    throw new UnsupportedError('');
  }

  @override
  Future<HttpClientRequest> postUrl(Uri url) {
    final HttpClientRequest response = new HttpTestClientRequest._(
      this,
      'POST',
      url,
      new HttpTestHeaders.__(<String, List<String>>{}),
    );
    return new Future.value(response);
  }

  @override
  Future<HttpClientRequest> put(String host, int port, String path) {
    throw new UnsupportedError('');
  }

  @override
  Future<HttpClientRequest> putUrl(Uri url) {
    final HttpClientRequest response = new HttpTestClientRequest._(
      this,
      'PUT',
      url,
      new HttpTestHeaders.__(<String, List<String>>{}),
    );
    return new Future.value(response);
  }

  @override
  Duration connectionTimeout;
}

/// A fake [HttpClientResponse] to return in a [RequestCallback].
///
/// A test response can be created with [new HttpTestResponse()]. This allows
/// you to specify the body, [statusCode], and [headers].
/// Other properties of a [HttpClientResponse] are faked are not currently
/// customizable:
///   * [contentLength] is calculated based on the provided body size.
///   * [redirects] and [cookies] are always the empty list.
///   * [reasonPhrase], [certificate], and [connectionInfo] are always `null`.
///   * [isRedirect] and [persistentConnection] are always false.
///
/// The methods [redirect] and [detachSocket] throw an [UnsupportedError] if
/// called.
///
/// See also:
///
///   * [HttpTestClient]
///   * [HttpClient]
class HttpTestResponse extends Stream<List<int>> implements HttpClientResponse {
  /// Creates a new test response.
  ///
  /// The response [body] can be either a `String`, which will be utf8 encoded,
  /// or a `List<int>` - including `Uint8List` and other typed data objects.
  /// It defaults to the empty string, and will never be `null`;
  ///
  /// The [statusCode] defaults to [HttpStatus.OK].
  ///
  /// [headers] are empty by default.  Multiple header values can be passed
  /// in a comma-separated string.
  factory HttpTestResponse({
    dynamic body,
    int statusCode = HttpStatus.OK,
    Map<String, String> headers = const <String, String>{},
  }) {
    body ??= '';
    assert(body is String || body is List<int>);
    List<int> codeUnits;
    if (body is String) {
      codeUnits = utf8.encode(body);
    } else {
      codeUnits = body as List<int>;
    }
    final HttpHeaders testHeaders = new HttpTestHeaders._(headers);
    return new HttpTestResponse._(codeUnits, statusCode, testHeaders);
  }

  HttpTestResponse._(
    this._body,
    this._statusCode,
    this._headers,
  );

  final List<int> _body;
  final int _statusCode;
  final HttpHeaders _headers;

  @override
  final List<RedirectInfo> redirects = <RedirectInfo>[];

  @override
  final List<Cookie> cookies = <Cookie>[];

  @override
  int get statusCode => _statusCode;

  @override
  X509Certificate get certificate => null;

  @override
  HttpConnectionInfo get connectionInfo => null;

  @override
  int get contentLength => _body?.length ?? -1;

  @override
  Future<Socket> detachSocket() {
    throw new UnsupportedError('');
  }

  @override
  HttpHeaders get headers => _headers;

  @override
  bool get isRedirect => false;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event) onData,
      {Function onError, void Function() onDone, bool cancelOnError}) {
    return new Stream<List<int>>.fromIterable(
        <List<int>>[_body ?? const <int>[]]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  bool get persistentConnection => false;

  @override
  String get reasonPhrase => null;

  @override
  Future<HttpClientResponse> redirect(
      [String method, Uri url, bool followLoops]) {
    throw new UnsupportedError('');
  }
}

/// A fake implementation of [HttpClientRequest].
///
/// It is not necessary to use this class directly. Instead, code should be
/// written as if it is dealing with a regular [HttpHeaders].
///
/// See also:
///
///   * [HttpClientRequest]
class HttpTestClientRequest extends HttpClientRequest {
  HttpTestClientRequest._(
    this._testClient,
    this.method,
    this.uri,
    this.headers,
  );

  final HttpTestClient _testClient;
  final List<int> _buffer = <int>[];
  final List<Future<void>> _pendingWrites = <Future<void>>[];
  final Completer<HttpClientResponse> _onDone =
      new Completer<HttpClientResponse>.sync();
  bool _isClosed = false;

  @override
  Encoding encoding = utf8;

  @override
  final String method;

  @override
  final Uri uri;

  @override
  final HttpHeaders headers;

  @override
  final HttpConnectionInfo connectionInfo = null;

  @override
  final List<Cookie> cookies = <Cookie>[];

  @override
  void add(List<int> data) {
    if (_isClosed) {
      throw new StateError('writing to a closed HttpRequest');
    }
    _buffer.addAll(data);
  }

  @override
  void addError(error, [StackTrace stackTrace]) {
    if (_isClosed) {
      throw new StateError('writing to a closed HttpRequest');
    }
  }

  @override
  Future<void> addStream(Stream<List<int>> stream) {
    if (_isClosed) {
      throw new StateError('writing to a closed HttpRequest');
    }
    final Completer<void> completer = new Completer<void>.sync();
    stream.listen(
      (List<int> data) => _buffer.addAll(data),
      onDone: completer.complete,
      cancelOnError: true,
    );
    _pendingWrites.add(completer.future);
    return completer.future;
  }

  @override
  Future<HttpClientResponse> close() async {
    if (_isClosed) {
      throw new StateError('writing to a closed HttpRequest');
    }
    await Future.wait(_pendingWrites);
    _isClosed = true;
    final HttpTestResponse response =
        _testClient._requestCallback(this, _testClient);
    _onDone.complete(response);
    return response;
  }

  @override
  Future<HttpClientResponse> get done => _onDone.future;

  @override
  Future<void> flush() async {
    await Future.wait(_pendingWrites);
    return null;
  }

  @override
  void write(Object obj) {
    if (_isClosed) {
      throw new StateError('writing to a closed HttpRequest');
    }
    final List<int> codeUnits = encoding.encode(obj.toString());
    _buffer.addAll(codeUnits);
  }

  @override
  void writeAll(Iterable<Object> objects, [String separator = '']) {
    for (Object object in objects) {
      write(object);
    }
  }

  @override
  void writeCharCode(int charCode) {
    if (_isClosed) {
      throw new StateError('writing to a closed HttpRequest');
    }
    _buffer.add(charCode);
  }

  @override
  void writeln([Object obj = '']) {
    if (_isClosed) {
      throw new StateError('writing to a closed HttpRequest');
    }
    write(obj);
    write('\n');
  }
}

/// A fake implementation of [HttpHeaders].
///
/// It is not necessary to use this class directly. Instead, code should be
/// written as if it is dealing with a regular [HttpHeaders].
///
/// See also:
///
///   * [HttpHeaders]
class HttpTestHeaders extends HttpHeaders {
  factory HttpTestHeaders._(Map<String, String> headers) {
    final Map<String, List<String>> values = <String, List<String>>{};
    headers.forEach((String key, String value) {
      values[key] = value.split(',').map((value) => value.trim());
    });
    return new HttpTestHeaders.__(values);
  }

  HttpTestHeaders.__(this._headers);

  final Map<String, List<String>> _headers;

  @override
  List<String> operator [](String name) {
    return _headers[name];
  }

  @override
  void add(String name, Object value) {
    _headers.putIfAbsent(name, () => <String>[]).add(value.toString());
  }

  @override
  void clear() {
    _headers.clear();
  }

  @override
  void forEach(void Function(String name, List<String> values) f) {
    _headers.forEach(f);
  }

  @override
  void noFolding(String name) {}

  @override
  void remove(String name, Object value) {
    _headers[name]?.remove(value.toString());
  }

  @override
  void removeAll(String name) {
    _headers.remove(name);
  }

  @override
  void set(String name, Object value) {
    _headers[name] = <String>[value.toString()];
  }

  @override
  String value(String name) {
    final List<String> values = _headers[name];
    if (values == null) {
      return null;
    }
    return values.single;
  }
}

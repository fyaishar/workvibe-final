import 'package:flutter_test/flutter_test.dart';
import 'package:finalworkvibe/services/error/logging_service.dart';

// Define the correct type for our print function replacement
typedef PrintFn = void Function(Object?);
final PrintFn originalPrint = print;

void main() {
  late LoggingService loggingService;

  setUp(() {
    loggingService = LoggingService();
  });

  group('LoggingService', () {
    // Testing logging methods functionality
    group('logging methods', () {
      test('debug method should call log with debug level', () {
        // Using a custom test message to detect in _formatLogEntry output
        final testMessage = 'Test debug message ${DateTime.now().millisecondsSinceEpoch}';
        
        // Capture log output using a listener
        String? capturedOutput;
        void testPrint(Object? message) {
          capturedOutput = message?.toString();
        }
        
        // Inject the print function
        LoggingService.printFn = testPrint;
        
        // Execute the debug method
        loggingService.debug(testMessage);
        
        // Verify output
        expect(capturedOutput, isNotNull);
        expect(capturedOutput!.contains(testMessage), isTrue);
        expect(capturedOutput!.contains('[DEBUG]'), isTrue);
        expect(capturedOutput!.contains('[general]'), isTrue);
        
        // Reset print override
        LoggingService.printFn = print;
      });

      test('info method should call log with info level', () {
        final testMessage = 'Test info message ${DateTime.now().millisecondsSinceEpoch}';
        
        String? capturedOutput;
        void testPrint(Object? message) {
          capturedOutput = message?.toString();
        }
        
        LoggingService.printFn = testPrint;
        loggingService.info(testMessage);
        
        expect(capturedOutput, isNotNull);
        expect(capturedOutput!.contains(testMessage), isTrue);
        expect(capturedOutput!.contains('[INFO]'), isTrue);
        
        LoggingService.printFn = print;
      });
      
      test('warning method should call log with warning level', () {
        final testMessage = 'Test warning message ${DateTime.now().millisecondsSinceEpoch}';
        final testError = Exception('Warning test error');
        
        String? capturedOutput;
        void testPrint(Object? message) {
          capturedOutput = message?.toString();
        }
        
        LoggingService.printFn = testPrint;
        loggingService.warning(
          testMessage, 
          error: testError,
          category: LogCategory.auth,
        );
        
        expect(capturedOutput, isNotNull);
        expect(capturedOutput!.contains(testMessage), isTrue);
        expect(capturedOutput!.contains('[WARNING]'), isTrue);
        expect(capturedOutput!.contains('[auth]'), isTrue);
        expect(capturedOutput!.contains('Warning test error'), isTrue);
        
        LoggingService.printFn = print;
      });
      
      test('error method should call log with error level', () {
        final testMessage = 'Test error message ${DateTime.now().millisecondsSinceEpoch}';
        final testError = Exception('Error test exception');
        final testStackTrace = StackTrace.current;
        
        List<String> capturedOutputs = [];
        void testPrint(Object? message) {
          if (message != null) {
            capturedOutputs.add(message.toString());
          }
        }
        
        LoggingService.printFn = testPrint;
        loggingService.error(
          testMessage,
          error: testError,
          stackTrace: testStackTrace,
          category: LogCategory.database,
        );
        
        expect(capturedOutputs, isNotEmpty);
        expect(capturedOutputs.first.contains(testMessage), isTrue);
        expect(capturedOutputs.first.contains('[ERROR]'), isTrue);
        expect(capturedOutputs.first.contains('[database]'), isTrue);
        
        // Should include stack trace since this is an error
        expect(capturedOutputs.length, 2);
        expect(capturedOutputs[1].contains('STACK TRACE'), isTrue);
        
        LoggingService.printFn = print;
      });
      
      test('fatal method should call log with fatal level', () {
        final testMessage = 'Test fatal message ${DateTime.now().millisecondsSinceEpoch}';
        
        String? capturedOutput;
        void testPrint(Object? message) {
          capturedOutput = message?.toString();
        }
        
        LoggingService.printFn = testPrint;
        loggingService.fatal(testMessage);
        
        expect(capturedOutput, isNotNull);
        expect(capturedOutput!.contains(testMessage), isTrue);
        expect(capturedOutput!.contains('[FATAL]'), isTrue);
        
        LoggingService.printFn = print;
      });
    });
    
    group('specialized logging methods', () {
      test('logSupabaseOperation should format database operations correctly', () {
        final operation = 'insert';
        final table = 'users';
        final id = 'user-123';
        final data = {'name': 'Test User', 'email': 'test@example.com'};
        
        String? capturedOutput;
        void testPrint(Object? message) {
          capturedOutput = message?.toString();
        }
        
        LoggingService.printFn = testPrint;
        loggingService.logSupabaseOperation(
          operation,
          table,
          id: id,
          data: data,
        );
        
        expect(capturedOutput, isNotNull);
        expect(capturedOutput!.contains('Supabase insert on users'), isTrue);
        expect(capturedOutput!.contains('[database]'), isTrue);
        expect(capturedOutput!.contains('operation: insert'), isTrue);
        expect(capturedOutput!.contains('table: users'), isTrue);
        expect(capturedOutput!.contains('id: user-123'), isTrue);
        
        LoggingService.printFn = print;
      });
      
      test('logAuthEvent should format auth events correctly', () {
        final event = 'sign-in';
        final userId = 'user-123';
        final email = 'test@example.com';
        
        String? capturedOutput;
        void testPrint(Object? message) {
          capturedOutput = message?.toString();
        }
        
        LoggingService.printFn = testPrint;
        loggingService.logAuthEvent(
          event,
          userId: userId,
          email: email,
        );
        
        expect(capturedOutput, isNotNull);
        expect(capturedOutput!.contains('Auth event: sign-in'), isTrue);
        expect(capturedOutput!.contains('[auth]'), isTrue);
        expect(capturedOutput!.contains('event: sign-in'), isTrue);
        expect(capturedOutput!.contains('userId: user-123'), isTrue);
        expect(capturedOutput!.contains('email: test@example.com'), isTrue);
        
        LoggingService.printFn = print;
      });
      
      test('logRealtimeEvent should format realtime events correctly', () {
        final event = 'subscription';
        final channel = 'presence';
        final eventType = 'join';
        final payload = {'user': 'user-123'};
        
        String? capturedOutput;
        void testPrint(Object? message) {
          capturedOutput = message?.toString();
        }
        
        LoggingService.printFn = testPrint;
        loggingService.logRealtimeEvent(
          event,
          channel,
          eventType: eventType,
          payload: payload,
        );
        
        expect(capturedOutput, isNotNull);
        expect(capturedOutput!.contains('Realtime event: subscription on presence'), isTrue);
        expect(capturedOutput!.contains('[realtime]'), isTrue);
        expect(capturedOutput!.contains('event: subscription'), isTrue);
        expect(capturedOutput!.contains('channel: presence'), isTrue);
        expect(capturedOutput!.contains('eventType: join'), isTrue);
        
        LoggingService.printFn = print;
      });
    });
    
    group('log formatting', () {
      test('_formatLogEntry should format log entries correctly', () {
        final testMessage = 'Test log message';
        
        String? capturedOutput;
        void testPrint(Object? message) {
          capturedOutput = message?.toString();
        }
        
        LoggingService.printFn = testPrint;
        
        // Add extra data to verify formatting of additional fields
        loggingService.log(
          testMessage,
          level: LogLevel.info,
          category: LogCategory.network,
          error: Exception('Test error'),
          additionalData: {
            'userId': 'user-123',
            'requestUrl': 'https://api.example.com',
          },
        );
        
        expect(capturedOutput, isNotNull);
        expect(capturedOutput!.contains(testMessage), isTrue);
        expect(capturedOutput!.contains('[INFO]'), isTrue);
        expect(capturedOutput!.contains('[network]'), isTrue);
        expect(capturedOutput!.contains('Error: Exception: Test error'), isTrue);
        expect(capturedOutput!.contains('userId: user-123'), isTrue);
        expect(capturedOutput!.contains('requestUrl: https://api.example.com'), isTrue);
        
        LoggingService.printFn = print;
      });
    });
  });
}

// Use this instead of directly referencing print
PrintFn debugPrintThrottled = print; 
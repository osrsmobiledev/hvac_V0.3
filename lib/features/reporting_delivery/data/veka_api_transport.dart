import 'dart:convert';

import '../../../app/localization/veka_dictionary.dart';
import 'veka_api_attempt.dart';

enum VekaMockOutcome { accepted, rejected, technical, uncertain }

typedef VekaApiTransport = Future<VekaApiResponse> Function(
    String requestJson, VekaMockOutcome outcome);

class VekaApiResponse {
  final int statusCode;
  final String body;

  const VekaApiResponse(this.statusCode, this.body);

  /// A successful status alone cannot establish that VEKA accepted a request.
  ({VekaApiStatus status, String? receiptNumber}) classify(
      String requestReference) {
    final data = decodeVekaApiBody(body);
    final receipt = data['meldingsnummer'];
    if (statusCode >= 200 && statusCode < 300) {
      if (receipt is String &&
          receipt.trim().isNotEmpty &&
          (!data.containsKey('externeReferte') ||
              data['externeReferte'] == requestReference)) {
        return (status: VekaApiStatus.accepted, receiptNumber: receipt.trim());
      }
      return (status: VekaApiStatus.uncertain, receiptNumber: null);
    }
    final status = switch (statusCode) {
      400 ||
      422
          when readFieldErrors(data).isNotEmpty &&
              (!data.containsKey('externeReferte') ||
                  data['externeReferte'] == requestReference) =>
        VekaApiStatus.rejected,
      401 ||
      403
          when !data.containsKey('externeReferte') ||
              data['externeReferte'] == requestReference =>
        VekaApiStatus.technical,
      _ => VekaApiStatus.uncertain,
    };
    return (status: status, receiptNumber: null);
  }
}

/// This transport is entirely local, and returns synthetic test evidence.
abstract final class VekaMockTransport {
  static Future<VekaApiResponse> send(
      String requestJson, VekaMockOutcome outcome) async {
    final reference =
        decodeVekaApiBody(requestJson)['externeReferte'] as String;
    return switch (outcome) {
      VekaMockOutcome.accepted => receipt(reference),
      VekaMockOutcome.rejected => VekaApiResponse(
          422,
          jsonEncode({
            'externeReferte': reference,
            'errors': [
              {
                'field': 'gegevensActiviteit.datumActiviteit',
                'detail': VekaDictionary.mockValidationDetail,
              },
            ],
          })),
      VekaMockOutcome.technical => const VekaApiResponse(403, '{}'),
      VekaMockOutcome.uncertain => const VekaApiResponse(504, '{}'),
    };
  }

  static VekaApiResponse receipt(String reference) => VekaApiResponse(
      201,
      jsonEncode({
        'externeReferte': reference,
        'meldingsnummer': 'TEST-$reference',
        'opmerkingen': [VekaDictionary.mockReceiptRemark],
      }));
}

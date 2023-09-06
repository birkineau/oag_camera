import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converts a [DateTime] to and from a [String] with the 'en_US' locale in the
/// format `yyyy-MM-ddTHH:mm:ss.SSS`.
class UtcDateTimeJsonConverter extends JsonConverter<DateTime, String> {
  static final _dateFormat = DateFormat("yyyy-MM-ddTHH:mm:ss.SSS", "en_US");

  const UtcDateTimeJsonConverter();

  @override
  DateTime fromJson(String json) => _dateFormat.parse(json, true);

  @override
  String toJson(DateTime object) => _dateFormat.format(object.toUtc());
}

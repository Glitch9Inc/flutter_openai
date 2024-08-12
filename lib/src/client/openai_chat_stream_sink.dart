import 'dart:async';
import 'dart:convert';

import '../config/openai_strings.dart';

class OpenAIChatStreamLineSplitter
    extends StreamTransformerBase<String, String> {
  const OpenAIChatStreamLineSplitter();

  Stream<String> bind(Stream<String> stream) {
    Stream<String> lineStream = LineSplitter().bind(stream);

    return Stream<String>.eventTransformed(
      lineStream,
      (sink) => _OpenAIChatStreamSink(sink),
    );
  }
}

/// Handling exceptions returned by OpenAI Stream API.
final class _OpenAIChatStreamSink implements EventSink<String> {
  final EventSink<String> _sink;
  final List<String> _carries = [];

  _OpenAIChatStreamSink(this._sink);

  void add(String str) {
    final isStartOfResponse = str.startsWith(OpenAIStrings.streamResponseStart);
    final isEndOfResponse = str.contains(OpenAIStrings.streamResponseEnd);
    final isDataResponseBoundaries = isStartOfResponse || isEndOfResponse;

    if (isDataResponseBoundaries) {
      addCarryIfNeeded();

      _sink.add(str);
    } else {
      _carries.add(str);
    }
  }

  void addError(Object error, [StackTrace? stackTrace]) {
    _sink.addError(error, stackTrace);
  }

  void addSlice(String str, int start, int end, bool isLast) {
    if (start == 0 && end == str.length) {
      add(str);
    } else {
      add(str.substring(start, end));
    }

    if (isLast) close();
  }

  void addCarryIfNeeded() {
    if (_carries.isNotEmpty) {
      _sink.add(_carries.join());

      _carries.clear();
    }
  }

  void close() {
    addCarryIfNeeded();
    _sink.close();
  }
}

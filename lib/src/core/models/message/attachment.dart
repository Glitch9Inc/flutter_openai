import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/core/utils/map_setter.dart';

class Attachment {
  final String? fileId;
  final List<ToolBase>? tools;
  const Attachment({this.fileId, this.tools});
  factory Attachment.fromMap(Map<String, dynamic> map) {
    return Attachment(
      fileId: map["file_id"],
      tools: MapSetter.setList(
        map,
        'tools',
        factory: (p0) => ToolBase.fromMap(p0),
      ),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      if (fileId != null) "file_id": fileId,
      if (tools != null) "tools": tools?.map((p0) => p0.toMap()).toList(),
    };
  }
}

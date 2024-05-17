import 'package:flutter_openai/flutter_openai.dart';
import 'package:flutter_openai/src/core/utils/convert_utils.dart';

class Attachment {
  final String? fileId;
  final List<ToolResources>? tools;
  const Attachment({this.fileId, this.tools});
  factory Attachment.fromMap(Map<String, dynamic> map) {
    return Attachment(
      fileId: map["file_id"],
      tools: ConvertUtils.fromList(map["tools"], (p0) => ToolResources.fromMap(p0)),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      if (fileId != null) "file_id": fileId,
      if (tools != null) "tools": tools?.map((p0) => p0.toMap()).toList(),
    };
  }
}

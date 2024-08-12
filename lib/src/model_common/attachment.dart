import 'package:flutter_openai/flutter_openai.dart';

class Attachment {
  final String fileId;
  final List<ToolCall>? tools;

  const Attachment(this.fileId, {this.tools});

  factory Attachment.create(AttachmentFile file) {
    if (file.target != null) {
      return Attachment(
        file.fileId,
        tools: [
          ToolCall(type: file.target),
        ],
      );
    } else {
      return Attachment(file.fileId);
    }
  }

  factory Attachment.fromMap(Map<String, dynamic> map) {
    return Attachment(
      map["file_id"],
      tools: MapSetter.setList(
        map,
        'tools',
        factory: (p0) => ToolCall.fromMap(p0),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "file_id": fileId,
      if (tools != null) "tools": tools?.map((p0) => p0.toMap()).toList(),
    };
  }
}

// little helper part 2.
class AttachmentFile {
  final String fileId;
  final ToolType? target;

  const AttachmentFile({required this.fileId, this.target});
}

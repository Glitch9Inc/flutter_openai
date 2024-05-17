import 'package:flutter_openai/flutter_openai.dart';

class FileSearch extends ToolResources {
  final List<String>? vectorStoreIds;
  final List<VectorStore>? vectorStores;
  FileSearch({this.vectorStoreIds, this.vectorStores});
  factory FileSearch.fromMap(Map<String, dynamic> map) {
    return FileSearch(
      vectorStoreIds: map['vector_store_ids'],
      vectorStores: map['vector_stores'].map((item) => VectorStore.fromMap(item)).toList(),
    );
  }
  @override
  Map<String, dynamic> toMap() {
    return {
      'vector_store_ids': vectorStoreIds,
      'vector_stores': vectorStores?.map((item) => item.toMap()).toList(),
    };
  }
}

class VectorStore {
  final List<String>? fileIds;
  final Map<String, String>? metadata;
  const VectorStore({this.fileIds, this.metadata});
  factory VectorStore.fromMap(Map<String, dynamic> map) {
    return VectorStore(fileIds: map['file_ids'], metadata: map['metadata']);
  }
  Map<String, dynamic> toMap() {
    return {
      'file_ids': fileIds,
      'metadata': metadata,
    };
  }
}

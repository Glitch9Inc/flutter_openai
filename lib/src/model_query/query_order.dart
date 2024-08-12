enum QueryOrder {
  descending,
  ascending,
  createdAt,
}

extension QueryOrderExtension on QueryOrder {
  String getName() {
    switch (this) {
      case QueryOrder.descending:
        return "desc";
      case QueryOrder.ascending:
        return "asc";
      case QueryOrder.createdAt:
        return "created_at";
    }
  }
}

/// How long a trashed customer is retained before permanent deletion.
const trashRetention = Duration(days: 30);

/// Whole days remaining before a customer trashed at [deletedAt] is purged,
/// evaluated relative to [now]. Clamped to zero once the cutoff has passed.
int daysUntilPurge(DateTime deletedAt, DateTime now,
    {Duration retention = trashRetention}) {
  final remaining = retention - now.difference(deletedAt);
  return remaining.isNegative ? 0 : remaining.inDays;
}

/// How long a trashed customer is retained before permanent deletion.
const trashRetention = Duration(days: 30);

/// Days remaining before a customer trashed at [deletedAt] is purged,
/// evaluated relative to [now]. Partial days count as a full day (the
/// customer survives into that day), and the result clamps to zero once
/// the cutoff has passed.
int daysUntilPurge(DateTime deletedAt, DateTime now,
    {Duration retention = trashRetention}) {
  final remaining = retention - now.difference(deletedAt);
  if (remaining.isNegative) return 0;
  return (remaining.inMicroseconds / Duration.microsecondsPerDay).ceil();
}

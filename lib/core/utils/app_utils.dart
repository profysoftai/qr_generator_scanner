class AppUtils {
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  static bool isValidUrl(String value) {
    return Uri.tryParse(value)?.hasAbsolutePath ?? false;
  }

  static String truncate(String value, {int max = 30}) {
    return value.length > max ? '${value.substring(0, max)}...' : value;
  }
}

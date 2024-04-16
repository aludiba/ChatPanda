import 'package:intl/intl.dart';

class WechatDateFormat {
  ///millisecondsSinceEpoch:要格式化的日期；dayOnly：是只展示到天
  static String format(int millisecondsSinceEpoch, {bool dayOnly = true}) {
    //当前日期
    DateTime nowDate = DateTime.now();
    //传入的日期 millisecondsSinceEpoch
    DateTime targetDate =
        DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    String prefix = '';
    if (nowDate.year != targetDate.year) {
      prefix = DateFormat('yyyy-MM-dd').format(targetDate);
    } else if (nowDate.month != targetDate.month) {
      prefix = DateFormat('MM-dd').format(targetDate);
    } else if (nowDate.day != targetDate.day) {
      if (nowDate.day - targetDate.day == 1) {
        prefix = 'Yesterday';
      } else {
        prefix = DateFormat('MM-dd').format(targetDate);
      }
    }
    if (prefix.isNotEmpty && dayOnly) {
      return prefix;
    }
    String suffix = DateFormat('HH:mm').format(targetDate);
    return '$prefix $suffix';
  }

  static String formatYMd(int millisecondsSinceEpoch) {
    DateTime targetDate =
        DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    return DateFormat('yyyy/MM/dd HH:mm').format(targetDate);
  }
}

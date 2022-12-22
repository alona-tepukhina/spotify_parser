String strToTime(String value) {
  if (value == '') return '';

  int intValue = int.parse(value);
  int h, m, s;

  h = intValue ~/ 3600;
  m = ((intValue - h * 3600)) ~/ 60;
  s = intValue - (h * 3600) - (m * 60);

  String result = '';

  if (h == 0) {
    result = "$m:$s";

    if (m == 0) {
      result = "$s";
    }
  } else {
    result = "$h:$m:$s";
  }

  return result;
}

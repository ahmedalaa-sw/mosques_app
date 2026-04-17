extension TextLimit on String {
  String limit(int maxChars) {
    return length <= maxChars ? this : "${substring(0, maxChars)}...";
  }
}

// how to use it with 
// add  => "oady ahmed ".limit(20) ) 
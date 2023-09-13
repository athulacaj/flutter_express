void splitMultipart(List<int> data, List<int> startBoundaryBytes,
    List<List<int>> result, int i, List<int> endBoundaryBytes) {
  List<int> tempList = [];
  int i = 0;
  while (i < data.length) {
    if (data[i] == startBoundaryBytes[0] &&
        data[i + 1] == startBoundaryBytes[1]) {
      bool isMatch = true;
      for (int j = 0; j < startBoundaryBytes.length; j++) {
        if (i + j >= data.length || data[i + j] != startBoundaryBytes[j]) {
          isMatch = false;
          tempList.add(data[i]);
          break;
        }
      }
      if (isMatch) {
        if (tempList.isNotEmpty) result.add([...tempList]);
        tempList.clear();
        i = i + startBoundaryBytes.length - 1;
      }
    } else {
      tempList.add(data[i]);
    }
    i++;
  }
  if (tempList.isNotEmpty) {
    result.add(tempList.sublist(0, tempList.length - endBoundaryBytes.length));
  }
}

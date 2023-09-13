void main() {
  mulitpartSplitting();
}

void mulitpartSplitting() {
  List<int> data = [1, 2, 4, 5, 1, 2, 6, 7, 3, 4];
  List<int> startBoundaryBytes = [1, 2];
  List<int> endBoundaryBytes = [];
  List<List<int>> result = [];

  splitMultipart(data, startBoundaryBytes, [], result, 0, endBoundaryBytes);
  print("result $result");
}

void splitMultipart(
    List<int> data,
    List<int> startBoundaryBytes,
    List<int> tempList,
    List<List<int>> result,
    int i,
    List<int> endBoundaryBytes) {
  if (i >= data.length - 1) {
    if (tempList.isNotEmpty) {
      result
          .add(tempList.sublist(0, tempList.length - endBoundaryBytes.length));
    }
    return;
  }
  int newI = i;
  if (data[i] == startBoundaryBytes[0]) {
    bool isMatch = true;
    for (int j = 0; j < startBoundaryBytes.length; j++) {
      if (data[i + j] != startBoundaryBytes[j]) {
        isMatch = false;
        tempList.add(data[i]);
        break;
      }
    }
    if (isMatch) {
      if (tempList.isNotEmpty) result.add([...tempList]);
      tempList.clear();
      newI = i + startBoundaryBytes.length - 1;
    }
  } else {
    tempList.add(data[i]);
  }
  splitMultipart(
      data, startBoundaryBytes, tempList, result, newI + 1, endBoundaryBytes);
}

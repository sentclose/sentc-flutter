PrepareKeysResult prepareKeys(List<GroupKey> keys, int page) {
  final offset = page * 50;
  int end = offset + 50;

  if (end < keys.length) {
    end = keys.length;
  }

  final keySlice = keys.sublist(offset, end);

  String str = "[";

  for (var i = 0; i < keySlice.length; ++i) {
    var key = keySlice[i].groupKey;

    str += "$key,";
  }

  //remove the trailing comma
  str = str.substring(0, str.length - 1);

  str += "]";

  return PrepareKeysResult(str, end < keys.length - 1);
}

class PrepareKeysResult {
  final String str;
  final bool end;

  PrepareKeysResult(this.str, this.end);
}

//______________________________________________________________________________________________________________________

class GroupInviteListItem {
  final String groupId;
  final String time;

  GroupInviteListItem(this.groupId, this.time);
}

class GroupKey {
  final String privateKey;
  final String publicKey;
  final String groupKey;
  final String time;
  final String groupKeyId;

  GroupKey(this.privateKey, this.publicKey, this.groupKey, this.time, this.groupKeyId);
}

import 'dart:io';
import 'dart:typed_data';

import 'package:sentc/sentc.dart';
import 'package:path/path.dart' as p;

/// Gets an available file name to download the file to this location
Future<String> findAvailableFileName(String path) async {
  final baseName = p.basenameWithoutExtension(path);
  final fileExtension = p.extension(path);
  final dirName = p.dirname(path);

  int i = 1;
  String fileName = '$dirName${Platform.pathSeparator}$baseName$fileExtension';
  while (await File(fileName).exists()) {
    fileName = '$dirName${Platform.pathSeparator}$baseName($i)$fileExtension';
    i++;
  }
  return fileName;
}

class FileMetaInformation {
  final String fileId;
  final String masterKeyId;
  final String? belongsTo;
  final BelongsToType belongsToType;
  final String encryptedKey;
  final String encryptedKeyAlg;
  final List<FilePartListItem> partList;
  String? fileName;
  final String? encryptedFileName;

  FileMetaInformation({
    required this.fileId,
    required this.masterKeyId,
    this.belongsTo,
    required this.belongsToType,
    required this.encryptedKey,
    required this.encryptedKeyAlg,
    required this.partList,
    this.fileName,
    this.encryptedFileName,
  });
}

class DownloadResult {
  final FileMetaInformation meta;
  final SymKey key;

  DownloadResult(this.meta, this.key);
}

/// Downloads a file.
/// Append the chunks to a file.
/// This is different to the browser version where the chunks are stored into indexeddb
class Downloader {
  static bool cancelDownload = false;

  final String _baseUrl;
  final String _appToken;

  final User _user;

  final String? _groupId;

  final String? _groupAsMember;

  Downloader(this._baseUrl, this._appToken, this._user, [this._groupId, this._groupAsMember]);

  Future<FileMetaInformation> downloadFileMetaInformation(String fileId) async {
    final jwt = await _user.getJwt();

    final meta = await Sentc.getApi().fileDownloadFileMeta(
      baseUrl: _baseUrl,
      authToken: _appToken,
      jwt: jwt,
      id: fileId,
      groupId: _groupId,
      groupAsMember: _groupAsMember,
    );

    final partList = meta.partList;

    if (partList.length >= 500) {
      //download parts via pagination
      var lastItem = partList[partList.length - 1];
      var nextFetch = true;

      while (nextFetch) {
        final fetchedParts = await downloadFilePartList(fileId, lastItem);

        partList.addAll(fetchedParts);
        nextFetch = fetchedParts.length >= 500;
        lastItem = fetchedParts[fetchedParts.length - 1];
      }
    }

    return FileMetaInformation(
      fileId: meta.fileId,
      masterKeyId: meta.masterKeyId,
      belongsToType: meta.belongsToType,
      encryptedKey: meta.encryptedKey,
      encryptedKeyAlg: meta.encryptedKeyAlg,
      partList: partList,
      belongsTo: meta.belongsTo,
      encryptedFileName: meta.encryptedFileName,
    );
  }

  Future<List<FilePartListItem>> downloadFilePartList(String fileId, FilePartListItem? lastItem) {
    final lastSeq = lastItem?.sequence.toString() ?? "";

    return Sentc.getApi().fileDownloadPartList(
      baseUrl: _baseUrl,
      authToken: _appToken,
      fileId: fileId,
      lastSequence: lastSeq,
    );
  }

  Future<void> downloadFileParts(
    File file,
    List<FilePartListItem> partList,
    String contentKey, [
    void Function(double progress)? updateProgressCb,
    String? verifyKey,
  ]) async {
    final api = Sentc.getApi();

    final urlPrefix = Sentc.filePartUrl;

    Downloader.cancelDownload = false;

    final sink = file.openWrite(mode: FileMode.append);

    String nextFileKey = contentKey;

    for (var i = 0; i < partList.length; ++i) {
      var partListItem = partList[i];

      final external = partListItem.externStorage == true;
      final partUrlBase = (external) ? urlPrefix : null;

      Uint8List part;

      try {
        if (i == 0) {
          final res = await api.fileDownloadAndDecryptFilePartStart(
            baseUrl: _baseUrl,
            urlPrefix: partUrlBase,
            authToken: _appToken,
            partId: partListItem.partId,
            contentKey: contentKey,
            verifyKeyData: verifyKey,
          );

          nextFileKey = res.nextFileKey;
          part = res.file;
        } else {
          final res = await api.fileDownloadAndDecryptFilePart(
            baseUrl: _baseUrl,
            urlPrefix: partUrlBase,
            authToken: _appToken,
            partId: partListItem.partId,
            contentKey: nextFileKey,
            verifyKeyData: verifyKey,
          );

          nextFileKey = res.nextFileKey;
          part = res.file;
        }
      } catch (e) {
        await sink.close();
        await file.delete();

        rethrow;
      }

      if (part.isEmpty) {
        await sink.close();
        await file.delete();

        throw Exception("File not found");
      }

      sink.add(part);

      if (updateProgressCb != null) {
        updateProgressCb((i + 1) / partList.length);
      }

      if (Downloader.cancelDownload) {
        Downloader.cancelDownload = false;

        await sink.close();
        await file.delete();

        return;
      }
    }

    await sink.close();
  }
}

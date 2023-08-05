/// End to end encryption and group access sdk
library sentc;

//main
export 'src/sentc.dart';
export 'src/user.dart';
export 'src/group.dart';
export 'src/generated.dart';
export 'src/crypto/sym_key.dart';
export 'src/either.dart';

//file handling
export 'src/file/uploader.dart';
export 'src/file/downloader.dart';

//storage
export 'src/storage/storage_interface.dart';
export 'src/storage/shared_preferences_storage.dart';

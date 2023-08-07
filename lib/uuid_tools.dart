import 'dart:typed_data';
import 'package:uuid/uuid_util.dart';
import 'package:uuid/uuid.dart';


String generateUuidString(){
  /// Get a conventional uuid as a string. In this app, uuid v4 is used, with
  /// cryptoRNG for cryptographically secure values.
  return const Uuid().v4obj(options: {"rng": UuidUtil.cryptoRNG}).toString();
}

Uint8List generateUuidUint8List(){
  return const Uuid().v4obj(options: {"rng": UuidUtil.cryptoRNG}).toBytes();

}

String uuidStringFromUint8List(Uint8List uuidBytes){
  return UuidValue.fromByteList(uuidBytes).toString();
}

Uint8List uuidBytesListFromString(String uuidString){
  return UuidValue(uuidString).toBytes();
}
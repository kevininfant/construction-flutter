import 'package:encrypt/encrypt.dart' as aesEncrypt;
import 'dart:math';
class AESEncryption {
  final key = aesEncrypt.Key.fromUtf8(generateRandomKey(32)); // Adjusted key length to 32 bytes (256 bits)
  final iv = aesEncrypt.IV.fromLength(16); // Adjusted IV length to 16 bytes (128 bits)

  String encryption(String? plainText) {
    final encrypter = aesEncrypt.Encrypter(aesEncrypt.AES(key));
    return encrypter.encrypt(plainText!, iv: iv).base16;
  }

  String decryption(String encryptedData) {
    final decrypter = aesEncrypt.Encrypter(aesEncrypt.AES(key));
    return decrypter.decrypt16(encryptedData, iv: iv);
  }
}


String generateRandomKey(int length) {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random.secure();
  return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
}

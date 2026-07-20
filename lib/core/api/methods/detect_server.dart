import 'package:get_it/get_it.dart';
import 'package:rdb/common/constant/configuration/cloudinary_url_routes.dart';
import 'package:rdb/common/constant/configuration/kyc_url_routes.dart';
import 'package:rdb/common/constant/configuration/wallet_url_routes.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';

/// `passcode` و `kycStep` يقصدان نفس خادمَي `wallet` و `kyc` على الترتيب،
/// ويختلفان في التوكن فقط: يُستخدمان أثناء تسجيل الدخول (mid-login) حيث لم
/// يصدر access token بعد، فالبطاقة المتاحة هي session stepToken.
enum ServerName { location, cloudinary, wallet, passcode, kyc, kycStep }

//todo make the return value dynamic to return the cloudinary as String
Uri getBaseUriForSpecificServer(ServerName serverName) {
  switch (serverName) {
    case ServerName.wallet:
      return WalletUrls.baseUri;
    case ServerName.passcode:
      return WalletUrls.baseUri;
    case ServerName.location:
      return Uri.parse('https://ipwho.is/');
    case ServerName.cloudinary:
      return CloudinaryUrls.baseUri;
    case ServerName.kyc:
    case ServerName.kycStep:
      return KycUrls.baseUri;
  }
}

String? getServerToken(ServerName serverName) {
  final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  switch (serverName) {
    case ServerName.wallet:
      return prefsRepository.walletToken;
    case ServerName.location:
      return null;
    case ServerName.cloudinary:
      return null;
    case ServerName.passcode:
      return prefsRepository.stepToken;
    case ServerName.kyc:
      // مسارات reverify تقبل Authorization: Bearer (توكن المحفظة).
      return prefsRepository.walletToken;
    case ServerName.kycStep:
      // mid-login: **بلا Bearer عمداً**. دليل تكامل الـ Worker (§1) ينصّ على
      // إرسال session stepToken في ترويسة `X-Step-Token` ويمنع صراحةً وضعه في
      // `Authorization: Bearer`. تُضاف الترويسة في auth_remote_datasource عبر
      // extraHeaders؛ وإرجاع null هنا يمنع BaseApi من كتابة Bearer.
      return null;
  }
}

import 'package:get_it/get_it.dart';
import 'package:rdb/common/constant/configuration/cloudinary_url_routes.dart';
import 'package:rdb/common/constant/configuration/wallet_url_routes.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';

enum ServerName { location, cloudinary, wallet }

//todo make the return value dynamic to return the cloudinary as String
Uri getBaseUriForSpecificServer(ServerName serverName) {
  switch (serverName) {
    case ServerName.wallet:
      return WalletUrls.baseUri;
    case ServerName.location:
      return Uri.parse('https://ipwho.is/');
    case ServerName.cloudinary:
      return CloudinaryUrls.baseUri;
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
  }
}

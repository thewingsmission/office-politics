// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '职场政治';

  @override
  String get appTagline => '预判下一步。在办公室里走动。';

  @override
  String get language => '语言';

  @override
  String get languageEnglish => 'EN';

  @override
  String get languageSimplifiedChinese => '简体';

  @override
  String get languageTraditionalChinese => '繁體';

  @override
  String get arcadeTitle => '街机';

  @override
  String get arcadeBody => '横屏办公室小游戏：拍同事、追回功劳、翻转谣言、躲开五点同步。';

  @override
  String get coachTitle => '教练';

  @override
  String get coachBody => '私密建议、回复推演、情景演练。';

  @override
  String get mapTitle => '办公室地图';

  @override
  String get mapBody => '摆放工位和同事。后续步骤提供。';

  @override
  String get comingNext => '下一步';

  @override
  String get landscapeOnly => '本应用仅支持横屏。';

  @override
  String get authSubtitle => '需要账户。教练数据只属于你。';

  @override
  String get sensitiveWarning => '请勿上传机密或敏感材料。同事请使用化名。';

  @override
  String get email => '邮箱';

  @override
  String get password => '密码';

  @override
  String get signIn => '登录';

  @override
  String get createAccount => '创建账户';

  @override
  String get haveAccount => '已有账户？去登录';

  @override
  String get needAccount => '还没有账户？去创建';

  @override
  String get account => '账户';

  @override
  String get signOut => '退出登录';

  @override
  String get exportAccount => '导出我的数据';

  @override
  String get deleteAccount => '删除账户';

  @override
  String get deleteAccountConfirm => '将永久删除此设备上的账户；若已连接 Supabase，云端记录也会删除。';

  @override
  String get deleteAccountAction => '永久删除';

  @override
  String get cancel => '取消';

  @override
  String get planFree => '免费';

  @override
  String get planPremium => '订阅';

  @override
  String get planContest => '竞赛通行证';

  @override
  String planExpires(String date) {
    return '有效期至 $date';
  }

  @override
  String get premiumUntilForever => '订阅有效';

  @override
  String get paywallTitle => '教练功能需要订阅';

  @override
  String get paywallBody =>
      '街机竞赛保持免费。订阅后可使用教练；也可参加每日、每周、每月竞赛赢取限时通行证。如果更愿意花时间而不是花钱，激励广告会在竞赛里给你公平的机会。';

  @override
  String get subscribe => '订阅';

  @override
  String get subscribeHint => '应用商店扣费稍后接入。现在会发放 30 天通行证，方便后续功能读取真实的权限标记。';

  @override
  String get contestCta => '返回街机';

  @override
  String get exported => '账户导出已复制';

  @override
  String get invalidCredentials => '邮箱或密码不正确。';

  @override
  String get emailTaken => '该邮箱已有账户。';

  @override
  String get weakPassword => '请使用至少 8 个字符。';

  @override
  String get invalidEmail => '请输入有效邮箱。';

  @override
  String get confirmEmail => '请查收邮件以确认账户。';

  @override
  String get genericError => '出了点问题，请重试。';

  @override
  String get coachLocked => '需要订阅';

  @override
  String accountEmail(String email) {
    return '当前登录 $email';
  }

  @override
  String get localAccountNote => '演示账户保存在此设备。连接 Supabase 后可使用云端账户。';

  @override
  String get cloudAccountNote => '云端账户。导出和删除会作用于服务器记录。';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => '職場政治';

  @override
  String get appTagline => '預判下一步。在辦公室裡走動。';

  @override
  String get language => '語言';

  @override
  String get languageEnglish => 'EN';

  @override
  String get languageSimplifiedChinese => '简体';

  @override
  String get languageTraditionalChinese => '繁體';

  @override
  String get arcadeTitle => '街機';

  @override
  String get arcadeBody => '橫屏辦公室小遊戲：拍同事、追回功勞、翻轉謠言、躲開五點同步。';

  @override
  String get coachTitle => '教練';

  @override
  String get coachBody => '私密建議、回覆推演、情境演練。';

  @override
  String get mapTitle => '辦公室地圖';

  @override
  String get mapBody => '擺放工位和同事。後續步驟提供。';

  @override
  String get comingNext => '下一步';

  @override
  String get landscapeOnly => '本應用僅支援橫屏。';

  @override
  String get authSubtitle => '需要帳戶。教練資料只屬於你。';

  @override
  String get sensitiveWarning => '請勿上傳機密或敏感資料。同事請使用化名。';

  @override
  String get email => '電子郵件';

  @override
  String get password => '密碼';

  @override
  String get signIn => '登入';

  @override
  String get createAccount => '建立帳戶';

  @override
  String get haveAccount => '已有帳戶？去登入';

  @override
  String get needAccount => '還沒有帳戶？去建立';

  @override
  String get account => '帳戶';

  @override
  String get signOut => '登出';

  @override
  String get exportAccount => '匯出我的資料';

  @override
  String get deleteAccount => '刪除帳戶';

  @override
  String get deleteAccountConfirm => '將永久刪除此裝置上的帳戶；若已連接 Supabase，雲端紀錄也會刪除。';

  @override
  String get deleteAccountAction => '永久刪除';

  @override
  String get cancel => '取消';

  @override
  String get planFree => '免費';

  @override
  String get planPremium => '訂閱';

  @override
  String get planContest => '競賽通行證';

  @override
  String planExpires(String date) {
    return '有效期至 $date';
  }

  @override
  String get premiumUntilForever => '訂閱有效';

  @override
  String get paywallTitle => '教練功能需要訂閱';

  @override
  String get paywallBody =>
      '街機競賽保持免費。訂閱後可使用教練；也可參加每日、每週、每月競賽贏取限時通行證。如果更願意花時間而不是花錢，激勵廣告會在競賽裡給你公平的機會。';

  @override
  String get subscribe => '訂閱';

  @override
  String get subscribeHint => '應用商店扣款稍後接入。現在會發放 30 天通行證，方便後續功能讀取真實的權限標記。';

  @override
  String get contestCta => '返回街機';

  @override
  String get exported => '帳戶匯出已複製';

  @override
  String get invalidCredentials => '電子郵件或密碼不正確。';

  @override
  String get emailTaken => '該電子郵件已有帳戶。';

  @override
  String get weakPassword => '請使用至少 8 個字元。';

  @override
  String get invalidEmail => '請輸入有效電子郵件。';

  @override
  String get confirmEmail => '請查收郵件以確認帳戶。';

  @override
  String get genericError => '出了點問題，請重試。';

  @override
  String get coachLocked => '需要訂閱';

  @override
  String accountEmail(String email) {
    return '目前登入 $email';
  }

  @override
  String get localAccountNote => '示範帳戶保存在此裝置。連接 Supabase 後可使用雲端帳戶。';

  @override
  String get cloudAccountNote => '雲端帳戶。匯出和刪除會作用於伺服器紀錄。';
}

// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ru';

  static String m0(resendText) => "${resendText}";

  static String m1(seconds) => "Отправлено (${seconds} сек)";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "ForgotenterTheEmailAddressToWhichYouWillReceiveThe":
        MessageLookupByLibrary.simpleMessage(
          "Введите адрес электронной почты, на который вы получите ссылку для сброса пароля.:",
        ),
    "LoginBtnForgotPassword": MessageLookupByLibrary.simpleMessage(
      "Забыли пароль?",
    ),
    "LoginBtnHintLoading": MessageLookupByLibrary.simpleMessage("Загрузка..."),
    "LoginBtnHintSignIn": MessageLookupByLibrary.simpleMessage("Войти"),
    "LoginBtnHintSignUp": MessageLookupByLibrary.simpleMessage(
      "Зарегистрироваться",
    ),
    "LoginHintEmailText": MessageLookupByLibrary.simpleMessage("Почта"),
    "LoginTextDontAccount": MessageLookupByLibrary.simpleMessage(
      "У Вас нет Учетной Записи? ",
    ),
    "LoginWelcomeSubText": MessageLookupByLibrary.simpleMessage(
      "пожалуйста, войдите в свою учетную запись",
    ),
    "LoginWelcomeText": MessageLookupByLibrary.simpleMessage("С возвращением!"),
    "RegBtnHintLoading": MessageLookupByLibrary.simpleMessage("Загрузка..."),
    "RegBtnHintRegister": MessageLookupByLibrary.simpleMessage(
      "Зарегистрироваться",
    ),
    "RegBtnLoginText": MessageLookupByLibrary.simpleMessage("Войти"),
    "RegCreateAcnText": MessageLookupByLibrary.simpleMessage("Создать Аккаунт"),
    "RegHintConfirmPassword": MessageLookupByLibrary.simpleMessage(
      "Подтвердить Пароль",
    ),
    "RegHintEmail": MessageLookupByLibrary.simpleMessage("Почта"),
    "RegHintPassword": MessageLookupByLibrary.simpleMessage("Пароль"),
    "RegTextDoUHaveAccount": MessageLookupByLibrary.simpleMessage(
      "У Вас Есть Учетная Запись? ",
    ),
    "RegisterHintPassCheck": MessageLookupByLibrary.simpleMessage(
      "Пароли не совпадают",
    ),
    "accountPage": MessageLookupByLibrary.simpleMessage("Аккаунт"),
    "appInformation": MessageLookupByLibrary.simpleMessage(
      "ИНФОРМАЦИЯ О ПРИЛОЖЕНИИ",
    ),
    "appVersion": MessageLookupByLibrary.simpleMessage("Версия приложения:"),
    "build": MessageLookupByLibrary.simpleMessage("Сборка:"),
    "checkAgain": MessageLookupByLibrary.simpleMessage("Проверить снова"),
    "confirmMessage": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, подтвердите адрес электронной почты.",
    ),
    "confirmTitle": MessageLookupByLibrary.simpleMessage("Подтверждение"),
    "language": MessageLookupByLibrary.simpleMessage("Язык"),
    "languageSetting": MessageLookupByLibrary.simpleMessage(
      "Языковые настройки",
    ),
    "logOut": MessageLookupByLibrary.simpleMessage("Выйти"),
    "resend": MessageLookupByLibrary.simpleMessage("Отправить повторно"),
    "resendtext": m0,
    "resetPassword": MessageLookupByLibrary.simpleMessage("Сброс пароля"),
    "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "selectLanguage": MessageLookupByLibrary.simpleMessage("ВЫБОР ЯЗЫКА"),
    "sentIn": m1,
    "settingAndTools": MessageLookupByLibrary.simpleMessage(
      "НАСТРОЙКИ И ИНСТРУМЕНТЫ",
    ),
    "successfulExit": MessageLookupByLibrary.simpleMessage("Успешный выход"),
    "theEmailHasBeenSentCheckYourEmail": MessageLookupByLibrary.simpleMessage(
      "Письмо отправлено! Проверьте свой электронный адрес.",
    ),
    "theme": MessageLookupByLibrary.simpleMessage("Тема"),
  };
}

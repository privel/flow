// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Language Settings`
  String get languageSetting {
    return Intl.message(
      'Language Settings',
      name: 'languageSetting',
      desc: '',
      args: [],
    );
  }

  /// `Welcome back!`
  String get LoginWelcomeText {
    return Intl.message(
      'Welcome back!',
      name: 'LoginWelcomeText',
      desc: '',
      args: [],
    );
  }

  /// `please sign in to your account`
  String get LoginWelcomeSubText {
    return Intl.message(
      'please sign in to your account',
      name: 'LoginWelcomeSubText',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get LoginHintEmailText {
    return Intl.message(
      'Email',
      name: 'LoginHintEmailText',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password?`
  String get LoginBtnForgotPassword {
    return Intl.message(
      'Forgot Password?',
      name: 'LoginBtnForgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get LoginBtnHintLoading {
    return Intl.message(
      'Loading...',
      name: 'LoginBtnHintLoading',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get LoginBtnHintSignIn {
    return Intl.message(
      'Sign In',
      name: 'LoginBtnHintSignIn',
      desc: '',
      args: [],
    );
  }

  /// `Don’t Have An Account? `
  String get LoginTextDontAccount {
    return Intl.message(
      'Don’t Have An Account? ',
      name: 'LoginTextDontAccount',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get LoginBtnHintSignUp {
    return Intl.message(
      'Sign Up',
      name: 'LoginBtnHintSignUp',
      desc: '',
      args: [],
    );
  }

  /// `Passwords don't match`
  String get RegisterHintPassCheck {
    return Intl.message(
      'Passwords don\'t match',
      name: 'RegisterHintPassCheck',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get RegCreateAcnText {
    return Intl.message(
      'Create Account',
      name: 'RegCreateAcnText',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get RegHintEmail {
    return Intl.message('Email', name: 'RegHintEmail', desc: '', args: []);
  }

  /// `Password`
  String get RegHintPassword {
    return Intl.message(
      'Password',
      name: 'RegHintPassword',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get RegHintConfirmPassword {
    return Intl.message(
      'Confirm Password',
      name: 'RegHintConfirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get RegBtnHintLoading {
    return Intl.message(
      'Loading...',
      name: 'RegBtnHintLoading',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get RegBtnHintRegister {
    return Intl.message(
      'Register',
      name: 'RegBtnHintRegister',
      desc: '',
      args: [],
    );
  }

  /// `Do You Have An Account? `
  String get RegTextDoUHaveAccount {
    return Intl.message(
      'Do You Have An Account? ',
      name: 'RegTextDoUHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get RegBtnLoginText {
    return Intl.message('Sign In', name: 'RegBtnLoginText', desc: '', args: []);
  }

  /// `Enter the email address to which you will receive the password reset link.:`
  String get ForgotenterTheEmailAddressToWhichYouWillReceiveThe {
    return Intl.message(
      'Enter the email address to which you will receive the password reset link.:',
      name: 'ForgotenterTheEmailAddressToWhichYouWillReceiveThe',
      desc: '',
      args: [],
    );
  }

  /// `The email has been sent! Check your email.`
  String get theEmailHasBeenSentCheckYourEmail {
    return Intl.message(
      'The email has been sent! Check your email.',
      name: 'theEmailHasBeenSentCheckYourEmail',
      desc: '',
      args: [],
    );
  }

  /// `Reset password`
  String get resetPassword {
    return Intl.message(
      'Reset password',
      name: 'resetPassword',
      desc: '',
      args: [],
    );
  }

  /// `{resendText}`
  String resendtext(Object resendText) {
    return Intl.message(
      '$resendText',
      name: 'resendtext',
      desc: '',
      args: [resendText],
    );
  }

  /// `Confirm`
  String get confirmTitle {
    return Intl.message('Confirm', name: 'confirmTitle', desc: '', args: []);
  }

  /// `Please confirm your email address.`
  String get confirmMessage {
    return Intl.message(
      'Please confirm your email address.',
      name: 'confirmMessage',
      desc: '',
      args: [],
    );
  }

  /// `Check again`
  String get checkAgain {
    return Intl.message('Check again', name: 'checkAgain', desc: '', args: []);
  }

  /// `Resend`
  String get resend {
    return Intl.message('Resend', name: 'resend', desc: '', args: []);
  }

  /// `Sent ({seconds} sec)`
  String sentIn(Object seconds) {
    return Intl.message(
      'Sent ($seconds sec)',
      name: 'sentIn',
      desc: '',
      args: [seconds],
    );
  }

  /// `SELECT LANGUAGE`
  String get selectLanguage {
    return Intl.message(
      'SELECT LANGUAGE',
      name: 'selectLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get accountPage {
    return Intl.message('Account', name: 'accountPage', desc: '', args: []);
  }

  /// `SETTING AND TOOLS`
  String get settingAndTools {
    return Intl.message(
      'SETTING AND TOOLS',
      name: 'settingAndTools',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message('Theme', name: 'theme', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Successful exit`
  String get successfulExit {
    return Intl.message(
      'Successful exit',
      name: 'successfulExit',
      desc: '',
      args: [],
    );
  }

  /// `APP INFORMATION`
  String get appInformation {
    return Intl.message(
      'APP INFORMATION',
      name: 'appInformation',
      desc: '',
      args: [],
    );
  }

  /// `App version:`
  String get appVersion {
    return Intl.message('App version:', name: 'appVersion', desc: '', args: []);
  }

  /// `Build:`
  String get build {
    return Intl.message('Build:', name: 'build', desc: '', args: []);
  }

  /// `Log out`
  String get logOut {
    return Intl.message('Log out', name: 'logOut', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Search your task...`
  String get searchYourTask {
    return Intl.message(
      'Search your task...',
      name: 'searchYourTask',
      desc: '',
      args: [],
    );
  }

  /// `Create Card`
  String get createCard {
    return Intl.message('Create Card', name: 'createCard', desc: '', args: []);
  }

  /// `Create Board`
  String get createBoard {
    return Intl.message(
      'Create Board',
      name: 'createBoard',
      desc: '',
      args: [],
    );
  }

  /// `New Board`
  String get newBoard {
    return Intl.message('New Board', name: 'newBoard', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Add`
  String get add {
    return Intl.message('Add', name: 'add', desc: '', args: []);
  }

  /// `Delete List`
  String get deleteList {
    return Intl.message('Delete List', name: 'deleteList', desc: '', args: []);
  }

  /// `Rename it`
  String get renameIt {
    return Intl.message('Rename it', name: 'renameIt', desc: '', args: []);
  }

  /// `Delete a column?`
  String get DeleteColumn {
    return Intl.message(
      'Delete a column?',
      name: 'DeleteColumn',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this column and all its tasks?`
  String get areYouSureYouWantToDeleteThisColumnAnd {
    return Intl.message(
      'Are you sure you want to delete this column and all its tasks?',
      name: 'areYouSureYouWantToDeleteThisColumnAnd',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Starred Boards`
  String get starredBoards {
    return Intl.message(
      'Starred Boards',
      name: 'starredBoards',
      desc: '',
      args: [],
    );
  }

  /// `YOUR WORKSPACES`
  String get yourWorkspaces {
    return Intl.message(
      'YOUR WORKSPACES',
      name: 'yourWorkspaces',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ru'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}

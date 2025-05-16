// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(resendText) => "${resendText}";

  static String m1(seconds) => "Sent (${seconds} sec)";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "ForgotenterTheEmailAddressToWhichYouWillReceiveThe":
        MessageLookupByLibrary.simpleMessage(
          "Enter the email address to which you will receive the password reset link.:",
        ),
    "LoginBtnForgotPassword": MessageLookupByLibrary.simpleMessage(
      "Forgot Password?",
    ),
    "LoginBtnHintLoading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "LoginBtnHintSignIn": MessageLookupByLibrary.simpleMessage("Sign In"),
    "LoginBtnHintSignUp": MessageLookupByLibrary.simpleMessage("Sign Up"),
    "LoginHintEmailText": MessageLookupByLibrary.simpleMessage("Email"),
    "LoginTextDontAccount": MessageLookupByLibrary.simpleMessage(
      "Don’t Have An Account? ",
    ),
    "LoginWelcomeSubText": MessageLookupByLibrary.simpleMessage(
      "please sign in to your account",
    ),
    "LoginWelcomeText": MessageLookupByLibrary.simpleMessage("Welcome back!"),
    "RegBtnHintLoading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "RegBtnHintRegister": MessageLookupByLibrary.simpleMessage("Register"),
    "RegBtnLoginText": MessageLookupByLibrary.simpleMessage("Sign In"),
    "RegCreateAcnText": MessageLookupByLibrary.simpleMessage("Create Account"),
    "RegHintConfirmPassword": MessageLookupByLibrary.simpleMessage(
      "Confirm Password",
    ),
    "RegHintEmail": MessageLookupByLibrary.simpleMessage("Email"),
    "RegHintPassword": MessageLookupByLibrary.simpleMessage("Password"),
    "RegTextDoUHaveAccount": MessageLookupByLibrary.simpleMessage(
      "Do You Have An Account? ",
    ),
    "RegisterHintPassCheck": MessageLookupByLibrary.simpleMessage(
      "Passwords don\'t match",
    ),
    "checkAgain": MessageLookupByLibrary.simpleMessage("Check again"),
    "confirmMessage": MessageLookupByLibrary.simpleMessage(
      "Please confirm your email address.",
    ),
    "confirmTitle": MessageLookupByLibrary.simpleMessage("Confirm"),
    "languageSetting": MessageLookupByLibrary.simpleMessage(
      "Language Settings",
    ),
    "resend": MessageLookupByLibrary.simpleMessage("Resend"),
    "resendtext": m0,
    "resetPassword": MessageLookupByLibrary.simpleMessage("Reset password"),
    "sentIn": m1,
    "theEmailHasBeenSentCheckYourEmail": MessageLookupByLibrary.simpleMessage(
      "The email has been sent! Check your email.",
    ),
  };
}

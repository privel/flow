import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flow/data/models/card_model.dart';

// class BoardModel {
//   final String id;
//   final String title;
//   final String ownerId; // ID создателя доски
//   final Map<String, String> sharedWith; // userId -> role
//   final List<CardModel> cards;
//   final bool favorite; // ✅ Новое поле

//   BoardModel({
//     required this.id,
//     required this.title,
//     required this.ownerId,
//     required this.sharedWith,
//     required this.cards,
//     this.favorite = false, // ✅ по умолчанию не избранное
//   });

//   factory BoardModel.fromMap(Map<String, dynamic> map, String boardId) {
//     final cardsData = Map<String, dynamic>.from(map['cards'] ?? {});
//     final sharedMap = Map<String, dynamic>.from(map['sharedWith'] ?? {});

//     return BoardModel(
//       id: boardId,
//       title: map['title'] ?? '',
//       ownerId: map['ownerId'] ?? '',
//       sharedWith: sharedMap.map((key, value) => MapEntry(key, value.toString())),
//       cards: cardsData.entries.map((entry) {
//         return CardModel.fromMap(Map<String, dynamic>.from(entry.value), entry.key);
//       }).toList(),
//       favorite: map['favorite'] ?? false, // ✅ загрузка поля
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'title': title,
//       'ownerId': ownerId,
//       'sharedWith': sharedWith,
//       'cards': {for (var c in cards) c.id: c.toMap()},
//       'favorite': favorite, // ✅ сохранение поля
//     };
//   }

//   BoardModel copyWith({
//     String? id,
//     String? title,
//     String? ownerId,
//     Map<String, String>? sharedWith,
//     List<CardModel>? cards,
//     bool? favorite, // ✅ для обновления
//   }) {
//     return BoardModel(
//       id: id ?? this.id,
//       title: title ?? this.title,
//       ownerId: ownerId ?? this.ownerId,
//       sharedWith: sharedWith ?? Map<String, String>.from(this.sharedWith),
//       cards: cards ?? List<CardModel>.from(this.cards),
//       favorite: favorite ?? this.favorite,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class BoardModel {
  final String id;
  final String title;
  final String ownerId; // ID создателя доски
  final Map<String, Map<String, dynamic>> sharedWith; // userId -> role
  final Map<String, CardModel> cards; // ✅ Map вместо List
  String inviteId;
  final String hexColor;
  final bool isFavorite;

  Color get color =>
      Color(int.parse('FF${hexColor.replaceAll("#", "")}', radix: 16));

  BoardModel({
    required this.id,
    required this.title,
    required this.ownerId,
    required this.sharedWith,
    required this.cards,
    String? inviteId,
    this.isFavorite = false,
    this.hexColor = "11998e",
  }) : inviteId = inviteId ?? const Uuid().v4();

  factory BoardModel.fromMap(Map<String, dynamic> map, String boardId) {
    final cardsData = Map<String, dynamic>.from(map['cards'] ?? {});
    final sharedMap = Map<String, dynamic>.from(map['sharedWith'] ?? {});

    final cardMap = <String, CardModel>{};
    cardsData.forEach((cardId, cardData) {
      cardMap[cardId] =
          CardModel.fromMap(Map<String, dynamic>.from(cardData), cardId);
    });

    final parsedSharedWith = <String, Map<String, dynamic>>{};
    sharedMap.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        parsedSharedWith[key] = value;
      } else {
        // поддержка старого формата: просто роль без статуса
        parsedSharedWith[key] = {
          'role': value.toString(),
          'status': 'accepted',
        };
      }
    });

    final favoriteValue = map['isFavorite'];

    return BoardModel(
      id: boardId,
      title: map['title'] ?? '',
      ownerId: map['ownerId'] ?? '',
      sharedWith: parsedSharedWith,
      cards: cardMap,
      inviteId: map['inviteId'] ?? const Uuid().v4(),
      isFavorite: favoriteValue == true,
      hexColor: map['hexColor'] ?? "11998e",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'ownerId': ownerId,
      'sharedWith': sharedWith,
      'cards': cards.map((key, value) => MapEntry(key, value.toMap())),
      'inviteId': inviteId,
      'isFavorite': isFavorite,
      'hexColor': hexColor,
    };
  }

  BoardModel copyWith({
    String? id,
    String? title,
    String? ownerId,
    Map<String, Map<String, dynamic>>? sharedWith,
    Map<String, CardModel>? cards,
    String? inviteId,
    bool? isFavorite,
    String? hexColor,
  }) {
    return BoardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      ownerId: ownerId ?? this.ownerId,
      sharedWith: sharedWith ??
          this
              .sharedWith
              .map((k, v) => MapEntry(k, Map<String, dynamic>.from(v))),
      cards: cards ?? Map<String, CardModel>.from(this.cards),
      inviteId: inviteId ?? this.inviteId,
      isFavorite: isFavorite ?? this.isFavorite,
      hexColor: hexColor ?? this.hexColor,
    );
  }

  factory BoardModel.empty() {
    return BoardModel(
      id: '',
      title: '',
      ownerId: '',
      sharedWith: {},
      cards: {},
    );
  }
}

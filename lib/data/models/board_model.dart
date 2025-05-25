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


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flow/data/models/card_model.dart';
import 'package:flutter/material.dart';

class BoardModel {
  final String id;
  final String title;
  final String ownerId; // ID создателя доски
  final Map<String, String> sharedWith; // userId -> role
  final Map<String, CardModel> cards; // ✅ Map вместо List
  final String hexColor;
  final bool favorite;
  
   Color get color => Color(int.parse('FF${hexColor.replaceAll("#", "")}', radix: 16));

  BoardModel({
    required this.id,
    required this.title,
    required this.ownerId,
    required this.sharedWith,
    required this.cards,
    this.favorite = false,
    this.hexColor = "11998e",
  });

  factory BoardModel.fromMap(Map<String, dynamic> map, String boardId) {
    final cardsData = Map<String, dynamic>.from(map['cards'] ?? {});
    final sharedMap = Map<String, dynamic>.from(map['sharedWith'] ?? {});

    final cardMap = <String, CardModel>{};
    cardsData.forEach((cardId, cardData) {
      cardMap[cardId] = CardModel.fromMap(Map<String, dynamic>.from(cardData), cardId);
    });

    return BoardModel(
      id: boardId,
      title: map['title'] ?? '',
      ownerId: map['ownerId'] ?? '',
      sharedWith: sharedMap.map((key, value) => MapEntry(key, value.toString())),
      cards: cardMap,
      favorite: map['favorite'] ?? false,
      hexColor: map['hexColor'] ?? "11998e"
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'ownerId': ownerId,
      'sharedWith': sharedWith,
      'cards': cards.map((key, value) => MapEntry(key, value.toMap())),
      'favorite': favorite,
      'hexColor': hexColor,
    };
  }

  BoardModel copyWith({
    String? id,
    String? title,
    String? ownerId,
    Map<String, String>? sharedWith,
    Map<String, CardModel>? cards,
    bool? favorite,
    String? hexColor,
  }) {
    return BoardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      ownerId: ownerId ?? this.ownerId,
      sharedWith: sharedWith ?? Map<String, String>.from(this.sharedWith),
      cards: cards ?? Map<String, CardModel>.from(this.cards),
      favorite: favorite ?? this.favorite,
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
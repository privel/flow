/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });




const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Инициализируем Firebase Admin SDK.
// Эта строка должна быть в начале вашего файла функций.
admin.initializeApp();

// Cloud Function, которая срабатывает при создании нового документа
// в коллекции 'notifications'.
exports.sendNotificationOnNotificationCreate = functions.firestore
    .document('notifications/{notificationId}') // Слушаем коллекцию 'notifications'
    .onCreate(async (snap, context) => { // Функция будет выполняться при каждом создании нового документа
        const notificationData = snap.data(); // Данные созданного уведомления

        const userId = notificationData.userId; // Получаем userId из данных уведомления
        const title = notificationData.title; // Получаем заголовок
        const description = notificationData.description; // Получаем описание
        const type = notificationData.type; // Получаем тип (например, 'invitation')
        const metadata = notificationData.metadata; // Получаем метаданные (например, boardId)

        // Проверяем, есть ли userId. Если нет, это некорректное уведомление.
        if (!userId) {
            console.warn('Notification document is missing userId. Skipping push notification.');
            return null;
        }

        // 1. Получаем FCM-токен пользователя из коллекции 'users'
        // Предполагаем, что ваш AuthProvider сохраняет токен в поле 'message_token'
        const userDocRef = admin.firestore().collection('users').doc(userId);
        const userDoc = await userDocRef.get();

        if (!userDoc.exists) {
            console.warn(`User document for userId: ${userId} not found. Skipping push notification.`);
            return null;
        }

        const fcmToken = userDoc.data()?.message_token; // Берем токен из поля 'message_token'

        if (!fcmToken) {
            console.warn(`No FCM token found for user: ${userId}. User might not have logged in on a device yet, or token is missing.`);
            return null; // Не можем отправить уведомление без токена
        }

        // 2. Создаем структуру сообщения для FCM
        const messagePayload = {
            notification: {
                title: title,
                body: description,
            },
            data: {
                // Эти данные будут доступны в вашем Flutter приложении
                // в `RemoteMessage.data`.
                // Они используются для логики обработки уведомления (например, навигации).
                'notificationId': context.params.notificationId, // ID самого документа уведомления Firestore
                'type': type || 'default', // Тип уведомления
                'userId': userId, // ID получателя
                // Добавляем метаданные, если они есть.
                // Например, для типа 'invitation' у вас есть 'boardId'
                ...(metadata && typeof metadata === 'object' ? metadata : {}),
            },
        };

        // 3. Отправляем сообщение на устройство пользователя через FCM
        try {
            const response = await admin.messaging().sendToDevice(fcmToken, messagePayload);
            console.log('Successfully sent message to user:', userId, 'Response:', response);

            // Опционально: можно обработать ошибки отправки
            if (response.results[0].error) {
                console.error('Error sending message:', response.results[0].error);
                // Если токен недействителен, его можно удалить из Firestore
                if (response.results[0].error.code === 'messaging/invalid-registration-token' ||
                    response.results[0].error.code === 'messaging/registration-token-not-registered') {
                    console.log('Removing invalid token for user:', userId, fcmToken);
                    await userDocRef.update({ message_token: admin.firestore.FieldValue.delete() });
                }
            }
        } catch (error) {
            console.error('Error sending message to user:', userId, error);
        }

        return null; // Cloud Function должна возвращать null или Promise<void>
    });
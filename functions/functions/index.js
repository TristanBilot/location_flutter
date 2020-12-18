'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp()

/// ------------------ Messaging push notifs  ------------------ ///

const DeviceTokensKey = 'DeviceTokens';
const NotificationSettingsKey = 'NotificationSettings';

/// notif types
const MessageType = 'Messages';
const ChatType = 'Chats';
const RequestType = 'Requests';
const ViewType = 'Views';

/**
* Trigger new messages.
*/
exports.sendMessage = functions.firestore
.document('/messages/{chatID}/chats/{msgID}')
.onCreate((doc, context) => {
  const msg = doc.data();
  const sentToID = msg.SentTo;
  const fromID = msg.SentBy;
  const body = msg.Message;
  const title = msg.SentByFirstName;
  const notifType = MessageType;
  const conditionToSendNotifCallback = (userNotifSettings) => {
    return Boolean(userNotifSettings[MessageType]);
  }
  return _sendPushNotification(sentToID, fromID, title, body, notifType, conditionToSendNotifCallback);
  });


/**
* Trigger new chats or requests.
*/
exports.sendChatOrRequest = functions.firestore
.document('/messages/{chatID}')
.onCreate((doc, context) => {
  const chat = doc.data();
  const sentToID = chat.UserIDs[1]; // requested ID
  const fromID = chat.UserIDs[0]; // requester ID
  const isChat = Boolean(chat.IsChatEngaged); // or request
  const title = chat.UserNames[1];
  const body = isChat ? 'New chat 🔥' : 'New request 🔥'; // penser à traduire en checkant le language du user
  const notifType = isChat ? ChatType : RequestType;
  const conditionToSendNotifCallback = (userNotifSettings) => {
    return (isChat && Boolean(userNotifSettings[ChatType])) ||
    (!isChat && Boolean(userNotifSettings[RequestType]));
  }
  return _sendPushNotification(sentToID, fromID, body, title, notifType, conditionToSendNotifCallback);
  });

/**
* Trigger new profile views.
*/
exports.sendView = functions.firestore
.document('/locations/{userID}/UserIDsWhoWiewedMe/{fromID}')
.onCreate((doc, context) => {
  const sentToID = context.params.userID;
  const fromID = context.params.fromID;
  const title = 'Someone viewed your profile!';
  const body = 'Engage now a conversation 😍'; // penser à traduire en checkant le language du user
  const notifType = ViewType;
  const conditionToSendNotifCallback = (userNotifSettings) => {
    return Boolean(userNotifSettings[ViewType]);
  }
  return _sendPushNotification(sentToID, fromID, body, title, notifType, conditionToSendNotifCallback);
  });

  /**
   * method used generically to send a push notif with user data fetching
   */
function _sendPushNotification(sentToID, fromID, body, title, notifType, conditionToSendNotifCallback) {
  if (!sentToID) {
    console.log('error: sentToID is null.');
    return;
  }
  /// fetch user from user ID
  admin.firestore().doc('/locations/' + sentToID).get().then((snapshot) => {
    const user = snapshot.data();
    const deviceTokens = user[DeviceTokensKey];
    const notifSettings = user[NotificationSettingsKey];

    if (!deviceTokens || !notifSettings) {
      console.log('error: user device tokens or notif settings null.');
      return;
    }
    const shouldSendMessage = conditionToSendNotifCallback(notifSettings);
    if (!shouldSendMessage) {
      console.log('Not sent because of disabled notifications settings');
      return;
    }
    console.log('Sending notif of type ' + notifType + ': ' + body);

    const message = {
      notification: {
          title: title,
          sound: 'default',
          body: body,
          priority: '10',
          click_action: 'FLUTTER_NOTIFICATION_CLICK'
      },
      /// to access information in every handler methods in the app, 
      /// use the `data` element.
      data: {
        type: notifType,
        fromID: fromID,
      }
    };
    /// send the push notif message
    admin.messaging().sendToDevice(deviceTokens, message, {
      mutableContent: true,
      contentAvailable: true,
      apnsPushType: "background"
    })
      .then((response) => {
        console.log('Notification succefully sent to ' + sentToID);
        return response;
      }).catch((error) => { console.log('Sending notification error:', error); });
      return null;
    }).catch(error => { console.log('Get document error ' + error); });
}

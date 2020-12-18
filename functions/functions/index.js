'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const path = require('path');
const os = require('os');
const fs = require('fs');
const gm = require('gm').subClass({ imageMagick: true });

admin.initializeApp()

/// ------------------ Picture processing  ------------------ ///

/**
 * When an image is uploaded in the Storage bucket, we want to 
 * create a copy resized it and circle it.
 */
exports.onFileUploaded = functions.storage.object().onFinalize(async (file) => {
  // File path in the bucket.
  const filePath = file.name;
  // Get the file name.
  const fileName = path.basename(filePath);

  // We do not want to convert all images but only the main picture which
  // not have a '_n' at the end
  if (!fileName.startsWith('mainPicture_'))
    return;


  /* prefix used to break infinite loop in the firestore trigger */
  const outputFilePrefix = 'circle_';
  const size = 150;
  const fileBucket = file.bucket; // The Storage bucket that contains the file.
  const contentType = file.contentType; // File content type.

  // Exit if this is triggered on a file that is not an image.
  if (!contentType.startsWith('image/')) {
    return console.log('This is not an image.');
  }

  // Exit if the image is already a thumbnail.
  if (fileName.startsWith(outputFilePrefix)) {
    return console.log('This file had already been modified.');
  }

  // Download file from bucket.
  const bucket = admin.storage().bucket(fileBucket);
  const fileNameWithPng = fileName.substr(0, fileName.lastIndexOf(".")) + ".png";
  const inTmpPath = path.join(os.tmpdir(), 'in_' + fileName);
  const outTmpPath = path.join(os.tmpdir(), fileNameWithPng);
  const metadata = { contentType: contentType };

  // Download the file from Firestore to a tmp folder.
  await bucket.file(filePath).download({destination: inTmpPath});
  console.log('Image downloaded locally to', inTmpPath);

  gm(inTmpPath) // could use crop()
  .resize(size, size, "!") // force the image to resize
  .write(outTmpPath, async () => {
    console.log('writing');
    gm(size, size, 'none')
        .fill(outTmpPath) // scale
        .drawCircle(size / 2, size / 2, size / 2, 0)
        .write(outTmpPath, async () => {
          console.log('Circles photo created at', outTmpPath);
        
          const firestoreFilePath = path.join(path.dirname(filePath), outputFilePrefix + fileNameWithPng);
          // Remove old photo.
          // await bucket.file(filePath).delete();
          // Uploading the output photo to firestore.
          await bucket.upload(outTmpPath, {
            destination: firestoreFilePath,
            metadata: metadata,
          });
          // Delete the local files to free up disk space.
          fs.unlinkSync(outTmpPath);
          return fs.unlinkSync(inTmpPath);
        });
  });
  return null;
});

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

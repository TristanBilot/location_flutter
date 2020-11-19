'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp()
const path = require('path');
const os = require('os');
const fs = require('fs');
const gm = require('gm').subClass({ imageMagick: true });

/* prefix used to break infinite loop in the firestore trigger */
const outputFilePrefix = 'circle_';
const size = 150;

/**
 * When an image is uploaded in the Storage bucket, we want to 
 * resize it and circle it.
 */
exports.onFileUploaded = functions.storage.object().onFinalize(async (file) => {
  const fileBucket = file.bucket; // The Storage bucket that contains the file.
  const filePath = file.name; // File path in the bucket.
  const contentType = file.contentType; // File content type.

  // Exit if this is triggered on a file that is not an image.
  if (!contentType.startsWith('image/')) {
    return console.log('This is not an image.');
  }

  // Get the file name.
  const fileName = path.basename(filePath);
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

/// Handle when a new message is created in firestore
exports.sendMessage = functions.firestore
.document('/messages/{chatID}/chats/{msgID}')
.onCreate((doc, context) => {
  const msg = doc.data();
  const sentToID = msg.SentTo;
  const text = msg.Message;

  if (!sentToID) {
    console.log('error: sentToID is null.');
    return;
  }
  /// fetch user from user ID
  admin.firestore().doc('/locations/' + sentToID).get().then((snapshot) => {
    const user = snapshot.data();
    const deviceTokens = user.DeviceTokens;

    if (!deviceTokens) {
      console.log('error: user device tokens null.');
      return;
    }
    console.log('tokens: ' + deviceTokens);

    const message = {
      notification: {
          title: user.FirstName,
          body: text,
          type: 'message',
      },
    };
    /// send the push notif   message
    admin.messaging().sendToDevice(deviceTokens, message, {
      mutableContent: true,
      contentAvailable: true,
      apnsPushType: "background"
    })
      .then((response) => {
        console.log('Message succefully sent to ' + sentToID);
        return response;
      }).catch((error) => { console.log('sending message error:', error); });
      return null;
    }).catch(error => { console.log('get document error ' + error); });
  });

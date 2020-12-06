import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

const db = admin.firestore();
const fcm = admin.messaging();

export const sendToTopic = functions.firestore
  .document('messages/{chatId}/{chatId}/{message}')
  .onCreate(async snapshot => {
    const message = snapshot.data();

    const payload: admin.messaging.MessagingPayload = {
      notification: {
        title: 'New Message!',
        body: `Unknown sent you a message`,
        icon: 'https://firebasestorage.googleapis.com/v0/b/communicaid-5453b.appspot.com/o/logo.png?alt=media&token=b00f8ddb-560e-478e-8b22-01d14937283f',

        click_action: 'FLUTTER_NOTIFICATION_CLICK' // required only for onResume or onLaunch callbacks
      }
    };

    return fcm.sendToDevice("ebdC8CFqThyWi_LrMs2WwY:APA91bFwcd6RxkOIvBXIdUtQuZpVfsDmC7Gp1o5XhV9Q2GYcmQ9MjI7Kaa2wRisYGGO1wAEevSCeLOVdr94k7TRn4Fh8gqlfYRJRcwrw9band-1GCoXV8htUf8EiRAlv3_9x9lfedxpr", payload);
  });

export const sendToDevice = functions.firestore
  .document('orders/{orderId}')
  .onCreate(async snapshot => {


    const order = snapshot.data();

    const querySnapshot = await db
      .collection('users')
      .doc(order.seller)
      .collection('tokens')
      .get();

    const tokens = querySnapshot.docs.map(snap => snap.id);

    const payload: admin.messaging.MessagingPayload = {
      notification: {
        title: 'New Order!',
        body: `you sold a ${order.product} for ${order.total}`,
        icon: 'your-icon-url',
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      }
    };

    return fcm.sendToDevice(tokens, payload);
  });
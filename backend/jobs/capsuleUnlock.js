const cron = require('node-cron');
const admin = require('firebase-admin');
const { sendNotification } = require('../services/fcmService');

// Run every minute
cron.schedule('* * * * *', async () => {
  console.log('Running capsule unlock job...');
  try {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();

    const capsulesRef = db.collection('capsule_notes');
    const snapshot = await capsulesRef
      .where('isUnlocked', '==', false)
      .where('unlockAt', '<=', now)
      .get();

    if (snapshot.empty) {
      return;
    }

    const batch = db.batch();
    const notifications = [];

    for (const doc of snapshot.docs) {
      const data = doc.data();
      const userId = data.userId;
      const title = data.title;

      batch.update(doc.ref, {
        isUnlocked: true,
        isNotified: true,
      });

      // Fetch user's FCM token
      const userDoc = await db.collection('users').doc(userId).get();
      if (userDoc.exists) {
        const userData = userDoc.data();
        if (userData.fcmToken) {
          notifications.push({
            token: userData.fcmToken,
            title: 'Your capsule is open! 🎉',
            body: `Your note '${title}' is now unlocked!`,
          });
        }
      }
    }

    await batch.commit();

    // Send notifications
    for (const notif of notifications) {
      await sendNotification(notif.token, notif.title, notif.body);
    }
    
    console.log(`Unlocked ${snapshot.size} capsules`);
  } catch (error) {
    console.error('Error in capsule unlock job:', error);
  }
});

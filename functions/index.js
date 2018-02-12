const functions = require('firebase-functions');

const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
exports.helloWorld = functions.https.onRequest((request, response) => {
     response.send("Hello from Firebase!");
});


exports.sendPushNotifications = functions.https.onRequest((req, res) => {
    res.send("Attempting to send push notifications")

    //admin.message().sendToDevice(token, payload);

    // This registration token comes from the client FCM SDKs.
    var fcmToken = "d7HQwse4F6c:APA91bF1UAJi66Fvi3SybrU0NqhEAmV1mm0XoTvxkJbfzIswJ0VrJ8deNRt2HL9W8dEkvSnYmq07P-8JkrTJLrV-C3MzLaaHE65fRWxYMzkg4yV7APriMj_YbxcpaW_xcyHoGf0i33iY";

    // See the "Defining the message payload" section below for details
    // on how to define a message payload.
    var payload = {
        notification: {
            title: "Lucky you!",
            body: "Some just found a lost item that belongs to you, log in to get it back."
        },
        data: {
            score: "850",
            time: "2:45"
        }
    };

    // Send a message to the device corresponding to the provided
    // registration token.
    admin.messaging().sendToDevice(fcmToken, payload)
        .then(function(response) {
        // See the MessagingDevicesResponse reference documentation for
        // the contents of response.
        console.log("Successfully sent message:", response);
        return null;
        })
        .catch(function(error) {
            console.log("Error sending message:", error);
         });
})
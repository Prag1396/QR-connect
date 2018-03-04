const functions = require('firebase-functions');

const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
exports.helloWorld = functions.https.onRequest((request, response) => {
     response.send("Hello from Firebase!");
     
});

//Listen for following events and then trigger a push notification
exports.observeusermessages = functions.database.ref('/messages/{messageID}').onCreate(event => {

    var messageID = event.params.messageID;

    return admin.database().ref('/messages/' + messageID).once('value', snapshot => {
        var message = snapshot.val();

        observeUser(message.fromID, message.toID, message.messagetext);
    })
})

function observeUser(senderID, recipientUID, text) {
    admin.database().ref('/users/' + recipientUID).once('value', snapshot => {
        var recipientUIDReference = snapshot.val()
        var badgeValue = parseInt(recipientUIDReference.unreadMessagesCounter) + 1

    console.log("Attempting to send message");
    admin.database().ref('/users/' + senderID).once('value', snapshot => {
        var _senderIDref = snapshot.val();
        var name = _senderIDref.FirstName;
        var payload = {
            notification: {
                title: name + "found your lost item",
                body:  'Log back in to get it back!',
                badge: badgeValue.toString(),
                sound: 'default'
            },
            data: {
                //Put data
                senderID: name,
                text: text
            }
        }

        admin.messaging().sendToDevice(recipientUIDReference.token, payload)
        .then(function(response) {
            console.log(payload)
        // See the MessagingDevicesResponse reference documentation for
        // the contents of response.
        console.log("Successfully sent message:", response);
        return null;
        })
        .catch(function(error) {
            console.log("Error sending message:", error);
         });

    })

    return admin.database().ref('/users/' + recipientUID).update({unreadMessagesCounter: badgeValue})
    })
}

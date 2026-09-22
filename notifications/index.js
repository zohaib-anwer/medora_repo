const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

const db = getFirestore();
const messaging = getMessaging();

exports.sendChatNotification = onDocumentCreated(
  "chats/{chatId}/messages/{messageId}",
  async (event) => {
    try {
      const message = event.data?.data();

      if (!message) {
        console.log("No message data found.");
        return;
      }

      const chatId = event.params.chatId;
      const messageId = event.params.messageId;

      const senderId = message.senderId;
      const senderType = message.senderType;
      const messageText = message.text || "";

      if (!senderId || !senderType) {
        console.log("Missing sender information.");
        return;
      }

      // Get chat document
      const chatSnap = await db
        .collection("chats")
        .doc(chatId)
        .get();

      if (!chatSnap.exists) {
        console.log("Chat document not found:", chatId);
        return;
      }

      const chat = chatSnap.data();

      const patientId = chat.patientId;
      const doctorId = chat.doctorId;

      let receiverId;

      if (senderType === "patient") {
        receiverId = doctorId;
      } else if (senderType === "doctor") {
        receiverId = patientId;
      } else {
        console.log("Unknown sender type:", senderType);
        return;
      }

      if (!receiverId) {
        console.log("Receiver ID not found.");
        return;
      }

      console.log("====================================");
      console.log("NEW CHAT MESSAGE");
      console.log("CHAT ID:", chatId);
      console.log("MESSAGE ID:", messageId);
      console.log("SENDER:", senderId);
      console.log("SENDER TYPE:", senderType);
      console.log("RECEIVER:", receiverId);

      // Get receiver profile
      const receiverSnap = await db
        .collection("paitent")
        .doc(receiverId)
        .get();

      if (!receiverSnap.exists) {
        console.log("Receiver profile not found:", receiverId);
        return;
      }

      const receiverData = receiverSnap.data();
      const fcmToken = receiverData.fcmToken;

      if (!fcmToken) {
        console.log("FCM token not found for:", receiverId);
        return;
      }

      console.log("FCM TOKEN FOUND FOR:", receiverId);

      let senderName = "New Message";

      if (senderType === "doctor") {
        senderName = chat.doctorName || "Doctor";
      } else {
        senderName = chat.patientName || "Patient";
      }

      let notificationBody = messageText;

      if (message.type === "image") {
        notificationBody = "📷 Image";
      }

      if (!notificationBody) {
        notificationBody = "You received a new message";
      }

      const payload = {
        token: fcmToken,

        notification: {
          title: senderName,
          body: notificationBody,
        },

       data: {
  type: "chat",
  messageType: message.type || "text",

  chatId: chatId,

  patientId: patientId || "",
  doctorId: doctorId || "",

  patientName: chat.patientName || "Patient",
  patientImage: chat.patientImage || "",

  doctorName: chat.doctorName || "Doctor",
  doctorImage: chat.doctorImage || "",
  doctorSpecialist: chat.doctorSpecialist || "",

  senderId: senderId,
  senderType: senderType,
  messageId: messageId,
},
        android: {
          priority: "high",
          notification: {
            channelId: "chat_messages",
            sound: "default",
            priority: "high",
            icon: "ic_notification",
          },
        },

        apns: {
          payload: {
            aps: {
              sound: "default",
            },
          },
        },
      };

      await messaging.send(payload);

      console.log("FCM NOTIFICATION SENT SUCCESSFULLY");
      console.log("====================================");

    } catch (error) {
      console.error("FCM NOTIFICATION ERROR:", error);
    }
  }
);
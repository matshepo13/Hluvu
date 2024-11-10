

import {onCall} from "firebase-functions/v2/https";
import * as functions from "firebase-functions";
import * as nodemailer from "nodemailer";

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "matshepo.soto@fraktionaldev.com",
    // Use an app password if you have 2FA enabled
    pass: "Tebogomatshepo@2000",
  },
});

export const sendEmergencyAlert = onCall(async (request) => {
  const {email, location, message} = request.data;

  const mailOptions = {
    from: "matshepo.soto@fraktionaldev.com",
    to: "tebogomatshepo@gmail.com",
    subject: "🚨 EMERGENCY ALERT",
    html: `
      <div style="font-family: Arial, sans-serif; padding: 20px; 
        background-color: #f5f5f5;">
        <h2 style="color: #ff0000;">Emergency Alert</h2>
        <p><strong>From:</strong> ${email}</p>
        <p><strong>Message:</strong> ${message}</p>
        <p><strong>Location:</strong> 
          <a href="${location}">View on Google Maps</a></p>
        <p><strong>Time:</strong> ${new Date().toLocaleString()}</p>
      </div>
    `,
  };

  try {
    await transporter.sendMail(mailOptions);
    return {success: true};
  } catch (error) {
    console.error("Error sending email:", error);
    throw new functions.https.HttpsError("internal", "Error sending email");
  }
});

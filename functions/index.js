/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const { onRequest } = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");
// const { initializeApp } = require("firebase-admin/app");
// const { getFirestore } = require("firebase-admin/firestore");

// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", { structuredData: true });
//   response.send("Hello from Firebase!");
// });

// initializeApp();
const functions = require("firebase-functions");
const stripe = require("stripe")(
  "sk_test_51PtRsEFsjlkin0gBloSpTRR2tFgnX2fQhgh6dT8UwKDlbU8ezGYpY0LFENYkbPAh704LMSWjMpXiFjq0BXt8k3xY00m56zSuDQ"
);

exports.stripePaymentIntentRequest = functions.https.onRequest(
  async (req, res) => {
    try {
      let customerId;

      //Gets the customer who's email id matches the one sent by the client
      const customerList = await stripe.customers.list({
        email: req.body.email,
        limit: 1,
      });

      //Checks the if the customer exists, if not creates a new customer
      if (customerList.data.length !== 0) {
        customerId = customerList.data[0].id;
      } else {
        const customer = await stripe.customers.create({
          email: req.body.email,
        });
        customerId = customer.data.id;
      }

      //Creates a temporary secret key linked with the customer
      const ephemeralKey = await stripe.ephemeralKeys.create(
        { customer: customerId },
        { apiVersion: "2020-08-27" }
      );

      //Creates a new payment intent with amount passed in from the client
      const paymentIntent = await stripe.paymentIntents.create({
        amount: parseInt(req.body.amount),
        currency: "eur",
        customer: customerId,
      });

      res.status(200).send({
        paymentIntent: paymentIntent.client_secret,
        ephemeralKey: ephemeralKey.secret,
        customer: customerId,
        success: true,
      });
    } catch (error) {
      res.status(404).send({ success: false, error: error.message });
    }
  }
);

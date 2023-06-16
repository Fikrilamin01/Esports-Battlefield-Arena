/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */
const https = require('https');
const { onRequest } = require("firebase-functions/v2/https");
const functions = require("firebase-functions");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const axios = require('axios');
const express = require('express');
const cors = require('cors');
const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);
// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });


admin.initializeApp();

exports.stripePaymentIntentRequest = functions.https.onRequest(async (req, res) => {
    try {
        let customerId;
        //Gets the customer who's email id matches the one sent by the client
        const customerList = await stripe.customers.list({
            email: req.body.email,
            limit: 1
        });

        //Checks the if the customer exists, if not creates a new customer
        if (customerList.data.length != 0) {
            customerId = customerList.data[0].id;
        }
        else {
            const customer = await stripe.customers.create({
                email: req.body.email
            });
            customerId = customer.data.id;
        }

        //Creates a temporary secret key linked with the customer 
        const ephemeralKey = await stripe.ephemeralKeys.create(
            { customer: customerId },
            { apiVersion: '2022-11-15' }
        );

        //Creates a new payment intent with amount passed in from the client
        const paymentIntent = await stripe.paymentIntents.create({
            amount: parseFloat(req.body.amount) * 100,
            currency: 'myr',
            customer: customerId,
        })

        //Sends the client the payment intent secret, ephemeral key secret and customer id
        res.status(200).send({
            success: true,
            paymentIntentId: paymentIntent.id,
            clientSecret: paymentIntent.client_secret,
            ephemeralKey: ephemeralKey.secret,
            customer: customerId,
        })

    } catch (error) {
        res.status(404).send({ success: false, error: error.message })
    }
});


exports.cancelPaymentIntent = functions.https.onRequest(async (req, res) => {
    const paymentIntentId = req.body.paymentIntentId;

    try {
        const paymentIntent = await stripe.paymentIntents.cancel(paymentIntentId);
        //Sends the client the payment intent secret, ephemeral key secret and customer id
        res.status(200).send({
            message: 'Payment intent canceled.'
        })
    } catch (error) {
        console.error(error);
        res.status(404).send({ success: false, error: error.message })
    }
});


exports.verifyApexPlayer = functions.https.onCall(async (data, context) => {
    try {
        if (!context.auth) {
            return {
                status: false,
                message: 'User is not authenticated',
                data: [],
            }
        }
        if (data == null) {
            return {
                status: false,
                message: 'No data sent',
                data: [],
            }
        }
        var auth = process.env.ALS_API_KEY;
        var player = data.username;
        var platform = data.platform;

        const apiUrl = 'https://api.mozambiquehe.re/nametouid?auth=' + auth + '&player=' + player + '&platform=' + platform;

        const response = await axios.get(apiUrl, {
            headers: {
                'Content-Type': 'application/json',
            },
        });
        const responseData = response.data;
        if (responseData.error != null) {
            return {
                status: false,
                message: response.data.error,
                data: [],
            }
        }

        const playerInformation = {
            uid: responseData.uid,
            pid: responseData.pid,
            username: responseData.name,
        }

        return {
            status: true,
            message: 'Retrieved player information successfully',
            data: playerInformation,
        };
    } catch (error) {
        throw new functions.https.HttpsError('internal', 'An error occurred', error.message);
    }

});


exports.updateValorantGameResult = functions.https.onCall(async (data, context) => {
    try {
        if (!context.auth) {
            return {
                status: false,
                message: 'User is not authenticated',
                data: [],
            }
        }
        if (data == null) {
            return {
                status: false,
                message: 'No data sent',
                data: [],
            }
        }
        var auth = process.env.ALS_API_KEY;
        var player = data.username;
        var platform = data.platform;

        const apiUrl = 'https://api.mozambiquehe.re/nametouid?auth=' + auth + '&player=' + player + '&platform=' + platform;

        const response = await axios.get(apiUrl, {
            headers: {
                'Content-Type': 'application/json',
            },
        });
        const responseData = response.data;
        if (responseData.error != null) {
            return {
                status: false,
                message: response.data.error,
                data: [],
            }
        }

        const playerInformation = {
            uid: responseData.uid,
            pid: responseData.pid,
            username: responseData.name,
        }

        return {
            status: true,
            message: 'Retrieved player information successfully',
            data: playerInformation,
        };
    } catch (error) {
        throw new functions.https.HttpsError('internal', 'An error occurred', error.message);
    }

});


// RESTFUL API
const app = express();
app.use(cors({ origin: true }));

const db = admin.firestore();

//Routes
app.get('/', (req, res) => {
    return res.status(200).send('Hello World!');
});

//Collection names
const userCollection = 'Users';
const playerCollection = 'Players';
const organizerCollection = 'Organizers';
const invoiceCollection = 'Invoices';

//User
//Create new user -> POST()
app.post('/users', async (req, res) => {
    try {
        let email = req.body.email;
        let password = req.body.password;
        let address = req.body.address;
        let country = req.body.country;
        let role = req.body.role;
        let request = {
            email: email,
            password: password,
            address: address,
            country: country,
            role: role,
            userId : ''
        }
        logger.info("POST USER API: REQUEST DATA", { data: request });
        let documentRef = await db.collection(userCollection).add(request);

        
        //update the user id
        await db.collection(userCollection).doc(documentRef.id).update({
            userId: documentRef.id
        });
        let response;
        response = request;
        response.userId = documentRef.id;

        // If user role is player, create a new player document
        if (role == 'player') {
            let fName = req.body.firstName;
            let lName = req.body.lastName;
            await db.collection(playerCollection).doc(documentRef.id).create({
                userId: documentRef.id,
                firstName: fName,
                lastName: lName,
            });
            response.put('firstName', documentRef.id);
            response.put('lastName', documentRef.id);
        } else if (role == 'organizer') { // If user role is organizer, create a new organizer document
            let orgsName = req.body.organizerName;
            await db.collection(organizerCollection).doc(documentRef.id).create({
                userId: documentRef.id,
                organizerName: orgsName,
            });
            response.put('organizerName', documentRef.id);
        } else {
            return res.status(404).send({ success: false, error: 'Invalid user role' })
        }

        logger.info("POST USER API", { data: response });
        return res.status(200).send({ success: true, data: response });
    } catch (error) {
        console.error(error);
        return res.status(500).send({ success: false, error: error.message })

    }
});

//Get all user -> GET()
app.get('/users', async (req, res) => {
    try {
        const query = db.collection(userCollection);
        let response = [];
        let querySnapshot = await query.get();
        let docs = querySnapshot.docs;
        docs.map((doc) => response.push(doc.data()));
        logger.info("GET ALL USER API", { data: response });
        return res.status(200).send({ success: true, data: response });
    } catch (error) {
        console.error(error);
        return res.status(500).send({ success: false, error: error.message })

    }
});

//Get user by id -> GET()
app.get('/users/:id', async (req, res) => {
    try {
        const reqData = db.collection(userCollection).doc(req.params.id);
        let userDetail = await reqData.get();
        let response = userDetail.data();
        if(response == null){
            return res.status(404).send({ success: false, error: 'User not found' })
        }
        logger.info("GET USER API", { data: response });
        return res.status(200).send({ success: true, data: response });
    } catch (error) {
        console.error(error);
        return res.status(500).send({ success: false, error: error.message })

    }
});

//Update user by id -> PUT()
app.put('/users/:id', async (req, res) => {
    try {
        const reqDoc = db.collection(userCollection).doc(req.params.id);
        let email = req.body.email;
        let password = req.body.password;
        let address = req.body.address;
        let country = req.body.country;
        let role = req.body.role;

        let request = {
            email: email,
            password: password,
            address: address,
            country: country,
            role: role,
        }

        logger.info("PUT USER API: REQUEST DATA", { data: request });
        await reqDoc.update(request);

        let response;
        // If user role is player, create a new player document
        if (role == 'player') {
            let fName = req.body.firstName;
            let lName = req.body.lastName;
            const playerDoc = db.collection(playerCollection).doc(req.params.id);
            await playerDoc.update({
                firstName: fName,
                lastName: lName,
            });
            response = {
                email: email,
                password: password,
                address: address,
                country: country,
                role: role,
                firstName: fName,
                lastName: lName,
            }
        } else if (role == 'organizer') { // If user role is organizer, create a new organizer document
            let orgsName = req.body.organizerName;
            const teamDoc = db.collection(organizerCollection).doc(req.params.id);
            await teamDoc.update({
                organizerName: orgsName,
            });
            response = {
                email: email,
                password: password,
                address: address,
                country: country,
                role: role,
                organizerName: orgsName
            }
        } else {
            return res.status(404).send({ success: false, error: 'Invalid user role' })
        }
        logger.info("PUT USER API", { data: response });
        return res.status(200).send({ success: true, data: response });
    } catch (error) {
        console.error(error);
        return res.status(500).send({ success: false, error: error.message })

    }
});

//Delete user by id -> DELETE()
app.delete('/users/:id', async (req, res) => {
    try {
        const reqData = db.collection(userCollection).doc(req.params.id);

        //get the detail data to be deleted
        let userDetail = await reqData.get();
        let response = userDetail.data();

        if (response.role == 'player') {
            const playerDoc = db.collection(playerCollection).doc(req.params.id);
            await playerDoc.delete();
        } else if (response.role == 'organizer') {
            const organizerDoc = db.collection(organizerCollection).doc(req.params.id);
            await organizerDoc.delete();
        } else {
            return res.status(404).send({ success: false, error: 'Invalid user role' })
        }

        //delete the data
        await reqData.delete();

        logger.info("DELETE USER API", { data: response });
        return res.status(200).send({ success: true, data: response });
    } catch (error) {
        console.error(error);
        return res.status(500).send({ success: false, error: error.message })

    }
});

//Invoice
//Create new invoice -> POST()
app.post('/invoices', async (req, res) => {
    try {
        let amount = req.body.amount;
        let belognsTo = req.body.belognsTo;
        let date = req.body.date;
        let paidBy = req.body.paidBy;
        let paidCompleted = req.body.paidCompleted;
        let paymentReferenceId = req.body.paymentReferenceId;
        let time = req.body.time;
        let tournementId = req.body.tournementId;

        request = {
            amount: amount,
            belognsTo: belognsTo,
            date: date,
            paidBy: paidBy,
            paidCompleted: paidCompleted,
            paymentReferenceId: paymentReferenceId,
            time: time,
            tournementId: tournementId,
            invoiceId: ''
        }

        logger.info("POST INVOICE API: REQUEST DATA", { data: request });
        let documentRef = await db.collection(invoiceCollection).add(request);
        //update the user id
        await db.collection(invoiceCollection).doc(documentRef.id).update({
            invoiceId: documentRef.id
        });

        let response = request;
        response.invoiceId = documentRef.id;

        logger.info("POST INVOICE API", { data: response });
        return res.status(200).send({ success: true, data: response });
    } catch (error) {
        console.error(error);
        return res.status(500).send({ success: false, error: error.message })

    }
});

//Get all invoices -> GET()
app.get('/invoices', async (req, res) => {
    try {
        const query = db.collection(invoiceCollection);
        let response = [];
        let querySnapshot = await query.get();
        let docs = querySnapshot.docs;
        docs.map((doc) => response.push(doc.data()));
        logger.info("GET ALL INVOICE API", { data: response });
        return res.status(200).send({ success: true, data: response });
    } catch (error) {
        console.error(error);
        return res.status(500).send({ success: false, error: error.message })

    }
});

//Get invoice by id -> GET()
app.get('/invoices/:id', async (req, res) => {
    try {
        const reqData = db.collection(invoiceCollection).doc(req.params.id);
        let userDetail = await reqData.get();
        let response = userDetail.data();
        if(response == null){
            return res.status(404).send({ success: false, error: 'Invoice not found' })
        }
        logger.info("GET INVOICE API", { data: response });
        return res.status(200).send({ success: true, data: response });
    } catch (error) {
        console.error(error);
        return res.status(500).send({ success: false, error: error.message })

    }
});

//Update invoice by id -> PUT()
app.put('/invoices/:id', async (req, res) => {
    try {
        const reqDoc = db.collection(invoiceCollection).doc(req.params.id);
        let amount = req.body.amount;
        let belognsTo = req.body.belognsTo;
        let date = req.body.date;
        let paidBy = req.body.paidBy;
        let paidCompleted = req.body.paidCompleted;
        let paymentReferenceId = req.body.paymentReferenceId;
        let time = req.body.time;
        let tournementId = req.body.tournementId;
        let invoiceId = req.body.invoiceId;

        request = {
            amount: amount,
            belognsTo: belognsTo,
            date: date,
            paidBy: paidBy,
            paidCompleted: paidCompleted,
            paymentReferenceId: paymentReferenceId,
            time: time,
            tournementId: tournementId,
            invoiceId: invoiceId
        }

        await reqDoc.update(request);
        let response = request;
      
        logger.info("PUT INVOICE API", { data: response });
        return res.status(200).send({ success: true, data: response });
    } catch (error) {
        console.error(error);
        return res.status(500).send({ success: false, error: error.message })

    }
});

//Delete invoice by id -> DELETE()
app.delete('/invoices/:id', async (req, res) => {
    try {
        const reqData = db.collection(userCollection).doc(req.params.id);

        //get the detail data to be deleted
        let invoiceDetail = await reqData.get();
        let response = invoiceDetail.data();

        //delete the data
        await reqData.delete();

        logger.info("DELETE INVOICE API", { data: response });
        return res.status(200).send({ success: true, data: response });
    } catch (error) {
        console.error(error);
        return res.status(500).send({ success: false, error: error.message })

    }
});

exports.api = functions.https.onRequest(app);

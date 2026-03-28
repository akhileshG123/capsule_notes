require('dotenv').config();
const express = require('express');
const admin = require('firebase-admin');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.applicationDefault(), // Uses GOOGLE_APPLICATION_CREDENTIALS
  projectId: process.env.FIREBASE_PROJECT_ID,
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
});

const app = express();
app.use(express.json());

// Routes
const voiceRoutes = require('./routes/voice');
const scanRoutes = require('./routes/scan');

app.use('/api/voice', voiceRoutes);
app.use('/api/scan', scanRoutes);

// Start node-cron job
require('./jobs/capsuleUnlock');

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});

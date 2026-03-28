const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const authMiddleware = require('../middleware/authMiddleware');
const { extractText } = require('../services/visionService');

router.post('/extract', authMiddleware, async (req, res) => {
  const { noteId, userId, imageUrl } = req.body;
  if (!noteId || !userId || !imageUrl) {
    return res.status(400).json({ success: false, error: 'Missing parameters' });
  }

  if (req.user.uid !== userId) {
    return res.status(403).json({ success: false, error: 'Forbidden' });
  }

  try {
    const gcsUri = `gs://${process.env.FIREBASE_STORAGE_BUCKET}/scans/${userId}/${noteId}.jpg`;
    const extractedText = await extractText(gcsUri);

    const db = admin.firestore();
    await db.collection('scanned_notes').doc(noteId).update({
      extractedText: extractedText || 'No text detected.',
      isProcessed: true,
    });

    res.json({ success: true, extractedText });
  } catch (error) {
    console.error('OCR error:', error);
    res.status(500).json({ success: false, error: 'OCR failed' });
  }
});

module.exports = router;

const express = require('express');
const router = express.Router();
const admin = require('firebase-admin');
const authMiddleware = require('../middleware/authMiddleware');
const { transcribeAudio } = require('../services/speechService');

router.post('/transcribe', authMiddleware, async (req, res) => {
  const { noteId, userId, audioUrl } = req.body;
  if (!noteId || !userId || !audioUrl) {
    return res.status(400).json({ success: false, error: 'Missing parameters' });
  }

  if (req.user.uid !== userId) {
    return res.status(403).json({ success: false, error: 'Forbidden' });
  }

  try {
    const gcsUri = `gs://${process.env.FIREBASE_STORAGE_BUCKET}/audio/${userId}/${noteId}.m4a`;
    const transcript = await transcribeAudio(gcsUri);

    const db = admin.firestore();
    await db.collection('voice_notes').doc(noteId).update({
      transcript: transcript || 'No speech detected.',
      isTranscribed: true,
    });

    res.json({ success: true, transcript });
  } catch (error) {
    console.error('Transcription error:', error);
    res.status(500).json({ success: false, error: 'Transcription failed' });
  }
});

module.exports = router;

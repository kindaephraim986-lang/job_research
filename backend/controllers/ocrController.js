const fs = require('fs');
const { createWorker } = require('tesseract.js');
const { compareOcrData } = require('../utils/ocrCompare');

const verifyDocumentData = async (req, res) => {
  try {
    const { userData, ocrData } = req.body;

    if (!userData || !ocrData) {
      return res.status(422).json({
        success: false,
        message: 'userData et ocrData sont requis dans le corps de la requête'
      });
    }

    const comparison = compareOcrData(userData, ocrData);

    return res.json({
      success: true,
      comparison
    });
  } catch (error) {
    console.error('OCR VERIFICATION ERROR:', error);
    return res.status(500).json({
      success: false,
      message: 'Erreur lors de la comparaison OCR',
      error: error.message
    });
  }
};

const extractDocumentText = async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ success: false, message: 'Aucun fichier image reçu.' });
  }

  const filePath = req.file.path;
  const worker = createWorker();

  try {
    await worker.load();
    await worker.loadLanguage('fra');
    await worker.initialize('fra');

    const { data } = await worker.recognize(filePath);
    await worker.terminate();

    return res.json({
      success: true,
      text: data.text || ''
    });
  } catch (error) {
    console.error('OCR EXTRACTION ERROR:', error);
    return res.status(500).json({ success: false, message: 'Impossible d’extraire le texte OCR', error: error.message });
  } finally {
    fs.unlink(filePath, () => {});
  }
};

module.exports = {
  verifyDocumentData,
  extractDocumentText
};

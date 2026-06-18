function normalizeString(value) {
  if (typeof value !== 'string') return '';
  return value
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9\s]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function normalizePhone(value) {
  if (typeof value !== 'string') return '';
  return value.replace(/[^0-9+]/g, '');
}

function compareTextField(userValue, ocrValue) {
  return normalizeString(userValue) === normalizeString(ocrValue);
}

function comparePhoneField(userPhone, ocrPhone) {
  return normalizePhone(userPhone) === normalizePhone(ocrPhone);
}

function getMatchScore(userValue, ocrValue) {
  const normalizedUser = normalizeString(userValue);
  const normalizedOcr = normalizeString(ocrValue);
  if (!normalizedUser || !normalizedOcr) return 0;
  if (normalizedUser === normalizedOcr) return 100;
  const userWords = normalizedUser.split(' ');
  const ocrWords = normalizedOcr.split(' ');
  const matching = userWords.filter(word => ocrWords.includes(word));
  return Math.round((matching.length / Math.max(userWords.length, ocrWords.length)) * 100);
}

function compareOcrData(userData, ocrData) {
  return {
    nom: compareTextField(userData.nom, ocrData.nom),
    age: Number(userData.age) === Number(ocrData.age),
    telephone: comparePhoneField(userData.telephone, ocrData.telephone),
    domicile: compareTextField(userData.domicile, ocrData.domicile),
    score: {
      nom: getMatchScore(userData.nom, ocrData.nom),
      age: Number(userData.age) === Number(ocrData.age) ? 100 : 0,
      telephone: comparePhoneField(userData.telephone, ocrData.telephone) ? 100 : 0,
      domicile: getMatchScore(userData.domicile, ocrData.domicile)
    }
  };
}

module.exports = {
  normalizeString,
  normalizePhone,
  compareTextField,
  comparePhoneField,
  getMatchScore,
  compareOcrData
};

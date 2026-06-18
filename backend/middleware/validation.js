const { body, validationResult } = require('express-validator');

const phonePattern = /^(?:(?:\+221|00221)\d{9}|(?:\+226|00226)\d{8}|0\d{8,9})$/;

const validateRegister = [
  body('email')
    .trim()
    .isEmail()
    .withMessage('Email invalide'),
  body('password')
    .isLength({ min: 8 })
    .withMessage('Le mot de passe doit contenir au moins 8 caractères'),
  body('userType')
    .trim()
    .isIn(['candidat', 'entreprise'])
    .withMessage('Type utilisateur invalide'),

  body('nom')
    .if(body('userType').equals('candidat'))
    .trim()
    .notEmpty()
    .withMessage('Le nom complet est requis'),
  body('telephone')
    .if(body('userType').equals('candidat'))
    .trim()
    .matches(phonePattern)
    .withMessage('Téléphone candidat invalide'),
  body('age')
    .if(body('userType').equals('candidat'))
    .trim()
    .isInt({ min: 18, max: 65 })
    .withMessage('L’âge doit être compris entre 18 et 65 ans'),
  body('domicile')
    .if(body('userType').equals('candidat'))
    .trim()
    .notEmpty()
    .withMessage('Le domicile est requis'),
  body('filiere')
    .if(body('userType').equals('candidat'))
    .trim()
    .notEmpty()
    .withMessage('La filière est requise'),
  body('sexe')
    .if(body('userType').equals('candidat'))
    .trim()
    .notEmpty()
    .withMessage('Le sexe est requis'),

  body('nomSociete')
    .if(body('userType').equals('entreprise'))
    .trim()
    .notEmpty()
    .withMessage('Le nom de la société est requis'),
  body('domaine')
    .if(body('userType').equals('entreprise'))
    .trim()
    .notEmpty()
    .withMessage('Le domaine est requis'),
  body('villeLieu')
    .if(body('userType').equals('entreprise'))
    .trim()
    .notEmpty()
    .withMessage('La ville / lieu est requis'),
  body('telephone')
    .if(body('userType').equals('entreprise'))
    .trim()
    .matches(phonePattern)
    .withMessage('Téléphone entreprise invalide'),

  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(422).json({ errors: errors.array() });
    }
    return next();
  }
];

module.exports = {
  validateRegister
};

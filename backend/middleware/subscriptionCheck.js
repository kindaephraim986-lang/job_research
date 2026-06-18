/**
 * middleware/subscriptionCheck.js
 * Middleware pour vérifier l'abonnement de l'entreprise
 */

const db = require('../config/database');

/**
 * Middleware : Vérifier que l'entreprise a un abonnement actif
 * Utilisation : router.get('/protected-route', checkSubscription, controller)
 */
const checkSubscription = async (req, res, next) => {
  try {
    const entrepriseId = req.user?.entreprise_id || req.body?.entreprise_id;
    
    if (!entrepriseId) {
      return res.status(401).json({
        success: false,
        message: 'Entreprise ID requis',
        code: 'NO_ENTERPRISE_ID'
      });
    }

    const [subscriptions] = await db.query(
      `SELECT * FROM subscriptions 
       WHERE entreprise_id = ? AND status = 'active' AND end_date > NOW()
       ORDER BY end_date DESC LIMIT 1`,
      [entrepriseId]
    );

    if (!subscriptions || subscriptions.length === 0) {
      return res.status(402).json({
        success: false,
        message: 'Abonnement requis. Veuillez souscrire pour accéder à cette ressource.',
        code: 'SUBSCRIPTION_REQUIRED',
        nextAction: 'SHOW_SUBSCRIPTION_DIALOG'
      });
    }

    // Attachez les infos d'abonnement à la requête
    req.subscription = subscriptions[0];
    next();
  } catch (error) {
    console.error('Erreur checkSubscription:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur serveur',
      error: error.message
    });
  }
};

/**
 * Middleware : Vérifier l'abonnement et logger l'accès bloqué
 */
const checkSubscriptionWithLog = async (req, res, next) => {
  try {
    const entrepriseId = req.user?.entreprise_id;
    const candidatId = req.params.candidat_id || req.body?.candidat_id;

    if (!entrepriseId || !candidatId) {
      return res.status(400).json({
        success: false,
        message: 'Paramètres manquants'
      });
    }

    const [subscriptions] = await db.query(
      `SELECT * FROM subscriptions 
       WHERE entreprise_id = ? AND status = 'active' AND end_date > NOW()
       LIMIT 1`,
      [entrepriseId]
    );

    const hasSubscription = subscriptions && subscriptions.length > 0;

    // Logger l'accès (bloqué ou autorisé)
    await db.query(
      `INSERT INTO document_access_logs 
       (document_id, document_type, candidat_id, entreprise_id, access_type, blocked_reason, ip_address, user_agent)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        candidatId,
        'candidat_profile',
        candidatId,
        entrepriseId,
        hasSubscription ? 'view' : 'blocked',
        hasSubscription ? null : 'NO_ACTIVE_SUBSCRIPTION',
        req.ip,
        req.get('user-agent')
      ]
    );

    if (!hasSubscription) {
      return res.status(402).json({
        success: false,
        message: 'Abonnement requis pour accéder aux coordonnées de ce candidat',
        code: 'SUBSCRIPTION_REQUIRED',
        nextAction: 'SHOW_SUBSCRIPTION_PROMPT'
      });
    }

    req.subscription = subscriptions[0];
    next();
  } catch (error) {
    console.error('Erreur checkSubscriptionWithLog:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur serveur',
      error: error.message
    });
  }
};

module.exports = {
  checkSubscription,
  checkSubscriptionWithLog
};

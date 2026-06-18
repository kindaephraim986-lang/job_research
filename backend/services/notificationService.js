/**
 * services/notificationService.js
 * Service pour gérer les notifications
 */

const db = require('../config/database');

/**
 * Types de notifications disponibles
 */
const NOTIFICATION_TYPES = {
  OFFER: 'offer',                    // Nouvelle offre publiée
  MESSAGE: 'message',                // Nouveau message reçu
  APPLICATION_ACCEPTED: 'application_update',  // Candidature acceptée
  SUBSCRIPTION: 'subscription',      // Alerte abonnement
  DOCUMENT_ACCESS: 'document_access' // Tentative d'accès bloquée
};

/**
 * Créer une notification
 * @param {number} userId - ID de l'utilisateur
 * @param {string} userType - Type d'utilisateur ('candidat' ou 'entreprise')
 * @param {string} type - Type de notification
 * @param {string} title - Titre de la notification
 * @param {string} message - Corps du message
 * @param {number} relatedId - ID de la ressource associée (offre, message, etc.)
 * @param {string} relatedType - Type de ressource associée
 * @returns {Promise<Object>}
 */
const createNotification = async (userId, userType, type, title, message, relatedId = null, relatedType = null) => {
  try {
    const [result] = await db.query(
      `INSERT INTO notifications 
       (user_id, user_type, type, title, message, related_id, related_type, is_read)
       VALUES (?, ?, ?, ?, ?, ?, ?, FALSE)`,
      [userId, userType, type, title, message, relatedId, relatedType]
    );

    return {
      success: true,
      notificationId: result.insertId,
      message: 'Notification créée'
    };
  } catch (error) {
    console.error('Erreur createNotification:', error);
    throw error;
  }
};

/**
 * Créer des notifications pour plusieurs utilisateurs
 */
const createBulkNotifications = async (userIds, userType, type, title, message, relatedId = null, relatedType = null) => {
  try {
    const promises = userIds.map(userId =>
      createNotification(userId, userType, type, title, message, relatedId, relatedType)
    );

    const results = await Promise.all(promises);

    return {
      success: true,
      created: results.filter(r => r.success).length,
      total: userIds.length
    };
  } catch (error) {
    console.error('Erreur createBulkNotifications:', error);
    throw error;
  }
};

/**
 * Récupérer les notifications non lues d'un utilisateur
 */
const getUnreadNotifications = async (userId, limit = 20) => {
  try {
    const [notifications] = await db.query(
      `SELECT * FROM notifications 
       WHERE user_id = ? AND is_read = FALSE
       ORDER BY created_at DESC
       LIMIT ?`,
      [userId, limit]
    );

    return {
      success: true,
      notifications: notifications || [],
      unreadCount: notifications ? notifications.length : 0
    };
  } catch (error) {
    console.error('Erreur getUnreadNotifications:', error);
    throw error;
  }
};

/**
 * Récupérer toutes les notifications (lues et non lues)
 */
const getAllNotifications = async (userId, limit = 50, offset = 0) => {
  try {
    const [notifications] = await db.query(
      `SELECT * FROM notifications 
       WHERE user_id = ?
       ORDER BY created_at DESC
       LIMIT ? OFFSET ?`,
      [userId, limit, offset]
    );

    const [countResult] = await db.query(
      `SELECT COUNT(*) as total FROM notifications WHERE user_id = ?`,
      [userId]
    );

    const [unreadCount] = await db.query(
      `SELECT COUNT(*) as unread FROM notifications WHERE user_id = ? AND is_read = FALSE`,
      [userId]
    );

    return {
      success: true,
      notifications: notifications || [],
      total: countResult[0].total,
      unread: unreadCount[0].unread,
      hasMore: (offset + limit) < countResult[0].total
    };
  } catch (error) {
    console.error('Erreur getAllNotifications:', error);
    throw error;
  }
};

/**
 * Marquer une notification comme lue
 */
const markAsRead = async (notificationId) => {
  try {
    const [result] = await db.query(
      `UPDATE notifications 
       SET is_read = TRUE, read_at = NOW()
       WHERE id = ?`,
      [notificationId]
    );

    return {
      success: result.affectedRows > 0,
      message: 'Notification marquée comme lue'
    };
  } catch (error) {
    console.error('Erreur markAsRead:', error);
    throw error;
  }
};

/**
 * Marquer toutes les notifications d'un utilisateur comme lues
 */
const markAllAsRead = async (userId) => {
  try {
    const [result] = await db.query(
      `UPDATE notifications 
       SET is_read = TRUE, read_at = NOW()
       WHERE user_id = ? AND is_read = FALSE`,
      [userId]
    );

    return {
      success: true,
      updated: result.affectedRows,
      message: `${result.affectedRows} notification(s) marquée(s) comme lue(s)`
    };
  } catch (error) {
    console.error('Erreur markAllAsRead:', error);
    throw error;
  }
};

/**
 * Supprimer une notification
 */
const deleteNotification = async (notificationId) => {
  try {
    const [result] = await db.query(
      `DELETE FROM notifications WHERE id = ?`,
      [notificationId]
    );

    return {
      success: result.affectedRows > 0,
      message: 'Notification supprimée'
    };
  } catch (error) {
    console.error('Erreur deleteNotification:', error);
    throw error;
  }
};

/**
 * Supprimer toutes les notifications lues d'un utilisateur
 */
const deleteReadNotifications = async (userId) => {
  try {
    const [result] = await db.query(
      `DELETE FROM notifications WHERE user_id = ? AND is_read = TRUE`,
      [userId]
    );

    return {
      success: true,
      deleted: result.affectedRows,
      message: `${result.affectedRows} notification(s) supprimée(s)`
    };
  } catch (error) {
    console.error('Erreur deleteReadNotifications:', error);
    throw error;
  }
};

/**
 * Obtenir le count de notifications non lues
 */
const getUnreadCount = async (userId) => {
  try {
    const [result] = await db.query(
      `SELECT COUNT(*) as unread FROM notifications 
       WHERE user_id = ? AND is_read = FALSE`,
      [userId]
    );

    return {
      success: true,
      unreadCount: result[0].unread
    };
  } catch (error) {
    console.error('Erreur getUnreadCount:', error);
    throw error;
  }
};

/**
 * Créer une notification quand une offre est publiée
 * À appeler depuis le contrôleur d'offres
 */
const notifyNewOffer = async (offreTitre, offreId, entrepriseNom, domaine = null) => {
  try {
    // Récupérer tous les candidats correspondant au domaine
    let query = 'SELECT DISTINCT c.id FROM candidats c';
    const params = [];

    if (domaine) {
      query += ' WHERE c.domaine = ?';
      params.push(domaine);
    }

    const [candidats] = await db.query(query, params);

    if (candidats && candidats.length > 0) {
      const candidatIds = candidats.map(c => c.id);
      const title = `Nouvelle offre: ${offreTitre}`;
      const message = `Une nouvelle offre a été publiée par ${entrepriseNom}`;

      await createBulkNotifications(
        candidatIds,
        'candidat',
        NOTIFICATION_TYPES.OFFER,
        title,
        message,
        offreId,
        'offre'
      );
    }

    return {
      success: true,
      notifiedCount: candidats ? candidats.length : 0
    };
  } catch (error) {
    console.error('Erreur notifyNewOffer:', error);
    throw error;
  }
};

/**
 * Créer une notification quand une candidature est acceptée/refusée
 */
const notifyCandidatureUpdate = async (candidatId, offreTitre, status) => {
  try {
    const statusMessage = {
      'accepted': 'a été acceptée! 🎉',
      'rejected': 'a été refusée',
      'pending': 'est en attente de traitement'
    };

    const title = `Mise à jour candidature: ${offreTitre}`;
    const message = `Votre candidature pour "${offreTitre}" ${statusMessage[status] || 'a été mise à jour'}`;

    await createNotification(
      candidatId,
      'candidat',
      NOTIFICATION_TYPES.APPLICATION_ACCEPTED,
      title,
      message,
      null,
      'candidature'
    );

    return { success: true };
  } catch (error) {
    console.error('Erreur notifyCandidatureUpdate:', error);
    throw error;
  }
};

/**
 * Créer une notification de message
 */
const notifyNewMessage = async (userId, senderName, messagePreview) => {
  try {
    const title = `Nouveau message de ${senderName}`;
    const message = messagePreview;

    await createNotification(
      userId,
      'candidat',
      NOTIFICATION_TYPES.MESSAGE,
      title,
      message,
      null,
      'message'
    );

    return { success: true };
  } catch (error) {
    console.error('Erreur notifyNewMessage:', error);
    throw error;
  }
};

module.exports = {
  NOTIFICATION_TYPES,
  createNotification,
  createBulkNotifications,
  getUnreadNotifications,
  getAllNotifications,
  markAsRead,
  markAllAsRead,
  deleteNotification,
  deleteReadNotifications,
  getUnreadCount,
  notifyNewOffer,
  notifyCandidatureUpdate,
  notifyNewMessage
};

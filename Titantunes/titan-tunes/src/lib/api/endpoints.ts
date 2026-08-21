export const API_BASE = "";

const endpoints = {
  auth: {
    login:        `${API_BASE}/auth/login`,
    register:     `${API_BASE}/auth/register`,
    adminCreate:  `${API_BASE}/auth/admin/create`,
    verify:       `${API_BASE}/auth/verify`,
    forgotPwd:    `${API_BASE}/auth/forgot-password`,
    resetPwd:     `${API_BASE}/auth/reset-password`,
  },

  artistes: {
    list:              `${API_BASE}/artistes`,
    byId:              (id: number) => `${API_BASE}/artistes/${id}`,
    update:            (id: number) => `${API_BASE}/artistes/${id}`,
    dashboard:         (id: number) => `${API_BASE}/artistes/${id}/dashboard`,
    uploadPhoto:       (id: number) => `${API_BASE}/artistes/${id}/photo`,
    photoUrl:          (id: number) => `${API_BASE}/artistes/${id}/photo/url`,
  },

  chansons: {
    list:              `${API_BASE}/chansons`,
    byId:              (id: number) => `${API_BASE}/chansons/${id}`,
    publier:           `${API_BASE}/chansons/publier`,
    stream:            (id: number) => `${API_BASE}/chansons/${id}/stream`,
    recherche:         `${API_BASE}/chansons/recherche`,
    tendances:         `${API_BASE}/chansons/tendances`,
    delete:            (id: number) => `${API_BASE}/chansons/${id}`,
  },

  albums: {
    create:            `${API_BASE}/albums`,
    byId:              (id: number) => `${API_BASE}/albums/${id}`,
    byArtiste:         (artisteId: number) => `${API_BASE}/albums/artiste/${artisteId}`,
    delete:            (id: number) => `${API_BASE}/albums/${id}`,
  },

  evenements: {
    list:              `${API_BASE}/evenements`,
    byId:              (id: number) => `${API_BASE}/evenements/${id}`,
    byArtiste:         (artisteId: number) => `${API_BASE}/evenements/artiste/${artisteId}`,
    create:            `${API_BASE}/evenements`,
    delete:            (id: number) => `${API_BASE}/evenements/${id}`,
  },

  admin: {
    utilisateurs:      `${API_BASE}/admin/utilisateurs`,
    updateStatut:      (id: number) => `${API_BASE}/admin/utilisateurs/${id}/statut`,
    verifierArtiste:   (id: number) => `${API_BASE}/admin/artistes/${id}/verifier`,
    artistesEnAttente: `${API_BASE}/admin/artistes/en-attente`,
    metriques:         `${API_BASE}/admin/dashboard/metriques`,
    finances:          `${API_BASE}/admin/dashboard/finances`,
    stats:             `${API_BASE}/admin/dashboard/stats`,
  },

  labels: {
    list:              `${API_BASE}/labels`,
    byId:              (id: number) => `${API_BASE}/labels/${id}`,
    create:            `${API_BASE}/labels`,
    delete:            (id: number) => `${API_BASE}/labels/${id}`,
  },

  notifications: {
    list:              `${API_BASE}/notifications`,
    create:            `${API_BASE}/notifications`,
    markRead:          (id: number) => `${API_BASE}/notifications/${id}/lire`,
    delete:            (id: number) => `${API_BASE}/notifications/${id}`,
    promoArtiste:      (artisteId: number) => `${API_BASE}/notifications/promo/artiste/${artisteId}`,
  },

  bannieres: {
    actives:           `${API_BASE}/bannieres/actives`,
    byId:              (id: number) => `${API_BASE}/bannieres/${id}`,
    byArtiste:         (artisteId: number) => `${API_BASE}/bannieres/artiste/${artisteId}`,
    create:            `${API_BASE}/bannieres`,
    activer:           (id: number) => `${API_BASE}/bannieres/${id}/activer`,
    desactiver:        (id: number) => `${API_BASE}/bannieres/${id}/desactiver`,
    delete:            (id: number) => `${API_BASE}/bannieres/${id}`,
  },

  categories: {
    list:              `${API_BASE}/categories`,
    byId:              (id: number) => `${API_BASE}/categories/${id}`,
    create:            `${API_BASE}/categories`,
    delete:            (id: number) => `${API_BASE}/categories/${id}`,
  },

  reversements: {
    byArtiste:         (artisteId: number) => `${API_BASE}/reversements/artiste/${artisteId}`,
    totalByArtiste:    (artisteId: number) => `${API_BASE}/reversements/artiste/${artisteId}/total`,
    calculerArtiste:   (artisteId: number) => `${API_BASE}/reversements/calculer/artiste/${artisteId}`,
    calculerMensuel:   `${API_BASE}/reversements/calculer/mensuel`,
    verser:            (id: number) => `${API_BASE}/reversements/${id}/verser`,
  },
};

export default endpoints;


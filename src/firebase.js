const admin = require('firebase-admin');
const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

// Initialize with better emulator handling
if (!admin.apps.length) {
  // Initialize with application default credentials or empty if using emulator
  const projectId = process.env.GOOGLE_CLOUD_PROJECT || 'emu-project';
  initializeApp({ 
    projectId,
    credential: applicationDefault() 
  });
  
  console.log('Firebase Admin SDK initialized with project:', projectId);
}

const db = getFirestore();

// Explicitly log if using emulator for better debugging
if (process.env.FIRESTORE_EMULATOR_HOST) {
  console.log('Using Firestore emulator at:', process.env.FIRESTORE_EMULATOR_HOST);
}

module.exports = db;

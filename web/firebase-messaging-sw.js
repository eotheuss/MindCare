importScripts("https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js");

// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
firebase.initializeApp({
  apiKey: "AIzaSyBbKFtoL_H8UEg3dNXHEPOgvSDWtHXAOPg",
  authDomain: "mindcare-diary.firebaseapp.com",
  projectId: "mindcare-diary",
  storageBucket: "mindcare-diary.firebasestorage.app",
  messagingSenderId: "657584084120",
  appId: "1:657584084120:web:4c8c22f274739f6bb8eced",
  measurementId: "G-6E3W9DT5TQ"
});

const messaging = firebase.messaging();




// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyDwu-WnKDBzKEGSAM8LOFzVQpaKEIbB-WI",
  authDomain: "flash-card-22d3c.firebaseapp.com",
  projectId: "flash-card-22d3c",
  storageBucket: "flash-card-22d3c.firebasestorage.app",
  messagingSenderId: "709370489781",
  appId: "1:709370489781:web:15c15fdf7f41b9fd2687fc",
  measurementId: "G-5NTNZXT6E7"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
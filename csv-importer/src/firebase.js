import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";
const firebaseConfig = {
    apiKey: "AIzaSyAJfGMbVZAVc6DrrnNX1qbC9Njy7LZ2rHE",
    authDomain: "myapp-yefa.firebaseapp.com",
    projectId: "myapp-yefa",
    storageBucket: "myapp-yefa.firebasestorage.app",
    messagingSenderId: "598573520763",
    appId: "1:598573520763:web:d8c15d43609a0ca43c0fde",
    measurementId: "G-4VHP8YR3KJ"
  };

const app = initializeApp(firebaseConfig);
export const db = getFirestore(app);

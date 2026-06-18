package com.ankon.ankonai.firebase

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.storage.FirebaseStorage
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class FirebaseService @Inject constructor() {
    val auth: FirebaseAuth = FirebaseAuth.getInstance()
    val firestore: FirebaseFirestore = FirebaseFirestore.getInstance()
    val storage: FirebaseStorage = FirebaseStorage.getInstance()
    
    fun getCurrentUser() = auth.currentUser
    
    fun isUserLoggedIn() = auth.currentUser != null
    
    fun signInAnonymously(onSuccess: () -> Unit, onError: (Exception) -> Unit) {
        auth.signInAnonymously()
            .addOnSuccessListener { onSuccess() }
            .addOnFailureListener { onError(it) }
    }
}

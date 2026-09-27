// Integrations/FirestoreSecurityRules.swift
// Authoritative Firebase Firestore security rules enforcing strict owner UID scoping (P09).
// Per P09 specification: rules reject every cross-UID read/write/query and untrusted owner-ID substitution.

import Foundation

struct FirestoreSecurityRules: Sendable {
    static let rulesText: String = """
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User root document and private subcollections
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // All subcollections (tasks, projects, reminders, conversations, memories)
      // are strictly partitioned per authenticated UID.
      match /{allSubcollections=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }

    // Default deny-all for all other paths
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
"""
}

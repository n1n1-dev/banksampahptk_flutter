# banksampahptk_flutter

A new Flutter project.

## Getting Started

rules_version = '2';
service cloud.firestore {
  function userIsAuthenticated() {
    return request.auth.uid != null;
  }
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, create, update: if userIsAuthenticated();
      allow delete: if userIsAuthenticated() && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.rules == 'superadmin';
    }
  }
  match /databases/{database}/documents {
    match /sampah/{sampahId} {
      allow read: if userIsAuthenticated();
      allow write: if userIsAuthenticated() && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.rules == 'superadmin';
    }
  }
  match /databases/{database}/documents {
    match /banksampah/{banksampahId} {
      allow read: if userIsAuthenticated();
      allow write: if userIsAuthenticated() && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.rules == 'superadmin';
    }
  }   
    match /databases/{database}/documents {
    match /sampahbanksampah/{sampahbanksampahId} {
      allow read: if userIsAuthenticated();
      allow create: if userIsAuthenticated() && (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.rules == 'superadmin' || get(/databases/$(database)/documents/users/$(request.auth.uid)).data.rules == 'admin');
      allow update, delete: if userIsAuthenticated() && (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.rules == 'superadmin' || (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.rules == 'admin' && (resource.data.banksampahRef==/databases/$(database)/documents/banksampah/$(get(/databases/$(database)/documents/users/$(request.auth.uid)).data.banksampahId))));
    }
  }
  match /databases/{database}/documents {
    match /keranjangestimasi/{keranjangestimasiId} {
      allow read: if userIsAuthenticated();
      allow write: if userIsAuthenticated() && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.rules == 'nasabah';
    }
  }
}


Path apk release
https://github.com/n1n1-dev/banksampahptk_flutter/blob/master/build/app/outputs/flutter-apk/banksampahptk.apk

Login User
superadmin : adminbanksampahptk23@gmail.com (user email), adm1n123456@ (password)
admin bs tanray 1 : admintanray1@gmail.com (user email), adm1nbs123456@ (password)
admin bs tanray 2 : admintanray2@gmail.com (user email), adm1nbs123456@ (password)
nasabah : maya@gmail.com (user email), maya123456@ (password)

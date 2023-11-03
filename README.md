# banksampahptk_flutter

A new Flutter project.

## Getting Started

Firebase Authentication

![image](https://github.com/n1n1-dev/banksampahptk_flutter/assets/30413833/92b930b6-02a9-48b5-88f7-1655de6d699f)


Firebase Cloud Firestore

![image](https://github.com/n1n1-dev/banksampahptk_flutter/assets/30413833/4230298c-8375-465c-9dc4-284cafdfea04)

![image](https://github.com/n1n1-dev/banksampahptk_flutter/assets/30413833/021ec10e-ef86-4574-9b88-36cb251d08d0)

![image](https://github.com/n1n1-dev/banksampahptk_flutter/assets/30413833/ce353216-3532-4486-8aaf-719546071d71)

![image](https://github.com/n1n1-dev/banksampahptk_flutter/assets/30413833/a09719f3-2d9d-42b6-a0c9-276b74ad61c2)

![image](https://github.com/n1n1-dev/banksampahptk_flutter/assets/30413833/577f784a-4eb1-40f1-9e95-3b750d06dcb7)


Firebase Rules

![image](https://github.com/n1n1-dev/banksampahptk_flutter/assets/30413833/8cefb700-90b5-4715-a304-06cd807bf4d0)

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

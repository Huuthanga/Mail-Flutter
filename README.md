# 📱 GMAIL-CLONE APP

## PROJECT OVERVIEW

The Gmail-Clone App is a Flutter-based project that simulates an email service similar to Gmail. This application allows users to:
- Send and receive emails internally within the system
- Access their accounts and emails across multiple devices
- Register and log in using secure authentication
- Utilize a "Forgot Password" feature for account recovery

Since this is a simulated service, the application does not use standard email protocols (IMAP/POP/SMTP). Instead, it exchanges data between the client and the server via HTTP or sockets. The backend can be implemented using Firebase or other frameworks like ExpressJS, SpringBoot, or ASP.NET.

## SYSTEM REQUIREMENTS

- **Operating System**: Windows, macOS, or Linux
- **Flutter SDK**: Version 3.0 or later
- **Dart SDK**: Included with Flutter SDK
- **Database**: Firebase, SQLite, or any server-based database

## SETUP INSTRUCTIONS

### STEP 1: CLONE THE REPOSITORY

Open a terminal and navigate to the desired directory:

```bash
git clone <repository-url>
cd gmail_clone_project
```

### STEP 2: INSTALL DEPENDENCIES

Ensure Flutter is installed by running:

```bash
flutter doctor
```

Then, install the necessary dependencies:

```bash
flutter pub get
```

### STEP 3: BUILD THE APPLICATION

Run the following commands based on your platform:

- **Android**:
  ```bash
  flutter build apk
  ```
- **Windows**:
  ```bash
  flutter build windows
  ```

## ACCOUNT FOR TESTING

You can create your own account via the register function, but we recommend using one of our test accounts for better testing:

- **Email:** kuraa@gmail.com  
  **Password:** 123456  
- **Email:** kurab@gmail.com  
  **Password:** 123456  
- **Email:** khangnghiaa@gmail.com  
  **Password:** 123456  
- **Email:** khangnghiab@gmail.com  
  **Password:** 123456  

We recommend creating a Gmail account with the same username as your existing Google account to use the "Forgot Password" feature effectively. This ensures seamless recovery and access to your account.

## DEMO VIDEO

Due to the large size, the demo video is available on YouTube:
[Watch the demo](https://www.youtube.com/watch?v=pyDXqJn1aO8)


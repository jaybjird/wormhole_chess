# Milestone 7: The Mobile Forge
**Goal:** Prepare and package the game for actual mobile devices. We will set up automated app store deployments and launch closed beta tests for iOS and Android to gather real-world performance data.

## Tasks (Future Issues)

### 1. iOS Platform Configuration
- Configure Xcode project settings (`packages/app/ios/Runner.xcworkspace`).
- Set up App Icons, Launch Screens, and required permissions (e.g., Internet access).
- Configure signing certificates and provisioning profiles for ad-hoc and TestFlight distribution.

### 2. Android Platform Configuration
- Configure Android project settings (`packages/app/android/app/build.gradle`).
- Set up App Icons, Splash Screens, and required permissions.
- Generate and configure release keystores.

### 3. Fastlane Integration & CI/CD
- Initialize `fastlane` in both iOS and Android directories.
- Write a Fastfile for iOS to automate TestFlight uploads via GitHub Actions.
- Write a Fastfile for Android to automate Google Play Console Internal Track uploads via GitHub Actions.
- Configure necessary secrets in the GitHub repository (certificates, API keys, keystore passwords).

### 4. Crash Reporting & Performance Monitoring
- Integrate Sentry (`sentry_flutter`) into `packages/app/pubspec.yaml`.
- Wrap the app's `runApp` with Sentry boundary to catch unhandled Dart exceptions.
- Ensure source maps/dSYM files are correctly uploaded during the Fastlane CI/CD build process for readable crash reports.

### 5. Closed Beta Launch & Feedback Loop
- Deploy the first mobile builds to TestFlight (iOS) and Internal Testing (Android).
- Distribute invites to a small group of alpha testers.
- Implement an in-app "Provide Feedback" or "Report Bug" button that sends data (potentially via Appwrite or a webhook) to the development team.

### 6. Mobile-Specific Polish
- Ensure safe area constraints are respected (avoiding notches and dynamic islands).
- Test and refine the drag-and-drop mechanics specifically for touch screens.
- Implement handling for app lifecycle state changes (e.g., pausing the game or socket connection when the app goes into the background).

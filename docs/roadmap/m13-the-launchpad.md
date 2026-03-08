# Milestone 13: The Launchpad
**Goal:** Formalize the production pipelines and successfully publish the compiled application to all major mobile and desktop storefronts. This milestone tracks the platform-specific code signing, metadata generation, and store review processes required to graduate from beta testing to public availability.

## Tasks (Future Issues)

### 1. App Store Metadata & Assets Generation
- Finalize the official App Name, Subtitle, and Description.
- Generate necessary marketing screenshots for various iOS and Android screen sizes (using a tool like `fastlane frameit` or dedicated screenshot generator).
- Create a compelling App Store Promo Video showcasing the wormhole mechanic.

### 2. Privacy Policy & Terms of Service
- Draft a comprehensive Privacy Policy (critical for Appwrite authentication and cloud sync).
- Draft a Terms of Service document.
- Host these documents publicly (e.g., on the Appwrite Sites web alpha domain or a dedicated landing page) and link them in the respective App Store consoles.

### 3. iOS App Store Submission (Production)
- Ensure all certificates and provisioning profiles are set to "Distribution / App Store".
- Run final production build (`flutter build ipa`).
- Use Fastlane `deliver` to upload binary and metadata to App Store Connect.
- Submit the app for official Apple Review and handle any feedback/rejections.

### 4. Google Play Store Submission (Production)
- Ensure the production Keystore is secure and properly configured.
- Run final production build (`flutter build appbundle`).
- Use Fastlane `supply` to upload the AAB and metadata to the Google Play Console.
- Promote the release from the Internal Testing track to Production and navigate the Google Play review process.

### 5. Desktop Platform Builds (macOS / Windows / Linux)
- Finalize platform-specific configurations for macOS, Windows, and Linux.
- Set up CI/CD workflows using GitHub Actions to compile native binaries for these platforms on every release tag.
- Implement auto-update mechanisms for desktop binaries (e.g., using `sparkle` for macOS or checking GitHub Releases via API).

### 6. Official Launch & Marketing
- Prepare a "v1.0 Release" announcement for social media, Reddit (r/chess variants, r/flutterdev), and relevant forums.
- Monitor Sentry closely post-launch to rapidly patch any day-one critical crashes.
- Celebrate the launch!

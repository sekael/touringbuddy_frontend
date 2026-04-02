## ADDED Requirements

### Requirement: Capture browser install prompt event
The app SHALL listen for the browser's `beforeinstallprompt` event via JavaScript interop. When the event fires, the app SHALL store the event reference and make it available to the Dart layer. The app SHALL call `preventDefault()` on the event to suppress the browser's default install banner.

#### Scenario: Install prompt event is captured
- **WHEN** the browser fires `beforeinstallprompt` (criteria met: HTTPS, manifest, service worker)
- **THEN** the app SHALL capture the event and suppress the default browser prompt

#### Scenario: Event is not fired on already-installed app
- **WHEN** the app is already installed as a PWA
- **THEN** the `beforeinstallprompt` event SHALL NOT fire and no install UI SHALL be shown

### Requirement: In-app install banner is shown to eligible users
The app SHALL display a Material-styled banner (using `MaterialBanner` or a custom widget) prompting the user to install the app. The banner SHALL appear after the `beforeinstallprompt` event is captured. The banner SHALL include:
- A brief message explaining the benefit of installing
- An "Install" action button
- A "Dismiss" action to close the banner

#### Scenario: Install banner appears when eligible
- **WHEN** the `beforeinstallprompt` event has been captured and the user has not previously dismissed the banner
- **THEN** an install banner SHALL be displayed in the app

#### Scenario: Install banner respects dismissal
- **WHEN** the user dismisses the install banner
- **THEN** the banner SHALL NOT appear again for the remainder of the session

### Requirement: Install action triggers browser install flow
When the user taps the "Install" button on the in-app banner, the app SHALL call `prompt()` on the stored `beforeinstallprompt` event to trigger the browser's native install dialog.

#### Scenario: Tapping install triggers native dialog
- **WHEN** the user taps "Install" on the in-app banner
- **THEN** the browser's native PWA install dialog SHALL appear

#### Scenario: Banner is hidden after install completes
- **WHEN** the user completes the install via the native dialog
- **THEN** the in-app install banner SHALL be removed

### Requirement: Install prompt only shown on web platform
The install prompt logic SHALL only execute when the app is running on the web platform (`kIsWeb`). On native platforms, the install prompt widget SHALL render nothing.

#### Scenario: No install prompt on native platforms
- **WHEN** the app is running on a native platform (iOS, Android)
- **THEN** no install prompt UI or JS interop SHALL be initialized

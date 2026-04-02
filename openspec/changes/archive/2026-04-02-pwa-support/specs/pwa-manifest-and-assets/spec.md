## ADDED Requirements

### Requirement: Web manifest contains complete app identity
The `web/manifest.json` SHALL include the following fields with correct values:
- `name`: "TouringBuddy"
- `short_name`: "TouringBuddy"
- `description`: A brief description of the app's purpose
- `start_url`: "/"
- `scope`: "/"
- `display`: "standalone"
- `theme_color`: The app's primary orange theme color
- `background_color`: The app's surface/background color
- `orientation`: "portrait-primary"
- `categories`: ["sports", "navigation", "travel"]

#### Scenario: Manifest is valid and complete
- **WHEN** the manifest is loaded by a browser
- **THEN** it SHALL contain all required fields with non-empty values and valid JSON structure

#### Scenario: Theme color matches app branding
- **WHEN** the app is installed on a device
- **THEN** the OS chrome (status bar, title bar) SHALL display the app's orange brand color

### Requirement: Full set of PWA icons at all recommended sizes
The `web/icons/` directory SHALL contain PNG icons at the following sizes: 72x72, 96x96, 128x128, 144x144, 152x152, 192x192, 384x384, 512x512. Each size SHALL have both a standard and a maskable variant. All icons SHALL be referenced in `manifest.json` with correct `src`, `sizes`, `type`, and `purpose` fields.

#### Scenario: All icon sizes are present
- **WHEN** a device requests an icon for the installed app
- **THEN** the manifest SHALL provide an icon matching or exceeding the requested size

#### Scenario: Maskable icons are available
- **WHEN** a platform requires a maskable icon (e.g., Android adaptive icons)
- **THEN** the manifest SHALL include at least one icon with `"purpose": "maskable"` at 192x192 and 512x512

### Requirement: Apple-specific meta tags for iOS install experience
The `web/index.html` SHALL include meta tags for iOS PWA support:
- `apple-mobile-web-app-capable` set to "yes"
- `apple-mobile-web-app-status-bar-style` set to "black-translucent"
- `apple-mobile-web-app-title` set to "TouringBuddy"
- `apple-touch-icon` linking to the 192x192 icon

#### Scenario: iOS home screen install
- **WHEN** a user adds the app to their iOS home screen
- **THEN** the app SHALL launch in standalone mode with the correct title and icon

### Requirement: Enhanced HTML meta tags for discoverability
The `web/index.html` SHALL include:
- `<meta name="description">` with a meaningful app description
- `<meta name="theme-color">` matching the manifest theme color
- Open Graph tags: `og:title`, `og:description`, `og:type`, `og:image`

#### Scenario: Social sharing shows branded preview
- **WHEN** the app URL is shared on a social platform
- **THEN** the platform SHALL display the app name, description, and icon from OG tags

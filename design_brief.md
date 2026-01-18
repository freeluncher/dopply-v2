
# Prompt: UI/UX Redesign - Soft & Organic Theme for Dopply

**Role**: You are a Senior Flutter UI/UX Engineer specialized in standard compliance medical apps with high emotional intelligence design.

**Context**: The app "Dopply" is a Fetal Monitor application connecting to BLE devices. We need to redesign the entire look and feel to balance  **Emotional Comfort**  (reducing anxiety) and  **Professional Trust**  (medical accuracy).

**Theme Specification: "Soft & Organic" (Soft Minimalist)**

1.  **Color Palette (Pastel & Calming)**:
    
    -   **Primary**:  `Soft Teal/Mint`  (e.g.,  `#64B6AC`  or  `#B0E0E6`) - Trust & Calm.
    -   **Secondary**:  `Peach/Warm Pink`  (e.g.,  `#FAD2E1`) - Warmth & Life.
    -   **Background**:  `Off-White/Cream`  (e.g.,  `#FDFBF7`) - Avoid clinical stark white.
    -   **Surface**:  `White (#FFFFFF)`  with soft shadows.
    -   **Error/Alert**:  `Soft Coral`  (e.g.,  `#F08080`) instead of aggressive red.
    -   **Text**:  `Dark Slate Grey`  (e.g.,  `#2F4858`) instead of pure black.
2.  **Typography**:
    
    -   **Font Family**:  `Quicksand`  or  `Nunito`  (Rounded Sans-Serif).
    -   **Hierarchy**: Bold rounded headers, legible body text.
3.  **Shape & Form**:
    
    -   **Border Radius**: Aggressive rounding (20dp to 30dp).
    -   **Shapes**: Use "Organic Blobs" or soft waves.

----------

## **Technical Requirement: Modularity & Customization**

**Goal**: The design system must be  **highly modular**  and  **easy to customize**  for future rebranding or white-labeling.

**1. Modular Structure (`lib/src/core/theme/`)**: Do not dump everything into one  `app_theme.dart`  file. Split logic into:

-   `app_colors.dart`: Define a  **primitive**  palette (e.g.,  `_DopplyTeal`,  `_DopplyPeach`) and a  **semantic**  palette (e.g.,  `primary`,  `warning`).
-   `app_typography.dart`: Define text styles separately using  `GoogleFonts`.
-   `app_styles.dart`: Define shared shapes, shadows, and spacing constants (e.g.,  `AppRadius.large`,  `AppShadows.soft`).
-   `app_theme.dart`: The main entry point that assembles these modules into  `ThemeData`.

**2. Theme Extensions (Advanced Customization)**: Use  `ThemeExtension`  to handle custom colors that don't fit into Material 3 slots.

-   Example:  `MedicalStatusColors`  (e.g.,  `fetalHeartRateNormal`,  `fetalHeartRateHigh`).
-   This allows us to access colors like  `Theme.of(context).extension<MedicalStatusColors>()!.normal`  anywhere in the app.

**3. Configuration Factory**: Implement a  `DopplyThemeConfig`  class that accepts a "Seed Color" and automatically generates the rest of the palette.

----------

## **⚠️ CRITICAL CONSTRAINTS (DO NOT BREAK FUNCTIONALITY)**

1.  **Logic Isolation**:
    
    -   **STRICTLY FORBIDDEN**  to modify any logic files (`controllers`,  `repositories`,  `providers`,  `services`).
    -   Only modify  `presentation`  (UI) files and  `theme`  files.
    -   Do not change variable names in the
        
        build()  methods that rely on state (e.g.,  `ref.watch(provider)`).
2.  **Widget Keys & IDs**:
    
    -   Do  **NOT**  remove or rename existing
        
        Key('...')  identifiers. These are crucial for automated testing.
    -   If wrapping a widget in a new container (e.g.,  `OrganicBackground`), ensure the
        
        Key  is preserved on the interactive element.
3.  **Accessibility (Medical Standard)**:
    
    -   Although using pastel colors,  **Contrast Ratio**  for text must remain >= 4.5:1 (WCAG AA).
    -   Do not make text too light (`Colors.grey[400]`  is often too hard to read). Use the defined  `Dark Slate Grey`  for primary text.
    -   Touch targets for vital buttons (like "Record Heart Rate") must be at least 48x48dp.

**Output Format**: Provide the code for the split files (`app_colors.dart`,  `app_theme.dart`, etc.) and the  `MedicalStatusColors`  extension class.
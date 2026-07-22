---
name: Stardust Stories
colors:
  surface: '#fbf9f6'
  surface-dim: '#dbdad7'
  surface-bright: '#fbf9f6'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f3f0'
  surface-container: '#efeeeb'
  surface-container-high: '#eae8e5'
  surface-container-highest: '#e4e2df'
  on-surface: '#1b1c1a'
  on-surface-variant: '#47464d'
  inverse-surface: '#30312f'
  inverse-on-surface: '#f2f0ed'
  outline: '#78767e'
  outline-variant: '#c9c5ce'
  surface-tint: '#5e5b79'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#1a1833'
  on-primary-container: '#8480a0'
  inverse-primary: '#c7c3e6'
  secondary: '#812dc6'
  on-secondary: '#ffffff'
  secondary-container: '#9c4be1'
  on-secondary-container: '#fffbff'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#2f1500'
  on-tertiary-container: '#c96b00'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e3dfff'
  primary-fixed-dim: '#c7c3e6'
  on-primary-fixed: '#1a1833'
  on-primary-fixed-variant: '#464460'
  secondary-fixed: '#f1daff'
  secondary-fixed-dim: '#dfb7ff'
  on-secondary-fixed: '#2d004f'
  on-secondary-fixed-variant: '#6a02b0'
  tertiary-fixed: '#ffdcc4'
  tertiary-fixed-dim: '#ffb77f'
  on-tertiary-fixed: '#2f1500'
  on-tertiary-fixed-variant: '#6f3900'
  background: '#fbf9f6'
  on-background: '#1b1c1a'
  surface-variant: '#e4e2df'
typography:
  display-lg:
    fontFamily: Literata
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Literata
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Literata
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Literata
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 32px
  body-md:
    fontFamily: Literata
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 28px
  label-sm:
    fontFamily: Literata
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.04em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container-max: 1120px
  gutter: 24px
  margin-mobile: 20px
  margin-desktop: 40px
---

## Brand & Style

This design system is crafted for a bedtime-inspired storytelling experience, focusing on comfort, wonder, and low eye-strain. The brand personality is whimsical yet grounded, aimed at families and readers seeking a serene digital environment before sleep. 

The aesthetic blends **Modern Minimalism** with **Tactile** elements. It utilizes deep, immersive tones contrasted against soft, paper-like surfaces to create a sense of depth and focus. The emotional response should be one of calm curiosity—evoking the feeling of reading a physical book under a soft lamp. High-quality whitespace and intentional focal points guide the user through narrative content without overstimulation.

## Colors

The palette is anchored by "Soft Sand," a warm, off-white background that reduces blue-light harshness. "Indigo Night" serves as the foundational anchor for typography and deep containers, providing high legibility and a nocturnal atmosphere. 

"Magic Lilac" acts as the primary interactive driver, used for calls to action and indicating "active" storytelling states. "Sunset Gold" is reserved for moments of delight, such as achievement badges, star ratings, or highlighting specific passages within a story.

## Typography

The design system exclusively uses **Literata** to maintain a scholarly yet inviting "bookish" feel. The type scale is generous, prioritizing readability and vertical rhythm. 

Headlines use heavier weights and tighter tracking to command attention, while body text utilizes a relaxed line height (1.6x to 1.8x) to ensure a comfortable reading flow. Labels and captions are set in semi-bold with increased letter spacing to ensure clarity at smaller scales. On mobile devices, display sizes are scaled down to prevent excessive line-breaking while maintaining their authoritative presence.

## Layout & Spacing

The layout follows a **Fixed Grid** model for long-form reading content on desktop to prevent line lengths from becoming too wide for comfortable tracking. A maximum container width of 1120px is enforced.

Spacing is based on an 8px square grid, ensuring consistent alignment of all UI elements. On mobile, margins are reduced to 20px to maximize real estate for text, while desktop layouts use 40px margins to breathe. Vertical rhythm is strictly maintained; spacing between paragraphs and sections should always be a multiple of the base 8px unit.

## Elevation & Depth

Hierarchy is established through **Tonal Layers** rather than heavy shadows. Components sit on "Soft Sand" backgrounds. Elevated elements like cards or modals use subtle, wide-spread shadows tinted with "Indigo Night" at very low opacity (4-6%) to suggest lift without appearing "dirty."

To create depth in a "bedtime" context, use semi-transparent overlays of Indigo Night for background dimming when modals are active. Interactive elements like buttons should feel tactile, using slight inner-glows or subtle gradients of "Magic Lilac" to signify they are pressable.

## Shapes

The shape language is defined by **ROUND_EIGHT** (0.5rem base), creating a soft, approachable, and safe environment. This moderate rounding applies to all standard containers, buttons, and input fields.

Large layout sections or featured story cards utilize `rounded-xl` (1.5rem) to emphasize their role as primary content buckets. Interactive chips and tags use a fully pill-shaped radius to distinguish them from structural elements.

## Components

- **Buttons:** Primary buttons are filled with "Magic Lilac" with white or high-contrast text. They utilize a 0.5rem corner radius. Secondary buttons use an "Indigo Night" outline.
- **Story Cards:** Cards use a white or slightly lighter tint of "Soft Sand" with a subtle 1px border of "Indigo Night" at 10% opacity. They feature `rounded-xl` corners.
- **Inputs:** Text fields use a "Soft Sand" fill with an "Indigo Night" bottom border or thin outline. Focus states transition the border to "Magic Lilac."
- **Badges/Chips:** Use "Sunset Gold" for celebratory badges (e.g., "New Story," "Completed"). These should be pill-shaped.
- **Lists:** List items are separated by generous whitespace and thin horizontal dividers in 10% "Indigo Night."
- **Progress Bars:** For reading progress, use a "Soft Sand" track with a "Magic Lilac" fill to indicate completion percentage.
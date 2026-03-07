import SwiftUI

// ═══════════════════════════════════════════════════════════════
// MARK: – habitOS Design System
// Brand Manual: "Lujo silencioso" — Vanilla · Ink · Sage · Line
// Tipografía: Georgia (serif) + SF Pro (sistema)
// ═══════════════════════════════════════════════════════════════

extension Color {
    // MARK: – Core Palette (Brand Manual)
    /// Vanilla — #F6F3EE — fondo base de toda la app
    static let hbVanilla  = Color(red: 246/255, green: 243/255, blue: 238/255)
    /// Paper — #FEFDFB — fondo de cards (blanco cálido, no puro)
    static let hbPaper    = Color(red: 254/255, green: 253/255, blue: 251/255)
    /// Ink — #1C1D1A — texto principal
    static let hbInk      = Color(red: 28/255,  green: 29/255,  blue: 26/255)
    /// Sage — #6F7C68 — acento único, verde botánico
    static let hbSage     = Color(red: 111/255, green: 124/255, blue: 104/255)
    /// Line — #DCD8CF — bordes, divisores
    static let hbLine     = Color(red: 220/255, green: 216/255, blue: 207/255)

    // MARK: – Derived Tokens
    /// Ink al 86% — cuerpo de texto
    static let hbInk86    = Color(red: 28/255, green: 29/255, blue: 26/255).opacity(0.86)
    /// Ink al 68% — texto muted
    static let hbMuted    = Color(red: 28/255, green: 29/255, blue: 26/255).opacity(0.68)
    /// Ink al 52% — texto terciario / muted2
    static let hbMuted2   = Color(red: 28/255, green: 29/255, blue: 26/255).opacity(0.52)
    /// Sage sutil — fondos de badges/callouts
    static let hbSageBg   = Color(red: 111/255, green: 124/255, blue: 104/255).opacity(0.10)

    // MARK: – Backward Compatibility Aliases
    static let hbBackground       = hbVanilla
    static let hbSurface          = hbPaper
    static let hbSurfaceSecondary = hbVanilla
    static let hbAccent           = hbSage
    static let hbTextPrimary      = hbInk
    static let hbTextSecondary    = Color(red: 28/255, green: 29/255, blue: 26/255).opacity(0.68)
    static let hbTextTertiary     = Color(red: 28/255, green: 29/255, blue: 26/255).opacity(0.52)
    static let hbBorder           = hbLine
}

// MARK: – Design Tokens (spacing, radius, shadow)
enum HBTokens {
    static let radiusLarge: CGFloat  = 18   // Cards, modals
    static let radiusMedium: CGFloat = 14   // Buttons, badges, inputs
    static let radiusSmall: CGFloat  = 8    // Small pills

    static let padCard: CGFloat      = 22   // Internal card padding
    static let padScreen: CGFloat    = 20   // Horizontal screen padding
    static let sectionGap: CGFloat   = 28   // Between sections
}

// MARK: – Typography Helpers
extension Font {
    /// Serif headline — Georgia (closest iOS built-in to Playfair Display)
    static func hbSerif(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("Georgia", size: size).weight(weight)
    }
    /// Serif bold — Georgia Bold
    static func hbSerifBold(_ size: CGFloat) -> Font {
        .custom("Georgia-Bold", size: size)
    }
    /// Serif italic — Georgia Italic (for "OS" in logo)
    static func hbSerifItalic(_ size: CGFloat) -> Font {
        .custom("Georgia-Italic", size: size)
    }
    /// Kicker — system uppercase with tracking
    static func hbKicker(_ size: CGFloat = 10.5) -> Font {
        .system(size: size, weight: .semibold)
    }
}

// MARK: – Staggered Animation (disabled — was causing flicker)
extension View {
    /// Previously applied a staggered fade-in + slide animation.
    /// Disabled because it caused visible flickering on tab switches.
    /// Views now appear instantly.
    func staggered(index: Int) -> some View {
        self // no-op: content shown instantly
    }
}


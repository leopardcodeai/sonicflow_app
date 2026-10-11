// Copied from brand/generated/BrandTokens.swift — regenerate via node scripts/brand/generate-tokens.mjs
// Version: 0.1.0

import SwiftUI

public enum BrandTokens {
  public enum Chakra {
    public static let root = Color(hex: "#C73D3D")
    public static let sacral = Color(hex: "#E67E22")
    public static let solar = Color(hex: "#F5C518")
    public static let heart = Color(hex: "#1D9E75")
    public static let throat = Color(hex: "#378ADD")
    public static let thirdEye = Color(hex: "#7F77DD")
    public static let crown = Color(hex: "#534AB7")
  }

  public enum Neutral {
    public static let ink = Color(hex: "#0A0A0B")
    public static let bg = Color(hex: "#0F0F12")
    public static let border = Color(hex: "#2A2434")
    public static let fg = Color(hex: "#F5F7FB")
    public static let muted = Color(hex: "#8E97A8")
    public static let panel = Color.black.opacity(0.78)
  }

  public enum Accent {
    public static let gold = Color(hex: "#D4A24C")
    public static let spotRing = Color(hex: "#6B4B1F")
    public static let success = Color(hex: "#3CCF91")
    public static let danger = Color(hex: "#E0484D")
  }

  public enum Mode {
    public static let focus = Color(hex: "#378ADD")
    public static let flow = Color(hex: "#7F77DD")
    public static let meditation = Color(hex: "#1D9E75")
    public static let sleep = Color(hex: "#534AB7")
  }

  public enum Radius {
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 14
    public static let lg: CGFloat = 20
    public static let pill: CGFloat = 999
  }

  public enum Spacing {
    public static let xs: CGFloat = 4
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 14
    public static let lg: CGFloat = 20
    public static let xl: CGFloat = 32
  }

  public enum Leopard {
    public static let base = Color(hex: "#0F0F12")
    public static let spot = Color(hex: "#D4A24C")
    public static let ring = Color(hex: "#6B4B1F")
    public static let opacity: Double = 0.14
    public static let blurRadius: CGFloat = 2
    public static let spotCount: Int = 24
    public static let spotMinPx: CGFloat = 14
    public static let spotMaxPx: CGFloat = 44
  }
}

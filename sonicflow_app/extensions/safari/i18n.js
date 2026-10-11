const COPY = {
  en: {
    active: "Active",
    activity: "Activity",
    activityCopy: "Choose a one-click session path. Flow now powers Creative Flow inside Focus.",
    ambientMix: "Ambient mix",
    beatVolume: "Beat volume",
    checkingMedia: "Checking current tab for YouTube or SoundCloud media...",
    cleanAmbience: "clean ambience",
    detectedDoc: "Detected · Writing Doc",
    duration: "Duration",
    highPulse: "high pulse",
    layerCopy: "Layer SonicFlow under supported media while keeping native-only capture paths explicit.",
    off: "Off",
    open: "open",
    overlayMode: "Overlay Mode",
    pulseDepth: "Pulse depth",
    softPulse: "soft pulse",
    start: "Start SonicFlow",
    starterSessions: "Starter Sessions",
    stop: "Stop SonicFlow",
    suggested: "Suggested",
    unavailable: "Unavailable",
    untilStopped: "Until stopped",
    warmAmbience: "warm ambience"
  },
  de: {
    active: "Aktiv",
    activity: "Aktivitat",
    activityCopy: "Wahle einen One-Click-Session-Pfad. Flow steuert Creative Flow innerhalb von Fokus.",
    ambientMix: "Ambient-Mix",
    beatVolume: "Beat-Lautstarke",
    checkingMedia: "Prufe den aktuellen Tab auf YouTube- oder SoundCloud-Medien...",
    cleanAmbience: "klare ambience",
    detectedDoc: "Erkannt · Schreibdokument",
    duration: "Dauer",
    highPulse: "hoher puls",
    layerCopy: "Lege SonicFlow unter unterstutzte Medien und halte native Capture-Pfade explizit.",
    off: "Aus",
    open: "offen",
    overlayMode: "Overlay-Modus",
    pulseDepth: "Puls-Tiefe",
    softPulse: "sanfter puls",
    start: "SonicFlow starten",
    starterSessions: "Starter-Sessions",
    stop: "SonicFlow stoppen",
    suggested: "Vorschlag",
    unavailable: "Nicht verfugbar",
    untilStopped: "Bis zum Stoppen",
    warmAmbience: "warme ambience"
  }
};

const LABELS = {
  de: {
    Focus: "Fokus",
    Flow: "Flow",
    Meditation: "Meditation",
    Sleep: "Schlaf",
    "Sharpens attention for deep work.": "Scharft Aufmerksamkeit fur Deep Work.",
    "Balances calm and creative momentum.": "Balanciert Ruhe und kreativen Schwung.",
    "Soft theta pacing for inward focus.": "Sanftes Theta-Pacing fur inneren Fokus.",
    "Slow down gently toward rest.": "Sanft langsamer werden in Richtung Ruhe.",
    "Focus Primer": "Fokus-Primer",
    "5 min gamma warmup": "5 min Gamma-Warmup",
    "Flow Reset": "Flow-Reset",
    "5 min alpha reset": "5 min Alpha-Reset",
    "Night Drift": "Night Drift",
    "5 min delta wind-down": "5 min Delta-Wind-down",
    "Deep Work": "Deep Work",
    "Creative Flow": "Kreativer Flow",
    "Light Work": "Leichte Arbeit",
    Learning: "Lernen",
    Motivation: "Motivation",
    Unwind: "Runterkommen",
    Destress: "Stress loslassen",
    Recharge: "Aufladen",
    Chill: "Chillen",
    "Deep Sleep": "Tiefschlaf",
    "Wind Down": "Runterfahren",
    "Power Nap": "Powernap",
    "Guided Sleep": "Gefuhrter Schlaf",
    "Guided Meditation": "Gefuhrte Meditation",
    "Unguided Meditation": "Freie Meditation",
    Pomodoro: "Pomodoro",
    Short: "Kurz",
    Standard: "Standard",
    "Power nap": "Powernap",
    "Infinite sleep": "Unendlicher Schlaf",
    "Browser tab": "Browser-Tab",
    Available: "Verfugbar",
    "macOS system": "macOS-System",
    "Native app": "Native App",
    "iOS local": "iOS lokal",
    "Local only": "Nur lokal",
    "Overlay ready for this browser tab.": "Overlay ist fur diesen Browser-Tab bereit.",
    "Open YouTube, SoundCloud, or another supported media tab first.": "Offne zuerst YouTube, SoundCloud oder einen anderen unterstutzten Media-Tab."
  }
};

export function resolveLanguage(environment = globalThis) {
  const candidates = [
    environment?.navigator?.language,
    ...(environment?.navigator?.languages ?? [])
  ].filter(Boolean);
  return candidates.some((language) => String(language).toLowerCase().startsWith("de")) ? "de" : "en";
}

export function createTranslator(environment = globalThis) {
  const language = resolveLanguage(environment);
  const copy = COPY[language] ?? COPY.en;

  return {
    language,
    t(key) {
      return copy[key] ?? COPY.en[key] ?? key;
    },
    label(value) {
      if (language === "de") {
        return LABELS.de[value] ?? value;
      }
      return value;
    }
  };
}

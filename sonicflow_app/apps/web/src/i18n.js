export const SUPPORTED_LANGUAGES = ["en", "de"];

const COPY = {
  en: {
    active: "Active",
    attentionSupport: "Attention support",
    browserApiReview: "Browser API review",
    claimAllowed: "Claim allowed",
    claimBlocked: "Claim blocked",
    defaultIntensity: "Default intensity",
    distractible: "Distractible",
    duration: "Duration",
    efficacyRequest: "efficacy",
    extensionRequired: "Extension required",
    focusCheck: "Focus check",
    focusPattern: "Focus pattern",
    genre: "Genre",
    goodAfternoon: "good afternoon, sam",
    home: "Home",
    library: "Library",
    libraryFilters: "Library filters",
    localOnlySync: "local-only sync",
    neuralIntensity: "Neural intensity",
    off: "Off",
    openEnded: "open-ended",
    orStartFresh: "Or start fresh",
    overlayMode: "Overlay Mode",
    pickUpWhereLeftOff: "Pick up where you left off",
    player: "Player",
    productModes: "Product modes",
    profile: "Profile",
    pulseDepth: "Pulse depth",
    ready: "Ready",
    recentSessions: "Recent sessions",
    researchCondition: "Research condition",
    researchGate: "Research gate",
    resume: "resume",
    pause: "pause",
    searchSessions: "search sessions, genres, presets...",
    searchSessionsLabel: "Search sessions",
    sensitivity: "Sensitivity",
    session: "session",
    sessionHistoryCopy: "Session history and streak trends stay aligned with the redesign while deeper analytics remain lightweight in this local build.",
    sonicFlowSections: "SonicFlow sections",
    stats: "Stats",
    statusLive: "Live",
    statusReady: "Ready",
    subjectiveFeedback: "Subjective efficacy feedback",
    thisWeek: "This week",
    untilStopped: "until stopped",
    viewAll: "View all",
    volume: "Volume",
    whatFocusToday: "what's the focus today?",
    yourLibrary: "Your Library"
  },
  de: {
    active: "Aktiv",
    attentionSupport: "Aufmerksamkeits-Support",
    browserApiReview: "Browser-API-Prufung",
    claimAllowed: "Claim erlaubt",
    claimBlocked: "Claim blockiert",
    defaultIntensity: "Standardintensitat",
    distractible: "Leicht ablenkbar",
    duration: "Dauer",
    efficacyRequest: "efficacy",
    extensionRequired: "Extension erforderlich",
    focusCheck: "Fokus-Check",
    focusPattern: "Fokusmuster",
    genre: "Genre",
    goodAfternoon: "guten nachmittag, sam",
    home: "Home",
    library: "Bibliothek",
    libraryFilters: "Bibliotheksfilter",
    localOnlySync: "nur lokal synchronisiert",
    neuralIntensity: "Neurale Intensitat",
    off: "Aus",
    openEnded: "offen",
    orStartFresh: "Oder frisch starten",
    overlayMode: "Overlay-Modus",
    pickUpWhereLeftOff: "Da weitermachen, wo du aufgehort hast",
    player: "Player",
    productModes: "Produktmodi",
    profile: "Profil",
    pulseDepth: "Puls-Tiefe",
    ready: "Bereit",
    recentSessions: "Letzte Sessions",
    researchCondition: "Research-Bedingung",
    researchGate: "Research-Gate",
    resume: "weiter",
    pause: "pause",
    searchSessions: "sessions, genres, presets suchen...",
    searchSessionsLabel: "Sessions suchen",
    sensitivity: "Sensibilitat",
    session: "Session",
    sessionHistoryCopy: "Session-Verlauf und Streak-Trends bleiben am Redesign ausgerichtet; tiefere Analytics bleiben in diesem lokalen Build leichtgewichtig.",
    sonicFlowSections: "SonicFlow Bereiche",
    stats: "Statistik",
    statusLive: "Live",
    statusReady: "Bereit",
    subjectiveFeedback: "Subjektives Wirksamkeitsfeedback",
    thisWeek: "Diese Woche",
    untilStopped: "bis zum Stoppen",
    viewAll: "Alle ansehen",
    volume: "Lautstarke",
    whatFocusToday: "was ist heute der fokus?",
    yourLibrary: "Deine Bibliothek"
  }
};

const LABELS = {
  de: {
    Focus: "Fokus",
    Relax: "Entspannen",
    Sleep: "Schlaf",
    Meditate: "Meditieren",
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
    low: "niedrig",
    medium: "mittel",
    high: "hoch",
    off: "aus",
    modulated: "moduliert",
    control: "kontrolle",
    "Deep work": "Deep Work",
    "ADHD self-reported": "ADHS selbst berichtet",
    Gentle: "Sanft",
    Balanced: "Ausgewogen",
    Strong: "Stark",
    "Steady Focus": "Stabiler Fokus"
  }
};

export function resolveLanguage(environment = globalThis) {
  const candidates = [
    environment?.navigator?.language,
    ...(environment?.navigator?.languages ?? [])
  ].filter(Boolean);
  const detected = candidates.find((language) => normalizeLanguage(language) === "de");
  return detected ? "de" : "en";
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
    },
    lowerLabel(value) {
      return this.label(value).toLowerCase();
    }
  };
}

function normalizeLanguage(language) {
  return String(language).slice(0, 2).toLowerCase();
}

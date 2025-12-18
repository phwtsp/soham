
export interface Session {
  id: string;
  name: string;
  duration: string;
  time: string;
  date: string;
  icon: string;
}

export interface BreathingPattern {
  id: string;
  name: string;
  inhale: number;
  hold?: number;
  exhale: number;
  description: string;
  active?: boolean;
}

export type Screen = 'login' | 'dashboard' | 'patterns' | 'create' | 'player' | 'premium' | 'finished' | 'settings' | 'profile';

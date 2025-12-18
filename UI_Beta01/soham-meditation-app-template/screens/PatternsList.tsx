
import React from 'react';
import { useNavigate } from 'react-router-dom';
import { BreathingPattern } from '../types';

const patterns: BreathingPattern[] = [
  { id: '1', name: 'Relaxamento 4-7-8', inhale: 4, hold: 7, exhale: 8, description: 'Induz relaxamento profundo e sono.', active: true },
  { id: '2', name: 'Box Breathing', inhale: 4, hold: 4, exhale: 4, description: 'Foco e clareza mental extrema.' },
  { id: '3', name: 'Equilíbrio', inhale: 4, exhale: 4, description: 'Restaura a calma natural.' },
  { id: '4', name: 'Energia Matinal', inhale: 6, exhale: 2, description: 'Ativação rápida do corpo e mente.' },
];

const PatternsList: React.FC = () => {
  const navigate = useNavigate();

  return (
    <div className="bg-brand-blue h-screen w-full flex flex-col relative text-white overflow-hidden">
      <div className="flex items-center justify-between p-6 pt-12 pb-2 z-20 shrink-0">
        <button onClick={() => navigate('/dashboard')} className="flex items-center justify-center size-10 rounded-full hover:bg-white/10">
          <span className="material-symbols-outlined">arrow_back</span>
        </button>
        <h1 className="text-xl font-bold tracking-tight text-center flex-1 pr-8">Padrões de Respiração</h1>
      </div>

      <div className="flex-1 overflow-y-auto no-scrollbar px-4 pt-2 pb-32 space-y-4">
        <p className="text-brand-green/80 text-sm px-2 mb-2 font-medium">Escolha um ritmo para começar sua prática</p>
        
        {patterns.map(pattern => (
          <div 
            key={pattern.id} 
            onClick={() => navigate('/player')}
            className={`relative w-full rounded-[2rem] p-5 shadow-lg cursor-pointer transform transition-all active:scale-[0.98] ${pattern.active ? 'bg-brand-green text-brand-blue' : 'bg-white/5 border border-white/5 text-white'}`}
          >
            <div className="flex justify-between items-start mb-3">
              <div className="flex flex-col">
                {pattern.active && <span className="text-[10px] uppercase font-bold tracking-widest opacity-60 mb-1">Selecionado</span>}
                <h3 className="text-xl font-bold leading-tight">{pattern.name}</h3>
              </div>
              {pattern.active && (
                <div className="size-6 rounded-full border-2 border-brand-blue/20 flex items-center justify-center bg-white/20">
                  <div className="size-3 bg-brand-blue rounded-full"></div>
                </div>
              )}
            </div>
            
            <p className={`text-sm leading-snug mb-4 pr-4 ${pattern.active ? 'text-brand-blue/80' : 'text-white/60'}`}>{pattern.description}</p>
            
            <div className="flex items-center gap-1.5 opacity-80 mb-2">
              <div className={`h-1.5 rounded-full ${pattern.active ? 'bg-brand-blue/80' : 'bg-white/40'}`} style={{flex: pattern.inhale}}></div>
              {pattern.hold && <div className={`h-1.5 rounded-full ${pattern.active ? 'bg-brand-blue/60' : 'bg-white/20'}`} style={{flex: pattern.hold}}></div>}
              <div className={`h-1.5 rounded-full ${pattern.active ? 'bg-brand-blue/40' : 'bg-white/10'}`} style={{flex: pattern.exhale}}></div>
            </div>
          </div>
        ))}
      </div>

      <div className="absolute bottom-0 left-0 right-0 p-6 pb-8 bg-gradient-to-t from-brand-blue to-transparent z-30 flex justify-center">
        <button onClick={() => navigate('/create')} className="w-full h-14 bg-brand-green text-brand-blue rounded-full font-bold text-base flex items-center justify-center gap-2 shadow-xl hover:brightness-105 active:scale-[0.98] transition-all">
          <span className="material-symbols-outlined">add_circle</span>
          Adicionar Personalizada
        </button>
      </div>
    </div>
  );
};

export default PatternsList;

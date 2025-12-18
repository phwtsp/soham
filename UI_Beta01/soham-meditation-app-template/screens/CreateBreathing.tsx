
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';

const CreateBreathing: React.FC = () => {
  const navigate = useNavigate();
  const [inhale, setInhale] = useState(4);
  const [hold, setHold] = useState(2);
  const [exhale, setExhale] = useState(6);

  const total = inhale + hold + exhale;

  return (
    <div className="bg-white min-h-screen flex flex-col relative shadow-2xl">
      <header className="flex items-center justify-between px-6 pt-12 pb-4 z-10 sticky top-0 bg-white">
        <button onClick={() => navigate(-1)} className="flex size-10 shrink-0 items-center justify-center rounded-full hover:bg-brand-green/20 text-brand-blue">
          <span className="material-symbols-outlined text-[28px]">arrow_back</span>
        </button>
        <h1 className="text-brand-blue text-lg font-bold flex-1 text-center">Criar Respiração</h1>
        <div className="size-10"></div>
      </header>

      <main className="flex-1 flex flex-col px-6 pb-24 overflow-y-auto">
        <div className="mt-4 mb-8">
          <label className="block">
            <span className="block text-sm font-semibold text-brand-blue/70 mb-2 ml-1 uppercase">Nome do Padrão</span>
            <div className="relative flex items-center">
              <input className="w-full bg-brand-green/30 text-brand-blue placeholder:text-brand-blue/40 rounded-2xl border-0 py-4 px-5 text-lg font-medium focus:ring-2 focus:ring-brand-blue transition-all" defaultValue="Respiração Matinal" type="text"/>
              <span className="material-symbols-outlined absolute right-4 text-brand-blue/40">edit</span>
            </div>
          </label>
        </div>

        {/* Visualizer Card */}
        <div className="w-full aspect-[4/3] bg-brand-blue rounded-3xl relative overflow-hidden mb-8 shadow-lg">
          <div className="absolute inset-0 opacity-40 mix-blend-overlay bg-cover bg-center" style={{backgroundImage: 'url("https://picsum.photos/seed/abstract/600/400")'}}></div>
          <div className="absolute inset-0 flex flex-col items-center justify-center p-6">
            <div className="relative size-40 flex items-center justify-center">
              <div className="absolute inset-0 rounded-full border-[6px] border-brand-green/20"></div>
              <svg className="absolute inset-0 size-full -rotate-90 transform" viewBox="0 0 100 100">
                <circle cx="50" cy="50" fill="none" r="46" stroke="#f9f506" strokeDasharray="289" strokeDashoffset={289 * (1 - total/20)} strokeLinecap="round" strokeWidth="6"></circle>
              </svg>
              <div className="flex flex-col items-center justify-center bg-white/10 backdrop-blur-sm rounded-full size-28 shadow-inner border border-white/10">
                <span className="text-3xl font-bold text-white">{total}s</span>
                <span className="text-xs font-medium text-brand-green uppercase tracking-widest">Ciclo</span>
              </div>
            </div>
            <div className="mt-6 flex items-center gap-2 px-4 py-1.5 rounded-full bg-white/10 backdrop-blur-md border border-white/10">
              <span className="material-symbols-outlined text-brand-green text-sm">graphic_eq</span>
              <p className="text-brand-green text-sm font-medium">Visualização Dinâmica</p>
            </div>
          </div>
        </div>

        {/* Sliders */}
        <div className="flex flex-col gap-6">
          {[
            { label: 'Tempo Inspirar', val: inhale, set: setInhale, icon: 'air' },
            { label: 'Tempo Segurar', val: hold, set: setHold, icon: 'pause_circle' },
            { label: 'Tempo Expirar', val: exhale, set: setExhale, icon: 'air' },
          ].map((slider, i) => (
            <div key={i} className="bg-white rounded-2xl p-4 shadow-sm border border-slate-100">
              <div className="flex items-center justify-between mb-3">
                <div className="flex items-center gap-2">
                  <span className={`material-symbols-outlined text-brand-blue ${slider.label.includes('Expirar') ? '-scale-x-100' : ''}`}>{slider.icon}</span>
                  <span className="text-brand-blue font-bold text-base">{slider.label}</span>
                </div>
                <span className="text-2xl font-bold text-brand-blue tabular-nums">{slider.val}s</span>
              </div>
              <input 
                type="range" min="0" max="10" 
                value={slider.val} 
                onChange={(e) => slider.set(Number(e.target.value))}
                className="w-full h-3 bg-brand-green/40 rounded-full appearance-none cursor-pointer accent-brand-blue"
              />
            </div>
          ))}
        </div>
      </main>

      <div className="absolute bottom-0 left-0 w-full bg-white/80 backdrop-blur-lg border-t border-brand-blue/5 p-6 z-20">
        <button onClick={() => navigate('/patterns')} className="w-full bg-brand-blue text-white h-14 rounded-full font-bold text-lg shadow-lg active:scale-[0.98] transition-all flex items-center justify-center gap-2">
          <span className="material-symbols-outlined">check_circle</span>
          Salvar Padrão
        </button>
      </div>
    </div>
  );
};

export default CreateBreathing;


import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';

const Player: React.FC = () => {
  const navigate = useNavigate();
  const [stage, setStage] = useState<'Inale' | 'Segure' | 'Exale'>('Inale');
  const [seconds, setSeconds] = useState(4);
  const [scale, setScale] = useState(1);

  useEffect(() => {
    const interval = setInterval(() => {
      setSeconds((prev) => {
        if (prev <= 1) {
          if (stage === 'Inale') {
            setStage('Segure');
            return 7;
          } else if (stage === 'Segure') {
            setStage('Exale');
            return 8;
          } else {
            setStage('Inale');
            return 4;
          }
        }
        return prev - 1;
      });
    }, 1000);

    return () => clearInterval(interval);
  }, [stage]);

  useEffect(() => {
    if (stage === 'Inale') setScale(1.4);
    if (stage === 'Exale') setScale(1.0);
  }, [stage]);

  return (
    <div className="bg-brand-blue h-screen w-full flex flex-col relative text-white overflow-hidden">
      {/* Top Bar */}
      <div className="flex items-center justify-between p-6 pt-12 absolute top-0 w-full z-30">
        <h2 className="text-white text-xl font-bold opacity-90 pl-1">Soham</h2>
        <button onClick={() => navigate('/dashboard')} className="flex size-10 items-center justify-center rounded-full bg-white/10 backdrop-blur-md">
          <span className="material-symbols-outlined" style={{fontSize: '24px'}}>close</span>
        </button>
      </div>

      {/* Main Visualizer */}
      <div className="flex-1 flex flex-col items-center justify-center relative w-full">
        <div className="relative flex items-center justify-center mb-12">
          <div className="absolute size-[340px] rounded-full border border-brand-green/10 opacity-30 animate-pulse"></div>
          <div className="absolute size-[300px] rounded-full border border-brand-green/20 opacity-50"></div>
          
          <div 
            className="relative size-[250px] rounded-full bg-gradient-to-br from-[#0A5A8A] to-brand-blue shadow-[0_0_60px_rgba(209,233,222,0.15)] flex items-center justify-center overflow-hidden border border-white/10 transition-transform duration-[4000ms] ease-in-out"
            style={{ transform: `scale(${scale})` }}
          >
            <div className="absolute inset-0 opacity-40 mix-blend-overlay bg-cover bg-center" style={{backgroundImage: 'url("https://picsum.photos/seed/texture/500/500")'}}></div>
            <div className="relative z-10 flex flex-col items-center">
              <span className="text-white text-7xl font-light tracking-tighter">{seconds}<span className="text-3xl text-brand-green/80 ml-1">s</span></span>
            </div>
          </div>
        </div>

        <div className="flex flex-col gap-3 text-center z-10 px-6">
          <h1 className="text-white tracking-wide text-5xl font-bold drop-shadow-lg">{stage}</h1>
          <p className="text-brand-green/80 text-lg font-medium">
            {stage === 'Inale' ? 'Profundamente pelo nariz' : stage === 'Segure' ? 'Mantenha o ar nos pulmões' : 'Lentamente pela boca'}
          </p>
        </div>
      </div>

      {/* Controls */}
      <div className="flex flex-col items-center justify-end pb-[90px] w-full z-20 gap-6">
        <button onClick={() => navigate('/finished')} className="flex items-center gap-2 px-6 py-2 rounded-full text-white/70 hover:bg-white/10 transition-all">
          <span className="material-symbols-outlined icon-filled">stop_circle</span>
          <span className="text-sm font-bold tracking-widest uppercase">Finalizar</span>
        </button>

        <div className="flex px-6 justify-center w-full">
          <div className="flex w-full max-w-[400px] items-center justify-between rounded-2xl h-[72px] bg-brand-green text-brand-blue pl-6 pr-3 shadow-xl">
            <div className="flex flex-col items-start gap-1">
              <span className="text-[10px] uppercase font-extrabold tracking-widest opacity-60">Padrão Atual</span>
              <span className="truncate text-lg font-bold">4-7-8 Relaxamento</span>
            </div>
            <div className="size-12 rounded-xl bg-brand-blue/10 flex items-center justify-center">
              <span className="material-symbols-outlined">chevron_right</span>
            </div>
          </div>
        </div>
      </div>

      {/* Ad Space */}
      <div className="absolute bottom-0 left-0 right-0 h-[60px] bg-[#05324d]/90 border-t border-white/5 flex items-center justify-center z-50 backdrop-blur-md">
        <span className="text-white/40 text-[10px] font-bold tracking-widest uppercase">Publicidade</span>
      </div>
    </div>
  );
};

export default Player;


import React from 'react';
import { useNavigate } from 'react-router-dom';

const Finished: React.FC = () => {
  const navigate = useNavigate();

  return (
    <div className="bg-background-light flex flex-col min-h-screen justify-between overflow-hidden">
      <div className="flex items-center justify-end px-6 pt-12">
        <button onClick={() => navigate('/dashboard')} className="p-2 rounded-full text-brand-blue hover:bg-black/5">
          <span className="material-symbols-outlined text-[28px]">close</span>
        </button>
      </div>

      <div className="flex-1 flex flex-col items-center px-6 -mt-8 justify-center">
        <div className="relative w-full max-w-[280px] aspect-square mb-6">
          <div className="absolute inset-0 bg-brand-mint/30 rounded-full blur-2xl scale-90"></div>
          <div className="relative w-full h-full bg-center bg-contain bg-no-repeat" style={{backgroundImage: 'url("https://picsum.photos/seed/zen_art/400/400")'}}></div>
          <div className="absolute -bottom-2 right-4 bg-brand-blue text-white p-3 rounded-full shadow-lg">
            <span className="material-symbols-outlined text-[32px]">check</span>
          </div>
        </div>

        <div className="flex flex-col items-center text-center space-y-2 mb-8">
          <h1 className="text-brand-blue text-[32px] font-bold">Sessão Concluída</h1>
          <p className="text-brand-blue/70 text-base max-w-[280px]">
            Parabéns pelo seu momento de paz. Sua mente está mais calma agora.
          </p>
        </div>

        <div className="w-full max-w-sm bg-white border border-brand-mint/50 rounded-xl p-6 shadow-sm flex items-center justify-between">
          <div className="flex items-center gap-4">
            <div className="bg-brand-mint/30 p-3 rounded-full text-brand-blue">
              <span className="material-symbols-outlined">timer</span>
            </div>
            <div className="flex flex-col">
              <span className="text-brand-blue/60 text-sm font-medium">Tempo Focado</span>
              <span className="text-brand-blue text-xl font-bold">5 minutos</span>
            </div>
          </div>
          <span className="material-symbols-outlined text-primary text-[24px]">verified</span>
        </div>
      </div>

      <div className="w-full flex flex-col gap-3 px-6 pb-12 pt-4 bg-gradient-to-t from-background-light via-background-light">
        <button onClick={() => navigate('/dashboard')} className="flex w-full items-center justify-center rounded-full h-14 bg-brand-blue text-white text-lg font-bold shadow-md active:scale-95 transition-all">
          <span className="material-symbols-outlined mr-2">cloud_upload</span>
          Salvar Progresso na Nuvem
        </button>
        <button onClick={() => navigate('/dashboard')} className="flex w-full items-center justify-center rounded-full h-12 bg-transparent text-brand-blue font-medium hover:bg-brand-blue/5 transition-colors">
          Ver Dashboard
        </button>
      </div>
    </div>
  );
};

export default Finished;

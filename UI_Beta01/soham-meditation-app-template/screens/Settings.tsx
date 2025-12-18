
import React from 'react';
import { useNavigate } from 'react-router-dom';

const Settings: React.FC = () => {
  const navigate = useNavigate();

  return (
    <div className="bg-brand-blue h-screen w-full overflow-hidden text-white flex flex-col">
      <div className="flex items-center gap-4 p-6 pt-12 border-b border-white/5 bg-brand-blue/95 backdrop-blur-md">
        <button onClick={() => navigate(-1)} className="size-10 flex items-center justify-center hover:bg-white/10 rounded-full">
          <span className="material-symbols-outlined">arrow_back</span>
        </button>
        <h2 className="text-xl font-bold">Configurações</h2>
      </div>

      <div className="flex-1 overflow-y-auto w-full px-6 py-6">
        <div className="flex flex-col gap-8 pb-10">
          
          <div className="flex flex-col gap-4">
            <h3 className="text-brand-green/70 text-xs font-bold tracking-widest uppercase pl-2">Geral</h3>
            <div className="bg-white/5 rounded-3xl overflow-hidden border border-white/10 divide-y divide-white/5">
              <div className="flex items-center justify-between p-4">
                <span className="font-medium text-white/90">Tema</span>
                <div className="flex bg-black/20 p-1 rounded-lg">
                  <button className="px-3 py-1 text-xs font-bold bg-brand-green text-brand-blue rounded-md">Dark</button>
                  <button className="px-3 py-1 text-xs font-medium text-white/60">Light</button>
                </div>
              </div>
              <div className="flex items-center justify-between p-4 pr-5">
                <span className="font-medium text-white/90">Manter tela ligada</span>
                <div className="h-6 w-11 rounded-full bg-brand-green flex items-center px-1">
                  <div className="size-4 rounded-full bg-brand-blue translate-x-5 transition-transform"></div>
                </div>
              </div>
            </div>
          </div>

          <div className="flex flex-col gap-4">
            <h3 className="text-brand-green/70 text-xs font-bold tracking-widest uppercase pl-2">Conta</h3>
            <div className="bg-white/5 rounded-3xl overflow-hidden border border-white/10 divide-y divide-white/5">
              <div className="flex items-center justify-between p-4 pr-4">
                <div className="flex flex-col">
                  <span className="font-medium text-white/90">Plano Atual</span>
                  <span className="text-xs text-white/50">Gratuito</span>
                </div>
                <button onClick={() => navigate('/premium')} className="bg-gradient-to-r from-brand-green to-[#A0D9C0] text-brand-blue px-4 py-2 rounded-xl text-xs font-bold uppercase">
                  Upgrade Now
                </button>
              </div>
              <button className="w-full flex items-center justify-between p-4 hover:bg-white/5">
                <span className="font-medium text-white/80">Restaurar Compras</span>
                <span className="material-symbols-outlined text-white/30">chevron_right</span>
              </button>
              <button onClick={() => navigate('/')} className="w-full p-4 hover:bg-red-500/10 text-center">
                <span className="text-red-400 font-medium text-sm">Sair ou Deletar Conta</span>
              </button>
            </div>
          </div>

        </div>
      </div>
    </div>
  );
};

export default Settings;


import React from 'react';
import { useNavigate } from 'react-router-dom';

const Premium: React.FC = () => {
  const navigate = useNavigate();

  return (
    <div className="bg-brand-blue text-white min-h-screen flex flex-col relative overflow-hidden">
      {/* Top Bar */}
      <div className="absolute top-0 left-0 right-0 z-20 flex items-center justify-between p-4 pt-6">
        <button onClick={() => navigate(-1)} className="flex h-10 w-10 items-center justify-center rounded-full bg-black/20 text-white backdrop-blur-sm">
          <span className="material-symbols-outlined">close</span>
        </button>
        <div className="rounded-full bg-brand-mint/10 px-3 py-1 backdrop-blur-md">
          <span className="text-brand-mint text-xs font-bold uppercase tracking-wider">Premium</span>
        </div>
      </div>

      {/* Header Image */}
      <div className="relative h-[320px] w-full shrink-0">
        <div className="absolute inset-0 bg-cover bg-center" style={{backgroundImage: 'url("https://picsum.photos/seed/soham_zen/600/800")'}}></div>
        <div className="absolute inset-0 bg-gradient-to-b from-brand-blue/30 via-brand-blue/60 to-brand-blue"></div>
      </div>

      {/* Main Content */}
      <div className="relative z-10 -mt-20 flex-1 flex flex-col px-6 pb-6">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold leading-tight mb-2">
            Desbloqueie sua<br/><span className="text-brand-mint">Paz Interior</span>
          </h1>
          <p className="text-brand-mint/80 text-sm font-medium">Eleve sua prática e encontre o equilíbrio.</p>
        </div>

        <div className="space-y-4 mb-8">
          {[
            { icon: 'block', title: 'Remover Anúncios', sub: 'Navegue sem interrupções' },
            { icon: 'schedule', title: 'Tempos Personalizados', sub: 'Medite no seu próprio ritmo' },
            { icon: 'monitoring', title: 'Gráficos Avançados', sub: 'Acompanhe sua jornada diária' },
          ].map((item, i) => (
            <div key={i} className="flex items-center gap-4 rounded-2xl bg-white/5 p-3 border border-white/5 backdrop-blur-sm">
              <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-brand-mint/20 text-primary">
                <span className="material-symbols-outlined">{item.icon}</span>
              </div>
              <div>
                <h3 className="font-bold text-white text-base">{item.title}</h3>
                <p className="text-brand-mint/70 text-xs">{item.sub}</p>
              </div>
            </div>
          ))}
        </div>

        <div className="grid grid-cols-2 gap-3 mb-6">
          {/* Yearly */}
          <div className="relative flex cursor-pointer flex-col justify-between rounded-2xl border-2 border-primary bg-gradient-to-br from-brand-blue-light to-brand-blue p-4 shadow-lg active:scale-95">
            <div className="absolute -top-3 left-1/2 -translate-x-1/2 whitespace-nowrap rounded-full bg-primary px-3 py-1 text-[10px] font-bold uppercase text-brand-blue">
              Economize 20%
            </div>
            <div className="mt-2">
              <p className="text-brand-mint/80 text-xs font-bold uppercase">Anual</p>
              <p className="mt-1 flex items-baseline">
                <span className="text-2xl font-bold text-white">R$ 199,90</span>
              </p>
              <p className="text-brand-mint/60 text-[10px]">apenas R$ 16,65/mês</p>
            </div>
            <div className="mt-3 flex justify-end">
              <span className="material-symbols-outlined text-primary icon-filled">check_circle</span>
            </div>
          </div>
          {/* Monthly */}
          <div className="relative flex cursor-pointer flex-col justify-between rounded-2xl border border-white/10 bg-white/5 p-4 active:scale-95">
            <div className="mt-2">
              <p className="text-brand-mint/80 text-xs font-bold uppercase">Mensal</p>
              <p className="mt-1 flex items-baseline">
                <span className="text-2xl font-bold text-white">R$ 19,90</span>
              </p>
              <p className="text-brand-mint/60 text-[10px]">Cobrado mensalmente</p>
            </div>
            <div className="mt-3 flex justify-end">
              <span className="material-symbols-outlined text-white/20">radio_button_unchecked</span>
            </div>
          </div>
        </div>

        <button onClick={() => navigate('/dashboard')} className="group relative w-full overflow-hidden rounded-full bg-primary py-4 text-brand-blue shadow-xl transition-all active:scale-[0.98]">
          <span className="relative flex items-center justify-center gap-2 text-base font-bold uppercase tracking-wide">
            Assinar Agora
            <span className="material-symbols-outlined">arrow_forward</span>
          </span>
        </button>
        <p className="mt-3 text-center text-xs text-brand-mint/50">Cancelamento grátis a qualquer momento.</p>
      </div>
    </div>
  );
};

export default Premium;


import React, { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { BarChart, Bar, Cell, XAxis, YAxis, ResponsiveContainer, Tooltip } from 'recharts';
import { getMindfulTip } from '../services/geminiService';
import { Session } from '../types';

const Dashboard: React.FC = () => {
  const navigate = useNavigate();
  const [tip, setTip] = useState<string>("Carregando dica do dia...");

  const data = [
    { name: 'S', value: 45, color: '#084D75' },
    { name: 'T', value: 25, color: '#084D75' },
    { name: 'Q', value: 60, color: '#084D75' },
    { name: 'Q', value: 30, color: '#084D75' },
    { name: 'S', value: 10, color: '#084D75' },
    { name: 'S', value: 75, color: '#084D75' },
    { name: 'D', value: 50, color: '#f9f506' },
  ];

  const recentSessions: Session[] = [
    { id: '1', name: 'Mindfulness', duration: '15 min', time: '08:30', date: 'Hoje', icon: 'self_improvement' },
    { id: '2', name: 'Sono Profundo', duration: '20 min', time: '22:15', date: 'Ontem', icon: 'bedtime' },
    { id: '3', name: 'Foco Intenso', duration: '10 min', time: '14:00', date: '12 Out', icon: 'psychology' },
  ];

  useEffect(() => {
    getMindfulTip().then(setTip);
  }, []);

  return (
    <div className="flex flex-col min-h-screen pb-24">
      {/* Header */}
      <div className="flex items-center p-6 pb-2 justify-between">
        <h2 className="text-brand-blue text-2xl font-bold">Estatísticas</h2>
        <div className="flex items-center gap-3">
          <button onClick={() => navigate('/settings')} className="flex items-center justify-center rounded-full h-10 w-10 bg-brand-green/30 text-brand-blue">
            <span className="material-symbols-outlined">settings</span>
          </button>
          <div className="h-10 w-10 rounded-full bg-brand-blue border-2 border-white overflow-hidden shadow-sm">
            <img src="https://picsum.photos/seed/user/100/100" alt="Avatar" className="w-full h-full object-cover" />
          </div>
        </div>
      </div>

      {/* Gemini AI Tip */}
      <div className="px-6 py-2">
        <div className="bg-white/40 border border-brand-green p-4 rounded-xl flex gap-3 items-center">
           <span className="material-symbols-outlined text-brand-blue opacity-50">auto_awesome</span>
           <p className="text-xs italic font-medium text-brand-blue/70">"{tip}"</p>
        </div>
      </div>

      {/* Streak Section */}
      <div className="px-6 py-4">
        <div className="relative overflow-hidden rounded-lg bg-brand-green p-6 shadow-sm">
          <div className="absolute -right-6 -top-6 h-32 w-32 rounded-full bg-white/20 blur-2xl"></div>
          <div className="flex items-center justify-between relative z-10">
            <div className="flex flex-col">
              <span className="text-brand-blue/70 text-xs font-semibold uppercase tracking-wider">Sequência Atual</span>
              <div className="flex items-baseline gap-2">
                <span className="text-brand-blue text-5xl font-bold">3</span>
                <span className="text-brand-blue text-lg font-medium">dias seguidos</span>
              </div>
            </div>
            <div className="flex items-center justify-center h-14 w-14 rounded-full bg-white shadow-sm">
              <span className="material-symbols-outlined icon-filled text-[#f9bc06] !text-[32px]">local_fire_department</span>
            </div>
          </div>
        </div>
      </div>

      {/* Chart Section */}
      <div className="px-6 py-2">
        <div className="flex flex-col gap-4 rounded-lg bg-brand-green p-6 shadow-sm">
          <div className="flex justify-between items-start">
            <div>
              <p className="text-brand-blue/80 text-xs font-semibold uppercase">Minutos por dia</p>
              <p className="text-brand-blue text-3xl font-bold">135m <span className="text-base font-normal opacity-60">Total</span></p>
            </div>
            <div className="bg-white/40 px-3 py-1 rounded-full text-[10px] font-bold uppercase">Últimos 7 dias</div>
          </div>
          
          <div className="h-[180px] mt-4">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={data} margin={{ top: 0, right: 0, left: -20, bottom: 0 }}>
                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill: '#084D75', fontSize: 12, fontWeight: 'bold'}} dy={10} />
                <Bar dataKey="value" radius={[20, 20, 20, 20]} barSize={32}>
                  {data.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>

      <h2 className="text-brand-blue text-xl font-bold px-6 pt-6 pb-3">Sessões Recentes</h2>
      <div className="flex flex-col gap-3 px-6">
        {recentSessions.map(session => (
          <div key={session.id} onClick={() => navigate('/player')} className="flex items-center gap-4 bg-white p-2 pr-5 rounded-full shadow-sm border border-brand-green/30 hover:border-brand-green transition-all cursor-pointer">
            <div className="flex items-center justify-center rounded-full bg-brand-green shrink-0 h-12 w-12 text-brand-blue">
              <span className="material-symbols-outlined icon-filled">{session.icon}</span>
            </div>
            <div className="flex flex-col flex-1 overflow-hidden">
              <p className="text-brand-blue text-base font-bold leading-snug">{session.name}</p>
              <div className="flex items-center gap-2 text-xs font-medium text-brand-blue/60">
                <span>{session.date}</span>
                <span className="w-1 h-1 rounded-full bg-brand-blue/30"></span>
                <span>{session.time}</span>
              </div>
            </div>
            <div className="shrink-0 bg-background-light px-3 py-1 rounded-full">
              <p className="text-brand-blue text-sm font-semibold">{session.duration}</p>
            </div>
          </div>
        ))}
      </div>

      {/* Bottom Nav */}
      <div className="fixed bottom-0 left-0 right-0 max-w-md mx-auto bg-white/90 backdrop-blur-md border-t border-brand-green/30 pt-2 px-6 pb-safe">
        <div className="flex justify-around items-center h-16">
          <button onClick={() => navigate('/patterns')} className="flex flex-col items-center gap-1 text-brand-blue/40">
            <span className="material-symbols-outlined text-[28px]">spa</span>
            <span className="text-[10px] font-bold">Início</span>
          </button>
          <button className="flex flex-col items-center gap-1 text-brand-blue">
            <span className="material-symbols-outlined icon-filled text-[28px]">bar_chart</span>
            <span className="text-[10px] font-bold">Estatísticas</span>
          </button>
          <button onClick={() => navigate('/settings')} className="flex flex-col items-center gap-1 text-brand-blue/40">
            <span className="material-symbols-outlined text-[28px]">person</span>
            <span className="text-[10px] font-bold">Perfil</span>
          </button>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;

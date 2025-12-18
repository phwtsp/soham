
import React from 'react';
import { useNavigate } from 'react-router-dom';

const Login: React.FC = () => {
  const navigate = useNavigate();

  return (
    <div className="relative flex min-h-screen w-full flex-col overflow-hidden bg-background-light dark:bg-background-dark">
      <div className="absolute top-[-15%] right-[-15%] w-64 h-64 bg-brand-mint/30 rounded-full blur-3xl"></div>
      <div className="absolute bottom-[-10%] left-[-10%] w-64 h-64 bg-primary/20 rounded-full blur-3xl"></div>
      
      <div className="flex-1 flex flex-col items-center justify-center px-6 py-8 relative z-10 w-full">
        <div className="mb-6 w-full flex justify-center">
          <div className="w-32 h-32 rounded-full overflow-hidden shadow-lg border-4 border-white">
            <div className="w-full h-full bg-center bg-cover" style={{backgroundImage: 'url("https://picsum.photos/seed/meditation/400/400")'}}></div>
          </div>
        </div>

        <div className="flex flex-col gap-1 items-center mb-8">
          <h1 className="text-brand-blue text-4xl font-bold tracking-tight text-center">Soham</h1>
          <h2 className="text-brand-blue/80 text-lg font-medium tracking-tight text-center">Encontre o seu centro.</h2>
        </div>

        <div className="w-full flex flex-col gap-3">
          <button onClick={() => navigate('/dashboard')} className="flex w-full cursor-pointer items-center justify-center rounded-full h-12 px-4 bg-white border border-gray-200 hover:bg-gray-50 transition-colors gap-3 group">
            <svg className="w-5 h-5" viewBox="0 0 24 24"><path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.75h3.57c2.08-1.92 3.28-4.74 3.28-8.07z" fill="#4285F4"></path><path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.75c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"></path><path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05"></path><path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"></path></svg>
            <span className="text-brand-blue font-bold text-sm">Entrar com Google</span>
          </button>
          
          <button onClick={() => navigate('/dashboard')} className="flex w-full cursor-pointer items-center justify-center rounded-full h-12 px-4 bg-[#1c1c0d] text-white hover:opacity-90 transition-opacity gap-3">
             <span className="material-symbols-outlined text-white">apple</span>
            <span className="font-bold text-sm">Entrar com Apple</span>
          </button>
        </div>

        <div className="relative w-full py-6 flex items-center">
          <div className="flex-grow border-t border-brand-blue/10"></div>
          <span className="flex-shrink mx-4 text-xs font-semibold text-brand-blue/50 uppercase tracking-wider">ou continuar com email</span>
          <div className="flex-grow border-t border-brand-blue/10"></div>
        </div>

        <div className="w-full flex flex-col gap-4">
          <input className="w-full h-12 px-5 rounded-full bg-brand-mint/30 border-none text-brand-blue placeholder:text-brand-blue/50 focus:ring-2 focus:ring-brand-blue/50 text-sm font-medium" placeholder="seu@email.com" type="email"/>
          <input className="w-full h-12 px-5 rounded-full bg-brand-mint/30 border-none text-brand-blue placeholder:text-brand-blue/50 focus:ring-2 focus:ring-brand-blue/50 text-sm font-medium" placeholder="Sua senha" type="password"/>
          <button onClick={() => navigate('/dashboard')} className="w-full h-12 mt-2 rounded-full bg-primary hover:bg-yellow-300 active:scale-[0.98] transition-all shadow-md flex items-center justify-center gap-2 group">
            <span className="text-brand-blue font-bold text-base">Entrar</span>
            <span className="material-symbols-outlined text-brand-blue group-hover:translate-x-1 transition-transform">arrow_forward</span>
          </button>
        </div>

        <div className="mt-8 text-center">
          <p className="text-sm text-brand-blue/80">
            Não tem uma conta? <span className="font-bold text-brand-blue hover:underline cursor-pointer">Cadastre-se</span>
          </p>
        </div>
      </div>
    </div>
  );
};

export default Login;

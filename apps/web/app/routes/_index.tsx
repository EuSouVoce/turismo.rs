import type { MetaFunction } from "@remix-run/node";
import { useEffect, useState } from "react";

export const meta: MetaFunction = () => {
  return [
    { title: "turismo.rs — O Futuro do Turismo no Rio Grande do Sul (Em Construção)" },
    { name: "description", content: "Uma nova era para o turismo no Rio Grande do Sul. Em breve, uma plataforma state-of-the-art com roteiros, reservas e experiências personalizadas." },
  ];
};

export default function Index() {
  const [year, setYear] = useState(new Date().getFullYear());

  useEffect(() => {
    setYear(new Date().getFullYear());
  }, []);

  return (
    <div className="bg-slate-900 text-slate-200">
      <div className="absolute inset-0 -z-10 h-full w-full bg-slate-900 bg-[linear-gradient(to_right,#8080800a_1px,transparent_1px),linear-gradient(to_bottom,#8080800a_1px,transparent_1px)] bg-[size:14px_24px]"></div>
      <div className="absolute left-0 right-0 top-0 -z-10 m-auto h-[310px] w-[310px] rounded-full bg-emerald-500 opacity-20 blur-[100px]"></div>

      <div className="container mx-auto px-6 py-8 animate-fade-in">
        <header className="flex items-center justify-between">
          <a href="/" className="flex items-center gap-4 group">
            <div className="h-12 w-12 rounded-lg bg-gradient-to-br from-emerald-500 to-teal-400 flex items-center justify-center text-white font-extrabold text-lg shadow-2xl shadow-emerald-500/20 group-hover:scale-105 transition-transform">RS</div>
            <h1 className="text-2xl font-bold tracking-tighter">turismo.rs</h1>
          </a>
          <a href="#notify" className="btn btn-sm btn-ghost hidden md:inline-flex">Seja Notificado</a>
        </header>

        <main className="mt-24 text-center animate-fade-in-up" style={{ animationDelay: '0.2s' }}>
          <span className="badge badge-lg badge-outline border-emerald-400/50 text-emerald-400">Plataforma em Construção</span>
          <h2 className="mt-6 text-4xl md:text-6xl font-extrabold tracking-tighter bg-gradient-to-br from-white to-slate-400 bg-clip-text text-transparent">
            Uma nova era para o turismo no Rio Grande do Sul.
          </h2>
          <p className="mt-6 mx-auto max-w-2xl text-lg text-slate-400">
            Estamos desenvolvendo uma plataforma state-of-the-art para unificar roteiros, reservas e experiências personalizadas. Independente, moderno e focado no viajante.
          </p>

          <div className="mt-8 flex flex-col sm:flex-row items-center justify-center gap-4">
            <a href="#notify" className="btn btn-primary btn-wide bg-emerald-500 hover:bg-emerald-400 border-none text-slate-900 font-bold">Quero ser o primeiro a saber</a>
            <a href="#about" className="btn btn-ghost">Sobre o projeto</a>
          </div>

          <div className="mt-12 alert alert-warning max-w-3xl mx-auto bg-amber-500/10 border-amber-500/20 text-amber-300">
            <svg xmlns="http://www.w3.org/2000/svg" className="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" /></svg>
            <span><strong>Atenção:</strong> Somos um projeto independente, sem afiliação, vínculo ou patrocínio do Governo do Estado do RS, Secretaria de Turismo ou Cadastur.</span>
          </div>
        </main>

        <section id="about" className="mt-32 scroll-mt-24 animate-fade-in-up" style={{ animationDelay: '0.4s' }}>
          <div className="text-center">
            <h3 className="text-3xl font-bold tracking-tighter">O que estamos construindo?</h3>
            <p className="mt-4 max-w-xl mx-auto text-slate-400">A visão é ambiciosa: uma plataforma completa que integra tudo o que o viajante precisa.</p>
          </div>

          <div className="mt-12 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
            <div className="card bg-slate-800/50 shadow-xl border border-slate-700/50"><div className="card-body"><h4 className="card-title">Roteiros Inteligentes</h4><p>Por região, tema (enoturismo, ecoturismo) e com sugestões baseadas em seu perfil.</p></div></div>
            <div className="card bg-slate-800/50 shadow-xl border border-slate-700/50"><div className="card-body"><h4 className="card-title">Reservas e Ingressos</h4><p>Integração direta com parceiros locais para hotéis, passeios e eventos.</p></div></div>
            <div className="card bg-slate-800/50 shadow-xl border border-slate-700/50"><div className="card-body"><h4 className="card-title">Mapa Interativo</h4><p>Navegação, transfers, pontos de interesse e planejamento de rotas em tempo real.</p></div></div>
            <div className="card bg-slate-800/50 shadow-xl border border-slate-700/50"><div className="card-body"><h4 className="card-title">Módulos Futuros</h4><p>SSO, portais para parceiros, LGPD e subdomínios para cidades específicas.</p></div></div>
          </div>
        </section>

        <section id="notify" className="mt-32 scroll-mt-24 animate-fade-in-up" style={{ animationDelay: '0.6s' }}>
          <div className="card lg:card-side bg-slate-800/50 shadow-xl max-w-4xl mx-auto border border-slate-700/50">
            <div className="card-body">
              <h3 className="card-title text-2xl">Não perca o lançamento!</h3>
              <p>Deixe seu e-mail e seja um dos primeiros a explorar a nova forma de fazer turismo no Rio Grande do Sul.</p>
              <form className="card-actions justify-end mt-4" onSubmit={(e) => { e.preventDefault(); alert('Obrigado! Você será notificado. (Protótipo sem backend)'); }}>
                <input type="email" placeholder="seu-melhor-email@exemplo.com" className="input input-bordered w-full" required />
                <button type="submit" className="btn btn-primary bg-emerald-500 hover:bg-emerald-400 border-none text-slate-900 font-bold">Notifique-me</button>
              </form>
              <p className="text-xs text-slate-500 mt-2">Prometemos não enviar spam. Este formulário é um protótipo sem backend.</p>
            </div>
          </div>
        </section>

        <footer className="footer footer-center p-10 text-slate-400">
          <aside>
            <p className="font-bold text-lg">turismo.rs</p>
            <p>Copyright © {year} - Todos os direitos reservados</p>
            <p className="font-semibold text-amber-400">Projeto independente. Não afiliado ao Governo do RS, SETUR ou Cadastur.</p>
          </aside>
          <nav>
            <div className="grid grid-flow-col gap-4">
              <a href="https://setur.rs.gov.br/inicial" target="_blank" rel="noopener noreferrer" className="link link-hover">SETUR-RS</a>
              <a href="https://www.turismo.rs.gov.br/turismo/" target="_blank" rel="noopener noreferrer" className="link link-hover">Turismo RS (Gov)</a>
              <a href="https://cadastur.turismo.gov.br" target="_blank" rel="noopener noreferrer" className="link link-hover">Cadastur</a>
            </div>
          </nav>
        </footer>
      </div>
    </div>
  );
}

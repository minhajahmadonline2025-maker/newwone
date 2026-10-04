import { useCallback, useEffect, useState } from 'react';
import { GraduationCap, Lock } from 'lucide-react';
import { supabase } from '@/lib/supabase';
import StudentPanel from '@/components/StudentPanel';
import AdminLogin from '@/components/admin/AdminLogin';
import AdminPanel from '@/components/admin/AdminPanel';

type View = 'student' | 'admin-login' | 'admin-panel';

export default function App() {
  const [view, setView] = useState<View>('student');
  const [authChecked, setAuthChecked] = useState(false);

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      if (data.session && window.location.hash === '#admin') {
        setView('admin-panel');
      }
      setAuthChecked(true);
    });

    const { data: authListener } = supabase.auth.onAuthStateChange(
      (_event, session) => {
        if (session && view === 'admin-login') {
          setView('admin-panel');
        }
      }
    );

    return () => {
      authListener.subscription.unsubscribe();
    };
  }, [view]);

  const handleHashChange = useCallback(() => {
    if (window.location.hash === '#admin') {
      setView((prev) => {
        if (prev === 'student') return 'admin-login';
        return prev;
      });
    } else {
      setView('student');
    }
  }, []);

  useEffect(() => {
    handleHashChange();
    window.addEventListener('hashchange', handleHashChange);
    return () => window.removeEventListener('hashchange', handleHashChange);
  }, [handleHashChange]);

  const goToStudent = useCallback(() => {
    window.location.hash = '';
    setView('student');
  }, []);

  const goToAdmin = useCallback(() => {
    window.location.hash = '#admin';
    setView('admin-login');
  }, []);

  const handleAdminLogout = useCallback(() => {
    setView('admin-login');
  }, []);

  if (!authChecked) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-slate-50">
        <GraduationCap className="h-8 w-8 animate-pulse text-blue-600" />
      </div>
    );
  }

  if (view === 'admin-login') {
    return (
      <div>
        <AdminLogin onSuccess={() => setView('admin-panel')} />
        <button
          onClick={goToStudent}
          className="fixed bottom-4 right-4 flex items-center gap-1.5 rounded-full bg-white/10 px-4 py-2 text-xs font-medium text-slate-400 backdrop-blur transition hover:text-white"
        >
          <GraduationCap className="h-3.5 w-3.5" />
          Back to Feedback
        </button>
      </div>
    );
  }

  if (view === 'admin-panel') {
    return <AdminPanel onLogout={handleAdminLogout} />;
  }

  return (
    <div className="relative">
      <StudentPanel />
      <button
        onClick={goToAdmin}
        className="fixed bottom-4 right-4 flex items-center gap-2 rounded-full bg-slate-900 px-5 py-3 text-sm font-semibold text-white shadow-lg transition hover:bg-slate-800 active:scale-95"
        aria-label="Admin Login"
      >
        <Lock className="h-4 w-4" />
        Admin
      </button>
    </div>
  );
}

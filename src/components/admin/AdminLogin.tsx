import { useCallback, useEffect, useState } from 'react';
import { Loader2, Lock, Mail } from 'lucide-react';
import { supabase } from '@/lib/supabase';

type AdminLoginProps = {
  onSuccess: () => void;
};

export default function AdminLogin({ onSuccess }: AdminLoginProps) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [checking, setChecking] = useState(true);

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      if (data.session) onSuccess();
      setChecking(false);
    });
  }, [onSuccess]);

  const handleLogin = useCallback(
    async (e: React.FormEvent) => {
      e.preventDefault();
      if (!email || !password) return;
      try {
        setLoading(true);
        setError(null);
        const { error: authError } = await supabase.auth.signInWithPassword({
          email,
          password,
        });
        if (authError) throw authError;
        onSuccess();
      } catch (err) {
        const msg = err instanceof Error ? err.message : 'Login failed';
        setError(
          msg.includes('Invalid login')
            ? 'Invalid email or password.'
            : 'Login failed. Please try again.'
        );
      } finally {
        setLoading(false);
      }
    },
    [email, password, onSuccess]
  );

  if (checking) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-slate-900">
        <Loader2 className="h-8 w-8 animate-spin text-blue-400" />
      </div>
    );
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-slate-900 p-4">
      <div className="w-full max-w-md">
        <div className="mb-8 text-center">
          <div className="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-2xl bg-blue-600">
            <Lock className="h-7 w-7 text-white" />
          </div>
          <h1 className="text-2xl font-bold text-white">Admin Login</h1>
          <p className="mt-2 text-sm text-slate-400">
            Malik Deenar Islamic Academy — Administrator Access
          </p>
        </div>
        <form
          onSubmit={handleLogin}
          className="rounded-2xl bg-slate-800 p-8 shadow-2xl"
        >
          <div className="space-y-5">
            <div>
              <label className="mb-2 block text-sm font-medium text-slate-300">
                Email
              </label>
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-slate-500" />
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="admin@usthadfeedback.com"
                  className="w-full rounded-xl border border-slate-600 bg-slate-700 py-3 pl-11 pr-4 text-white placeholder-slate-500 outline-none transition focus:border-blue-500"
                  autoComplete="email"
                />
              </div>
            </div>
            <div>
              <label className="mb-2 block text-sm font-medium text-slate-300">
                Password
              </label>
              <div className="relative">
                <Lock className="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-slate-500" />
                <input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Enter password"
                  className="w-full rounded-xl border border-slate-600 bg-slate-700 py-3 pl-11 pr-4 text-white placeholder-slate-500 outline-none transition focus:border-blue-500"
                  autoComplete="current-password"
                />
              </div>
            </div>
            {error && (
              <div className="rounded-lg bg-red-500/10 px-4 py-3 text-sm text-red-400">
                {error}
              </div>
            )}
            <button
              type="submit"
              disabled={loading}
              className="flex w-full items-center justify-center gap-2 rounded-xl bg-blue-600 py-3.5 font-semibold text-white transition hover:bg-blue-700 disabled:opacity-50"
            >
              {loading ? (
                <Loader2 className="h-5 w-5 animate-spin" />
              ) : (
                'Sign In'
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

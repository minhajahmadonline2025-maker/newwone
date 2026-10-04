import { useCallback, useEffect, useState } from 'react';
import {
  BookOpen,
  CheckCircle2,
  Clock,
  FileText,
  GraduationCap,
  Loader2,
  Users,
} from 'lucide-react';
import {
  fetchAllClassUsthads,
  fetchClasses,
  fetchFeedbackSettings,
} from '@/services/feedbackService';
import { getEffectiveLimit } from '@/services/feedbackService';
import type {
  ClassRow,
  FeedbackSettings,
} from '@/types/database';
import { supabase } from '@/lib/supabase';

type ClassUsthadFull = {
  id: string;
  class_id: string;
  usthad_id: string;
  created_at: string;
  class: ClassRow;
  usthad: { id: string; name: string; created_at: string };
  class_usthad_subjects: {
    id: string;
    class_usthad_id: string;
    subject_id: string;
    feedback_limit: number | null;
    created_at: string;
    subject: { id: string; name: string; created_at: string };
  }[];
};

type AdminDashboardProps = {
  onNavigate: (tab: string) => void;
};

export default function AdminDashboard({ onNavigate }: AdminDashboardProps) {
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState({
    totalClasses: 0,
    totalUsthads: 0,
    totalSubjects: 0,
    totalFeedback: 0,
    completed: 0,
    pending: 0,
  });

  const loadData = useCallback(async () => {
    try {
      setLoading(true);
      const [classes, allClassUsthads, settings] = await Promise.all([
        fetchClasses(),
        fetchAllClassUsthads() as Promise<ClassUsthadFull[]>,
        fetchFeedbackSettings(),
      ]);

      const uniqueUsthadIds = new Set(allClassUsthads.map((cu) => cu.usthad_id));
      const uniqueSubjectIds = new Set<string>();
      let totalFeedback = 0;
      let completed = 0;
      let pending = 0;

      for (const cu of allClassUsthads) {
        for (const cus of cu.class_usthad_subjects) {
          uniqueSubjectIds.add(cus.subject_id);
          const { count } = await supabase
            .from('feedback_responses')
            .select('*', { count: 'exact', head: true })
            .eq('class_usthad_subject_id', cus.id);
          const responseCount = count ?? 0;
          totalFeedback += responseCount;
          const limit = getEffectiveLimit(cus, settings.default_feedback_limit);
          if (responseCount >= limit) {
            completed++;
          } else {
            pending++;
          }
        }
      }

      setStats({
        totalClasses: classes.length,
        totalUsthads: uniqueUsthadIds.size,
        totalSubjects: uniqueSubjectIds.size,
        totalFeedback,
        completed,
        pending,
      });
    } catch (err) {
      console.error('Failed to load dashboard:', err);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadData();
  }, [loadData]);

  if (loading) {
    return (
      <div className="flex h-full items-center justify-center py-20">
        <Loader2 className="h-8 w-8 animate-spin text-blue-600" />
      </div>
    );
  }

  const cards = [
    {
      label: 'Total Classes',
      value: stats.totalClasses,
      icon: BookOpen,
      color: 'bg-blue-50 text-blue-600',
    },
    {
      label: 'Total Usthads',
      value: stats.totalUsthads,
      icon: Users,
      color: 'bg-emerald-50 text-emerald-600',
    },
    {
      label: 'Total Subjects',
      value: stats.totalSubjects,
      icon: GraduationCap,
      color: 'bg-purple-50 text-purple-600',
    },
    {
      label: 'Total Feedback',
      value: stats.totalFeedback,
      icon: FileText,
      color: 'bg-amber-50 text-amber-600',
    },
    {
      label: 'Completed',
      value: stats.completed,
      icon: CheckCircle2,
      color: 'bg-green-50 text-green-600',
    },
    {
      label: 'Pending',
      value: stats.pending,
      icon: Clock,
      color: 'bg-orange-50 text-orange-600',
    },
  ];

  return (
    <div>
      <h2 className="mb-6 text-2xl font-bold text-slate-900">Dashboard</h2>
      <div className="grid grid-cols-2 gap-4 lg:grid-cols-3">
        {cards.map((card) => (
          <div
            key={card.label}
            className="rounded-2xl border border-slate-200 bg-white p-5 transition hover:shadow-md"
          >
            <div className={`mb-3 inline-flex rounded-xl p-3 ${card.color}`}>
              <card.icon className="h-6 w-6" />
            </div>
            <p className="text-3xl font-bold text-slate-900">{card.value}</p>
            <p className="mt-1 text-sm text-slate-500">{card.label}</p>
          </div>
        ))}
      </div>

      <div className="mt-8 rounded-2xl border border-slate-200 bg-white p-6">
        <h3 className="mb-4 text-lg font-semibold text-slate-800">
          Quick Actions
        </h3>
        <div className="flex flex-wrap gap-3">
          <button
            onClick={() => onNavigate('classes')}
            className="rounded-xl bg-blue-50 px-5 py-3 text-sm font-medium text-blue-700 transition hover:bg-blue-100"
          >
            View Classes & Feedback
          </button>
          <button
            onClick={() => onNavigate('reports')}
            className="rounded-xl bg-emerald-50 px-5 py-3 text-sm font-medium text-emerald-700 transition hover:bg-emerald-100"
          >
            View Reports
          </button>
          <button
            onClick={() => onNavigate('staff')}
            className="rounded-xl bg-purple-50 px-5 py-3 text-sm font-medium text-purple-700 transition hover:bg-purple-100"
          >
            Manage Staff & Subjects
          </button>
          <button
            onClick={() => onNavigate('settings')}
            className="rounded-xl bg-slate-100 px-5 py-3 text-sm font-medium text-slate-700 transition hover:bg-slate-200"
          >
            Settings
          </button>
        </div>
      </div>
    </div>
  );
}

import { useCallback, useEffect, useMemo, useState } from 'react';
import {
  CheckCircle2,
  Clock,
  Download,
  Eye,
  FileText,
  Loader2,
  Share2,
  Star,
  X,
} from 'lucide-react';
import StarRating from '@/components/StarRating';
import PdfReport from '@/components/admin/PdfReport';
import {
  fetchAllClassUsthads,
  fetchClasses,
  fetchFeedbackSettings,
  fetchResponsesBySubject,
  getEffectiveLimit,
} from '@/services/feedbackService';
import { supabase } from '@/lib/supabase';
import type {
  ClassRow,
  ClassUsthadRow,
  ClassUsthadSubjectRow,
  FeedbackResponseRow,
  FeedbackSettings,
  SubjectRow,
  UsthadRow,
} from '@/types/database';

type ClassUsthadFull = {
  id: string;
  class_id: string;
  usthad_id: string;
  created_at: string;
  class: ClassRow;
  usthad: UsthadRow;
  class_usthad_subjects: (ClassUsthadSubjectRow & { subject: SubjectRow })[];
};

type ReportRow = {
  cusId: string;
  className: string;
  usthadName: string;
  subjectName: string;
  responseCount: number;
  limit: number;
  avgRating: number;
  status: 'complete' | 'pending';
};

type ShareData = {
  className: string;
  usthadName: string;
  subjectName: string;
  responses: FeedbackResponseRow[];
  avgRating: number;
  limit: number;
  responseCount: number;
  institutionName: string;
  requireStudentName: boolean;
};

export default function AdminReports() {
  const [loading, setLoading] = useState(true);
  const [allClassUsthads, setAllClassUsthads] = useState<ClassUsthadFull[]>(
    []
  );
  const [settings, setSettings] = useState<FeedbackSettings | null>(null);
  const [filterClass, setFilterClass] = useState('');
  const [filterUsthad, setFilterUsthad] = useState('');
  const [filterStatus, setFilterStatus] = useState('');
  const [counts, setCounts] = useState<Record<string, number>>({});
  const [shareData, setShareData] = useState<ShareData | null>(null);
  const [viewData, setViewData] = useState<ShareData | null>(null);

  const loadData = useCallback(async () => {
    try {
      setLoading(true);
      const [cus, stg] = await Promise.all([
        fetchAllClassUsthads() as Promise<ClassUsthadFull[]>,
        fetchFeedbackSettings(),
      ]);
      setAllClassUsthads(cus);
      setSettings(stg);

      const countMap: Record<string, number> = {};
      for (const cu of cus) {
        for (const cusub of cu.class_usthad_subjects) {
          const { count } = await supabase
            .from('feedback_responses')
            .select('*', { count: 'exact', head: true })
            .eq('class_usthad_subject_id', cusub.id);
          countMap[cusub.id] = count ?? 0;
        }
      }
      setCounts(countMap);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadData();
  }, [loadData]);

  const uniqueUsthadNames = useMemo(() => {
    const names = new Set(allClassUsthads.map((cu) => cu.usthad.name));
    return Array.from(names).sort();
  }, [allClassUsthads]);

  const reportRows: ReportRow[] = useMemo(() => {
    const rows: ReportRow[] = [];
    for (const cu of allClassUsthads) {
      for (const cus of cu.class_usthad_subjects) {
        const count = counts[cus.id] ?? 0;
        const limit = getEffectiveLimit(
          cus,
          settings?.default_feedback_limit ?? 5
        );
        const isComplete = count >= limit;
        rows.push({
          cusId: cus.id,
          className: cu.class.name,
          usthadName: cu.usthad.name,
          subjectName: cus.subject.name,
          responseCount: count,
          limit,
          avgRating: 0,
          status: isComplete ? 'complete' : 'pending',
        });
      }
    }
    return rows.sort((a, b) =>
      a.className.localeCompare(b.className) ||
      a.usthadName.localeCompare(b.usthadName)
    );
  }, [allClassUsthads, counts, settings]);

  const filteredRows = useMemo(() => {
    return reportRows.filter((r) => {
      if (filterClass && r.className !== filterClass) return false;
      if (filterUsthad && r.usthadName !== filterUsthad) return false;
      if (filterStatus === 'complete' && r.status !== 'complete') return false;
      if (filterStatus === 'pending' && r.status !== 'pending') return false;
      return true;
    });
  }, [reportRows, filterClass, filterUsthad, filterStatus]);

  const handleShare = useCallback(
    async (row: ReportRow) => {
      try {
        const responses = await fetchResponsesBySubject(row.cusId);
        const avg =
          responses.length > 0
            ? responses.reduce((a, r) => a + r.rating, 0) / responses.length
            : 0;
        setShareData({
          className: row.className,
          usthadName: row.usthadName,
          subjectName: row.subjectName,
          responses,
          avgRating: avg,
          limit: row.limit,
          responseCount: row.responseCount,
          institutionName: settings?.institution_name ?? 'Malik Deenar Islamic Academy',
          requireStudentName: settings?.require_student_name ?? false,
        });
      } catch (err) {
        console.error(err);
      }
    },
    [settings]
  );

  if (loading) {
    return (
      <div className="flex h-full items-center justify-center py-20">
        <Loader2 className="h-8 w-8 animate-spin text-blue-600" />
      </div>
    );
  }

  return (
    <div>
      <h2 className="mb-6 text-2xl font-bold text-slate-900">Reports</h2>

      {/* Filters */}
      <div className="mb-6 flex flex-wrap gap-3">
        <select
          value={filterClass}
          onChange={(e) => setFilterClass(e.target.value)}
          className="rounded-xl border border-slate-200 px-4 py-2.5 text-sm outline-none transition focus:border-blue-500"
        >
          <option value="">All Classes</option>
          {Array.from(new Set(allClassUsthads.map((cu) => cu.class.name)))
            .sort()
            .map((name) => (
              <option key={name} value={name}>
                {name}
              </option>
            ))}
        </select>
        <select
          value={filterUsthad}
          onChange={(e) => setFilterUsthad(e.target.value)}
          className="rounded-xl border border-slate-200 px-4 py-2.5 text-sm outline-none transition focus:border-blue-500"
        >
          <option value="">All Usthads</option>
          {uniqueUsthadNames.map((name) => (
            <option key={name} value={name}>
              {name}
            </option>
          ))}
        </select>
        <select
          value={filterStatus}
          onChange={(e) => setFilterStatus(e.target.value)}
          className="rounded-xl border border-slate-200 px-4 py-2.5 text-sm outline-none transition focus:border-blue-500"
        >
          <option value="">All Status</option>
          <option value="complete">Completed</option>
          <option value="pending">Pending</option>
        </select>
      </div>

      {/* Report Table */}
      <div className="overflow-x-auto rounded-2xl border border-slate-200 bg-white">
        <table className="w-full text-left text-sm">
          <thead>
            <tr className="border-b border-slate-200 bg-slate-50">
              <th className="px-4 py-3 font-semibold text-slate-700">Class</th>
              <th className="px-4 py-3 font-semibold text-slate-700">
                Usthad
              </th>
              <th className="px-4 py-3 font-semibold text-slate-700">
                Subject
              </th>
              <th className="px-4 py-3 font-semibold text-slate-700">
                Responses
              </th>
              <th className="px-4 py-3 font-semibold text-slate-700">Status</th>
              <th className="px-4 py-3 font-semibold text-slate-700">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {filteredRows.length === 0 ? (
              <tr>
                <td
                  colSpan={6}
                  className="px-4 py-12 text-center text-slate-400"
                >
                  No reports found.
                </td>
              </tr>
            ) : (
              filteredRows.map((row) => (
                <tr key={row.cusId} className="transition hover:bg-slate-50">
                  <td className="px-4 py-3 text-slate-700">{row.className}</td>
                  <td className="px-4 py-3 text-slate-700">
                    {row.usthadName}
                  </td>
                  <td className="px-4 py-3 text-slate-600">
                    {row.subjectName}
                  </td>
                  <td className="px-4 py-3 text-slate-600">
                    {row.responseCount} / {row.limit}
                  </td>
                  <td className="px-4 py-3">
                    {row.status === 'complete' ? (
                      <span className="inline-flex items-center gap-1 rounded-full bg-green-50 px-2.5 py-1 text-xs font-medium text-green-700">
                        <CheckCircle2 className="h-3 w-3" />
                        Complete
                      </span>
                    ) : (
                      <span className="inline-flex items-center gap-1 rounded-full bg-orange-50 px-2.5 py-1 text-xs font-medium text-orange-700">
                        <Clock className="h-3 w-3" />
                        Pending
                      </span>
                    )}
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex gap-1.5">
                      <button
                        onClick={() => handleShare(row)}
                        className="flex items-center gap-1 rounded-lg bg-blue-50 px-2.5 py-1.5 text-xs font-medium text-blue-700 transition hover:bg-blue-100"
                      >
                        <Eye className="h-3.5 w-3.5" />
                        View
                      </button>
                      <button
                        onClick={() => handleShare(row)}
                        className="flex items-center gap-1 rounded-lg bg-emerald-50 px-2.5 py-1.5 text-xs font-medium text-emerald-700 transition hover:bg-emerald-100"
                      >
                        <FileText className="h-3.5 w-3.5" />
                        PDF
                      </button>
                      <button
                        onClick={() => handleShare(row)}
                        className="flex items-center gap-1 rounded-lg bg-purple-50 px-2.5 py-1.5 text-xs font-medium text-purple-700 transition hover:bg-purple-100"
                      >
                        <Share2 className="h-3.5 w-3.5" />
                        Share
                      </button>
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* View / Share Modal */}
      {(shareData || viewData) && (
        <div
          className="fixed inset-0 z-50 flex items-start justify-center overflow-y-auto bg-black/40 p-4"
          onClick={() => {
            setShareData(null);
            setViewData(null);
          }}
        >
          <div
            className="my-4 w-full max-w-3xl rounded-2xl bg-white shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between border-b border-slate-100 px-6 py-4">
              <h3 className="text-lg font-bold text-slate-900">
                Feedback Report
              </h3>
              <button
                onClick={() => {
                  setShareData(null);
                  setViewData(null);
                }}
                className="rounded-lg p-2 text-slate-400 transition hover:bg-slate-100"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            <div className="max-h-[70vh] overflow-y-auto p-6">
              <PdfReport data={shareData || viewData!} />
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

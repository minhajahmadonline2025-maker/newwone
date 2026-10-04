import { useCallback, useEffect, useState } from 'react';
import {
  ChevronRight,
  Eye,
  FileText,
  Loader2,
  Plus,
  RotateCcw,
  Share2,
  Trash2,
  X,
} from 'lucide-react';
import StarRating from '@/components/StarRating';
import {
  fetchAllClassUsthads,
  fetchClasses,
  fetchFeedbackSettings,
  fetchResponsesByCusIds,
  fetchResponsesBySubject,
  getEffectiveLimit,
  removeSubjectFromUsthad,
  resetFeedback,
  updateFeedbackLimit,
} from '@/services/feedbackService';
import { supabase } from '@/lib/supabase';
import type {
  ClassRow,
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

type DetailData = {
  usthad: UsthadRow;
  cls: ClassRow;
  subject: SubjectRow;
  cusId: string;
  responses: FeedbackResponseRow[];
  limit: number;
  requireStudentName: boolean;
};

export default function AdminClasses() {
  const [loading, setLoading] = useState(true);
  const [classes, setClasses] = useState<ClassRow[]>([]);
  const [allClassUsthads, setAllClassUsthads] = useState<ClassUsthadFull[]>([]);
  const [settings, setSettings] = useState<FeedbackSettings | null>(null);
  const [expandedClass, setExpandedClass] = useState<string | null>(null);
  const [detail, setDetail] = useState<DetailData | null>(null);
  const [detailLoading, setDetailLoading] = useState(false);
  const [editingLimit, setEditingLimit] = useState<string | null>(null);
  const [limitValue, setLimitValue] = useState('');
  const [resetConfirm, setResetConfirm] = useState<string | null>(null);

  const loadData = useCallback(async () => {
    try {
      setLoading(true);
      const [cls, cus, stg] = await Promise.all([
        fetchClasses(),
        fetchAllClassUsthads() as Promise<ClassUsthadFull[]>,
        fetchFeedbackSettings(),
      ]);
      setClasses(cls);
      setAllClassUsthads(cus);
      setSettings(stg);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadData();
  }, [loadData]);

  const handleView = useCallback(
    async (
      cu: ClassUsthadFull,
      cus: ClassUsthadSubjectRow & { subject: SubjectRow }
    ) => {
      try {
        setDetailLoading(true);
        const responses = await fetchResponsesBySubject(cus.id);
        const limit = getEffectiveLimit(
          cus,
          settings?.default_feedback_limit ?? 5
        );
        setDetail({
          usthad: cu.usthad,
          cls: cu.class,
          subject: cus.subject,
          cusId: cus.id,
          responses,
          limit,
          requireStudentName: settings?.require_student_name ?? false,
        });
      } catch (err) {
        console.error(err);
      } finally {
        setDetailLoading(false);
      }
    },
    [settings]
  );

  const handleSaveLimit = useCallback(
    async (cusId: string) => {
      const val = parseInt(limitValue, 10);
      if (isNaN(val) || val < 1) return;
      try {
        await updateFeedbackLimit(cusId, val);
        setEditingLimit(null);
        await loadData();
      } catch (err) {
        console.error(err);
      }
    },
    [limitValue, loadData]
  );

  const handleResetLimit = useCallback(
    async (cusId: string) => {
      try {
        await updateFeedbackLimit(cusId, null);
        setEditingLimit(null);
        await loadData();
      } catch (err) {
        console.error(err);
      }
    },
    [loadData]
  );

  const handleResetFeedback = useCallback(
    async (cusId: string) => {
      try {
        await resetFeedback(cusId);
        setResetConfirm(null);
        if (detail && detail.cusId === cusId) {
          setDetail({ ...detail, responses: [] });
        }
        await loadData();
      } catch (err) {
        console.error(err);
      }
    },
    [detail, loadData]
  );

  const handleRemoveSubject = useCallback(
    async (cusId: string) => {
      try {
        await removeSubjectFromUsthad(cusId);
        await loadData();
      } catch (err) {
        console.error(err);
      }
    },
    [loadData]
  );

  if (loading) {
    return (
      <div className="flex h-full items-center justify-center py-20">
        <Loader2 className="h-8 w-8 animate-spin text-blue-600" />
      </div>
    );
  }

  const avgRating = (responses: FeedbackResponseRow[]) => {
    if (responses.length === 0) return 0;
    const sum = responses.reduce((acc, r) => acc + r.rating, 0);
    return (sum / responses.length).toFixed(1);
  };

  return (
    <div>
      <h2 className="mb-6 text-2xl font-bold text-slate-900">Classes</h2>

      <div className="space-y-3">
        {classes.map((cls) => {
          const cus = allClassUsthads.filter((cu) => cu.class_id === cls.id);
          const isExpanded = expandedClass === cls.id;
          return (
            <div
              key={cls.id}
              className="overflow-hidden rounded-2xl border border-slate-200 bg-white"
            >
              <button
                onClick={() =>
                  setExpandedClass(isExpanded ? null : cls.id)
                }
                className="flex w-full items-center justify-between px-5 py-4 transition hover:bg-slate-50"
              >
                <span className="text-lg font-semibold text-slate-800">
                  {cls.name}
                </span>
                <div className="flex items-center gap-3">
                  <span className="text-sm text-slate-500">
                    {cus.length} Usthads
                  </span>
                  <ChevronRight
                    className={`h-5 w-5 text-slate-400 transition-transform ${
                      isExpanded ? 'rotate-90' : ''
                    }`}
                  />
                </div>
              </button>

              {isExpanded && (
                <div className="border-t border-slate-100">
                  {cus.length === 0 ? (
                    <p className="px-5 py-8 text-center text-sm text-slate-400">
                      No Usthads assigned to this class.
                    </p>
                  ) : (
                    <div className="divide-y divide-slate-100">
                      {cus.map((cu) => (
                        <div key={cu.id} className="px-5 py-4">
                          <div className="mb-3 flex items-center justify-between">
                            <p className="font-medium text-slate-800">
                              {cu.usthad.name}
                            </p>
                          </div>
                          {cu.class_usthad_subjects.length === 0 ? (
                            <p className="text-sm text-slate-400">
                              No subjects assigned
                            </p>
                          ) : (
                            <>
                            <UsthadStudentProgress
                              cusIds={cu.class_usthad_subjects.map((s) => s.id)}
                              totalSubjects={cu.class_usthad_subjects.length}
                              studentCount={settings?.default_feedback_limit ?? 5}
                            />
                            <div className="space-y-3">
                              {cu.class_usthad_subjects.map((cus) => {
                                const limit = getEffectiveLimit(
                                  cus,
                                  settings?.default_feedback_limit ?? 5
                                );
                                return (
                                  <div
                                    key={cus.id}
                                    className="flex flex-wrap items-center gap-3 rounded-xl bg-slate-50 p-3"
                                  >
                                    <div className="min-w-0 flex-1">
                                      <p className="text-sm font-medium text-slate-700">
                                        {cus.subject.name}
                                      </p>
                                      <div className="mt-1 flex items-center gap-3 text-xs text-slate-500">
                                        <span>
                                          Responses:{' '}
                                          {editingLimit === cus.id ? (
                                            '—'
                                          ) : (
                                            <LoadResponseCount
                                              cusId={cus.id}
                                              limit={limit}
                                            />
                                          )}
                                        </span>
                                        {editingLimit === cus.id ? (
                                          <div className="flex items-center gap-2">
                                            <input
                                              type="number"
                                              min={1}
                                              value={limitValue}
                                              onChange={(e) =>
                                                setLimitValue(e.target.value)
                                              }
                                              className="w-16 rounded-lg border border-slate-300 px-2 py-1 text-sm"
                                            />
                                            <button
                                              onClick={() =>
                                                handleSaveLimit(cus.id)
                                              }
                                              className="rounded-lg bg-blue-600 px-3 py-1 text-xs font-medium text-white hover:bg-blue-700"
                                            >
                                              Save
                                            </button>
                                            <button
                                              onClick={() =>
                                                handleResetLimit(cus.id)
                                              }
                                              className="rounded-lg bg-slate-200 px-3 py-1 text-xs font-medium text-slate-600 hover:bg-slate-300"
                                            >
                                              Reset
                                            </button>
                                            <button
                                              onClick={() =>
                                                setEditingLimit(null)
                                              }
                                              className="text-slate-400 hover:text-slate-600"
                                            >
                                              <X className="h-4 w-4" />
                                            </button>
                                          </div>
                                        ) : (
                                          <button
                                            onClick={() => {
                                              setEditingLimit(cus.id);
                                              setLimitValue(String(limit));
                                            }}
                                            className="font-medium text-blue-600 hover:underline"
                                          >
                                            Limit: {limit}
                                          </button>
                                        )}
                                      </div>
                                    </div>
                                    <div className="flex flex-wrap items-center gap-2">
                                      <button
                                        onClick={() => handleView(cu, cus)}
                                        className="flex items-center gap-1 rounded-lg bg-blue-50 px-3 py-1.5 text-xs font-medium text-blue-700 transition hover:bg-blue-100"
                                      >
                                        <Eye className="h-3.5 w-3.5" />
                                        View
                                      </button>
                                      <button
                                        onClick={() =>
                                          handleView(cu, cus)
                                        }
                                        className="flex items-center gap-1 rounded-lg bg-emerald-50 px-3 py-1.5 text-xs font-medium text-emerald-700 transition hover:bg-emerald-100"
                                      >
                                        <FileText className="h-3.5 w-3.5" />
                                        PDF
                                      </button>
                                      {resetConfirm === cus.id ? (
                                        <div className="flex items-center gap-2">
                                          <button
                                            onClick={() =>
                                              handleResetFeedback(cus.id)
                                            }
                                            className="rounded-lg bg-red-600 px-3 py-1.5 text-xs font-medium text-white hover:bg-red-700"
                                          >
                                            Confirm Reset
                                          </button>
                                          <button
                                            onClick={() =>
                                              setResetConfirm(null)
                                            }
                                            className="rounded-lg bg-slate-200 px-3 py-1.5 text-xs font-medium text-slate-600"
                                          >
                                            Cancel
                                          </button>
                                        </div>
                                      ) : (
                                        <button
                                          onClick={() =>
                                            setResetConfirm(cus.id)
                                          }
                                          className="flex items-center gap-1 rounded-lg bg-orange-50 px-3 py-1.5 text-xs font-medium text-orange-700 transition hover:bg-orange-100"
                                        >
                                          <RotateCcw className="h-3.5 w-3.5" />
                                          Reset
                                        </button>
                                      )}
                                      <button
                                        onClick={() =>
                                          handleRemoveSubject(cus.id)
                                        }
                                        className="flex items-center gap-1 rounded-lg bg-red-50 px-3 py-1.5 text-xs font-medium text-red-700 transition hover:bg-red-100"
                                      >
                                        <Trash2 className="h-3.5 w-3.5" />
                                      </button>
                                    </div>
                                  </div>
                                );
                              })}
                            </div>
                            </>
                          )}
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              )}
            </div>
          );
        })}
      </div>

      {/* Detail Modal */}
      {detail && (
        <div
          className="fixed inset-0 z-50 flex items-start justify-center overflow-y-auto bg-black/40 p-4"
          onClick={() => setDetail(null)}
        >
          <div
            className="my-8 w-full max-w-2xl rounded-2xl bg-white p-6 shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            {detailLoading ? (
              <div className="flex h-40 items-center justify-center">
                <Loader2 className="h-8 w-8 animate-spin text-blue-600" />
              </div>
            ) : (
              <>
                <div className="mb-6 flex items-start justify-between">
                  <div>
                    <h3 className="text-xl font-bold text-slate-900">
                      Feedback Detail
                    </h3>
                    <div className="mt-2 space-y-1 text-sm text-slate-600">
                      <p>
                        <span className="text-slate-400">Class: </span>
                        {detail.cls.name}
                      </p>
                      <p>
                        <span className="text-slate-400">Usthad: </span>
                        {detail.usthad.name}
                      </p>
                      <p>
                        <span className="text-slate-400">Subject: </span>
                        {detail.subject.name}
                      </p>
                    </div>
                  </div>
                  <button
                    onClick={() => setDetail(null)}
                    className="rounded-lg p-2 text-slate-400 transition hover:bg-slate-100 hover:text-slate-600"
                  >
                    <X className="h-5 w-5" />
                  </button>
                </div>

                <div className="mb-6 grid grid-cols-3 gap-4">
                  <div className="rounded-xl bg-slate-50 p-4 text-center">
                    <p className="text-2xl font-bold text-slate-900">
                      {detail.responses.length} / {detail.limit}
                    </p>
                    <p className="mt-1 text-xs text-slate-500">Responses</p>
                  </div>
                  <div className="rounded-xl bg-amber-50 p-4 text-center">
                    <p className="text-2xl font-bold text-amber-700">
                      {avgRating(detail.responses)}
                    </p>
                    <p className="mt-1 text-xs text-slate-500">
                      Average Rating
                    </p>
                  </div>
                  <div className="rounded-xl bg-blue-50 p-4 text-center">
                    <p className="text-2xl font-bold text-blue-700">
                      {detail.responses.length >= detail.limit
                        ? 'Complete'
                        : 'Pending'}
                    </p>
                    <p className="mt-1 text-xs text-slate-500">Status</p>
                  </div>
                </div>

                {detail.responses.length > 0 && (
                  <div className="mb-6">
                    <h4 className="mb-3 text-sm font-semibold text-slate-700">
                      Rating Distribution
                    </h4>
                    <div className="space-y-2">
                      {[5, 4, 3, 2, 1].map((star) => {
                        const count = detail.responses.filter(
                          (r) => r.rating === star
                        ).length;
                        const pct =
                          (count / detail.responses.length) * 100;
                        return (
                          <div
                            key={star}
                            className="flex items-center gap-3 text-sm"
                          >
                            <span className="w-16 text-slate-600">
                              {star} star{star > 1 ? 's' : ''}
                            </span>
                            <div className="h-2 flex-1 overflow-hidden rounded-full bg-slate-100">
                              <div
                                className="h-full rounded-full bg-amber-400"
                                style={{ width: `${pct}%` }}
                              />
                            </div>
                            <span className="w-8 text-right font-medium text-slate-700">
                              {count}
                            </span>
                          </div>
                        );
                      })}
                    </div>
                  </div>
                )}

                <div className="space-y-3">
                  {detail.responses.length === 0 ? (
                    <p className="py-8 text-center text-sm text-slate-400">
                      No feedback responses yet.
                    </p>
                  ) : (
                    detail.responses.map((r) => (
                      <div
                        key={r.id}
                        className="rounded-xl border border-slate-100 p-4"
                      >
                        <div className="flex flex-nowrap items-center justify-between gap-3">
                          <StarRating value={r.rating} readOnly size={18} />
                          <span className="shrink-0 text-xs text-slate-400">
                            {new Date(r.created_at).toLocaleDateString()}
                          </span>
                        </div>
                        {r.comment && (
                          <p className="mt-2 whitespace-pre-wrap break-words text-sm text-slate-600">
                            "{r.comment}"
                          </p>
                        )}
                        {!detail.requireStudentName && r.student_name && (
                          <p className="mt-1 text-xs text-slate-400">
                            — {r.student_name}
                          </p>
                        )}
                        {r.student_number && (
                          <p className="mt-1 text-xs text-slate-400">
                            Student {r.student_number}
                          </p>
                        )}
                      </div>
                    ))
                  )}
                </div>
              </>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

function LoadResponseCount({
  cusId,
  limit,
}: {
  cusId: string;
  limit: number;
}) {
  const [count, setCount] = useState<number | null>(null);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const { count: c } = await supabase
          .from('feedback_responses')
          .select('*', { count: 'exact', head: true })
          .eq('class_usthad_subject_id', cusId);
        if (!cancelled) setCount(c ?? 0);
      } catch {
        if (!cancelled) setCount(0);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [cusId]);

  if (count === null) return <span className="animate-pulse">… / {limit}</span>;
  const isComplete = count >= limit;
  return (
    <span className={isComplete ? 'font-medium text-green-600' : ''}>
      {count} / {limit} {isComplete && '· Complete'}
    </span>
  );
}

function UsthadStudentProgress({
  cusIds,
  totalSubjects,
  studentCount,
}: {
  cusIds: string[];
  totalSubjects: number;
  studentCount: number;
}) {
  const [progress, setProgress] = useState<
    { studentNumber: number; submitted: number }[] | null
  >(null);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const responses = await fetchResponsesByCusIds(cusIds);
        if (cancelled) return;
        const result = Array.from({ length: studentCount }, (_, i) => {
          const num = i + 1;
          const submitted = responses.filter(
            (r) => r.student_number === num
          ).length;
          return { studentNumber: num, submitted };
        });
        if (!cancelled) setProgress(result);
      } catch {
        if (!cancelled) setProgress([]);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [cusIds, studentCount]);

  if (progress === null) {
    return (
      <div className="mb-4 rounded-xl bg-blue-50 p-3">
        <p className="mb-2 text-xs font-semibold uppercase tracking-wide text-blue-600">
          Student Progress
        </p>
        <p className="animate-pulse text-sm text-slate-400">Loading…</p>
      </div>
    );
  }

  return (
    <div className="mb-4 rounded-xl bg-blue-50 p-3">
      <p className="mb-2 text-xs font-semibold uppercase tracking-wide text-blue-600">
        Student Progress ({progress.length} students · {totalSubjects}{' '}
        {totalSubjects === 1 ? 'subject' : 'subjects'})
      </p>
      <div className="grid grid-cols-1 gap-2 sm:grid-cols-2">
        {progress.map((p) => {
          const isDone = p.submitted >= totalSubjects;
          const pct =
            totalSubjects > 0
              ? Math.min((p.submitted / totalSubjects) * 100, 100)
              : 0;
          return (
            <div
              key={p.studentNumber}
              className="flex items-center gap-2 rounded-lg bg-white px-3 py-2"
            >
              <span className="text-sm font-medium text-slate-700">
                Student {p.studentNumber}
              </span>
              <div className="h-2 flex-1 overflow-hidden rounded-full bg-slate-100">
                <div
                  className={`h-full rounded-full transition-all duration-500 ${
                    isDone ? 'bg-green-500' : 'bg-blue-500'
                  }`}
                  style={{ width: `${pct}%` }}
                />
              </div>
              <span
                className={`w-16 text-right text-xs font-medium ${
                  isDone ? 'text-green-600' : 'text-slate-600'
                }`}
              >
                {p.submitted} / {totalSubjects}
              </span>
            </div>
          );
        })}
      </div>
    </div>
  );
}

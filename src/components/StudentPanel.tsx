import { useCallback, useEffect, useState } from 'react';
import { ArrowLeft, ArrowRight, CheckCircle, Download, FileText, FolderOpen, GraduationCap, Home, Loader2, MessageSquare, User } from 'lucide-react';
import StarRating from '@/components/StarRating';
import {
  fetchClasses,
  fetchFeedbackSettings,
  fetchResponseCount,
  fetchUsthadsByClass,
  submitFeedback,
} from '@/services/feedbackService';
import { supabase } from '@/lib/supabase';
import type {
  ClassRow,
  ClassUsthadWithDetails,
  DocumentRow,
  FeedbackSettings,
} from '@/types/database';
import { getEffectiveLimit } from '@/services/feedbackService';

type Step = 'class' | 'student' | 'usthad' | 'subject' | 'form' | 'success' | 'documents';

export default function StudentPanel() {
  const [step, setStep] = useState<Step>('class');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [classes, setClasses] = useState<ClassRow[]>([]);
  const [settings, setSettings] = useState<FeedbackSettings | null>(null);

  const [selectedClass, setSelectedClass] = useState<ClassRow | null>(null);
  const [usthads, setUsthads] = useState<ClassUsthadWithDetails[]>([]);
  const [selectedUsthad, setSelectedUsthad] =
    useState<ClassUsthadWithDetails | null>(null);
  const [selectedSubjectId, setSelectedSubjectId] = useState<string | null>(
    null
  );

  const [responseCount, setResponseCount] = useState(0);
  const [rating, setRating] = useState(0);
  const [comment, setComment] = useState('');
  const [studentName, setStudentName] = useState('');
  const [studentNumber, setStudentNumber] = useState<number | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [documents, setDocuments] = useState<DocumentRow[]>([]);
  const [docsLoading, setDocsLoading] = useState(false);

  const loadData = useCallback(async () => {
    try {
      setLoading(true);
      const [cls, stg] = await Promise.all([
        fetchClasses(),
        fetchFeedbackSettings(),
      ]);
      setClasses(cls);
      setSettings(stg);
    } catch (err) {
      setError('Failed to load data. Please try again.');
      console.error(err);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadData();
  }, [loadData]);

  const handleSelectClass = useCallback((cls: ClassRow) => {
    setSelectedClass(cls);
    setStudentNumber(null);
    setStep('student');
  }, []);

  const handleSelectStudentNumber = useCallback(async (num: number) => {
    setStudentNumber(num);
    try {
      setLoading(true);
      const data = await fetchUsthadsByClass(selectedClass!.id);
      const filtered = data.filter(
        (u) => u.class_usthad_subjects.length > 0
      );
      setUsthads(filtered);
      setStep('usthad');
    } catch (err) {
      setError('Failed to load Usthads.');
      console.error(err);
    } finally {
      setLoading(false);
    }
  }, [selectedClass]);

  const handleSelectUsthad = useCallback(
    (usthad: ClassUsthadWithDetails) => {
      setSelectedUsthad(usthad);
      if (usthad.class_usthad_subjects.length === 1) {
        setSelectedSubjectId(usthad.class_usthad_subjects[0].id);
        setStep('form');
      } else if (usthad.class_usthad_subjects.length === 0) {
        setError('No subjects assigned to this Usthad.');
      } else {
        setSelectedSubjectId(null);
        setStep('subject');
      }
    },
    []
  );

  const loadResponseCount = useCallback(async () => {
    if (!selectedSubjectId) return;
    try {
      const count = await fetchResponseCount(selectedSubjectId);
      setResponseCount(count);
    } catch (err) {
      console.error(err);
    }
  }, [selectedSubjectId]);

  useEffect(() => {
    if (step === 'form' && selectedSubjectId) {
      loadResponseCount();
    }
  }, [step, selectedSubjectId, loadResponseCount]);

  const selectedSubject = selectedUsthad?.class_usthad_subjects.find(
    (s) => s.id === selectedSubjectId
  );

  const effectiveLimit = selectedSubject && settings
    ? getEffectiveLimit(selectedSubject, settings.default_feedback_limit)
    : 0;

  const isComplete = responseCount >= effectiveLimit;

  const handleSubmit = useCallback(async () => {
    if (rating === 0 || !selectedSubjectId) return;
    try {
      setSubmitting(true);
      await submitFeedback(
        selectedSubjectId,
        rating,
        comment.trim() || null,
        settings?.require_student_name ? studentName.trim() || null : null,
        studentNumber
      );
      setStep('success');
    } catch (err) {
      setError('Failed to submit feedback. Please try again.');
      console.error(err);
    } finally {
      setSubmitting(false);
    }
  }, [rating, selectedSubjectId, comment, studentName, settings, studentNumber]);

  const resetAll = useCallback(() => {
    setStep('class');
    setSelectedClass(null);
    setSelectedUsthad(null);
    setSelectedSubjectId(null);
    setRating(0);
    setComment('');
    setStudentName('');
    setStudentNumber(null);
    setResponseCount(0);
    setError(null);
  }, []);

  const loadDocuments = useCallback(async () => {
    try {
      setDocsLoading(true);
      const { data, error: docError } = await supabase
        .from('documents')
        .select('*')
        .order('created_at', { ascending: false });
      if (docError) throw docError;
      setDocuments(data ?? []);
    } catch (err) {
      console.error(err);
    } finally {
      setDocsLoading(false);
    }
  }, []);

  const handleViewDocuments = useCallback(() => {
    loadDocuments();
    setStep('documents');
  }, [loadDocuments]);

  if (loading && step === 'class') {
    return (
      <div className="flex min-h-screen items-center justify-center bg-gradient-to-br from-slate-50 to-blue-50">
        <Loader2 className="h-8 w-8 animate-spin text-blue-600" />
      </div>
    );
  }

  if (error && step === 'class') {
    return (
      <div className="flex min-h-screen flex-col items-center justify-center gap-4 bg-gradient-to-br from-slate-50 to-blue-50 p-6">
        <p className="text-center text-red-600">{error}</p>
        <button
          onClick={() => {
            setError(null);
            loadData();
          }}
          className="rounded-lg bg-blue-600 px-6 py-3 font-medium text-white transition hover:bg-blue-700"
        >
          Try Again
        </button>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50">
      {/* Header */}
      <header className="sticky top-0 z-10 border-b border-slate-200 bg-white/80 backdrop-blur-md">
        <div className="mx-auto flex max-w-2xl items-center justify-between px-4 py-4">
          <div className="flex items-center gap-2">
            <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-blue-600">
              <GraduationCap className="h-5 w-5 text-white" />
            </div>
            <span className="text-sm font-bold text-slate-800">
              Malik Deenar Academy
            </span>
          </div>
          {step !== 'class' && step !== 'student' && step !== 'success' && step !== 'documents' && (
            <button
              onClick={resetAll}
              className="flex items-center gap-1 text-sm font-medium text-slate-600 transition hover:text-blue-600"
            >
              <Home className="h-4 w-4" />
              Home
            </button>
          )}
        </div>
      </header>

      <main className="mx-auto max-w-2xl px-4 py-6">
        {/* Error toast */}
        {error && step !== 'class' && (
          <div className="mb-4 rounded-xl bg-red-50 px-4 py-3 text-sm text-red-700">
            {error}
          </div>
        )}

        {/* STEP: CLASS SELECTION */}
        {step === 'class' && (
          <div>
            <div className="mb-6 text-center">
              <h1 className="text-3xl font-bold text-slate-900">
                Malik Deenar Islamic Academy
              </h1>
              <p className="mt-2 text-base text-slate-600">
                Your feedback helps improve teaching and learning.
              </p>
            </div>
            <h2 className="mb-4 text-sm font-semibold uppercase tracking-wide text-slate-500">
              Select Class
            </h2>
            <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
              {classes.map((cls) => (
                <button
                  key={cls.id}
                  onClick={() => handleSelectClass(cls)}
                  className="group flex aspect-square flex-col items-center justify-center gap-2 rounded-2xl border-2 border-slate-200 bg-white p-4 transition-all duration-200 hover:border-blue-500 hover:shadow-lg hover:shadow-blue-100 active:scale-95"
                >
                  <GraduationCap className="h-8 w-8 text-slate-400 transition group-hover:text-blue-600" />
                  <span className="text-base font-bold text-slate-700">
                    {cls.name.replace('Class ', 'Class ')}
                  </span>
                </button>
              ))}
            </div>

            <div className="mt-8 border-t border-slate-200 pt-6">
              <button
                onClick={handleViewDocuments}
                className="flex w-full items-center justify-center gap-3 rounded-2xl border-2 border-emerald-200 bg-emerald-50 px-5 py-4 font-semibold text-emerald-700 transition-all duration-200 hover:border-emerald-400 hover:shadow-md active:scale-[0.98]"
              >
                <FolderOpen className="h-6 w-6" />
                View Documents
              </button>
            </div>
          </div>
        )}

        {/* STEP: STUDENT NUMBER SELECTION */}
        {step === 'student' && selectedClass && settings && (
          <div>
            <button
              onClick={() => setStep('class')}
              className="mb-4 flex items-center gap-1 text-sm font-medium text-slate-600 transition hover:text-blue-600"
            >
              <ArrowLeft className="h-4 w-4" />
              Back to Classes
            </button>
            <div className="mb-6">
              <h2 className="text-2xl font-bold text-slate-900">
                {selectedClass.name}
              </h2>
              <p className="mt-1 text-sm text-slate-500">
                Which student are you? Select your number
              </p>
            </div>
            <div className="grid grid-cols-3 gap-3 sm:grid-cols-5">
              {Array.from({ length: settings.default_feedback_limit }, (_, i) => i + 1).map((num) => (
                <button
                  key={num}
                  onClick={() => handleSelectStudentNumber(num)}
                  className="group flex aspect-square flex-col items-center justify-center gap-1.5 rounded-2xl border-2 border-slate-200 bg-white p-3 transition-all duration-200 hover:border-blue-500 hover:shadow-lg hover:shadow-blue-100 active:scale-95"
                >
                  <User className="h-6 w-6 text-slate-400 transition group-hover:text-blue-600" />
                  <span className="text-sm font-bold text-slate-700">
                    Student {num}
                  </span>
                </button>
              ))}
            </div>
          </div>
        )}

        {/* STEP: USTHAD SELECTION */}
        {step === 'usthad' && selectedClass && (
          <div>
            <button
              onClick={() => setStep('class')}
              className="mb-4 flex items-center gap-1 text-sm font-medium text-slate-600 transition hover:text-blue-600"
            >
              <ArrowLeft className="h-4 w-4" />
              Back to Classes
            </button>
            <div className="mb-6">
              <h2 className="text-2xl font-bold text-slate-900">
                {selectedClass.name}
              </h2>
              <p className="mt-1 text-sm text-slate-500">Select your Usthad</p>
            </div>
            <div className="space-y-3">
              {usthads.length === 0 ? (
                <p className="rounded-xl border-2 border-slate-200 bg-white px-5 py-8 text-center text-sm text-slate-400">
                  No Usthads with subjects assigned to this class yet.
                </p>
              ) : (
                usthads.map((u) => (
                  <button
                    key={u.id}
                    onClick={() => handleSelectUsthad(u)}
                    className="flex w-full items-center justify-between rounded-xl border-2 border-slate-200 bg-white px-5 py-4 text-left transition-all duration-200 hover:border-blue-500 hover:shadow-md active:scale-[0.98]"
                  >
                    <span className="font-medium text-slate-800">
                      {u.usthad.name}
                    </span>
                    <ArrowRight className="h-5 w-5 text-slate-400" />
                  </button>
                ))
              )}
            </div>
          </div>
        )}

        {/* STEP: SUBJECT SELECTION */}
        {step === 'subject' && selectedUsthad && (
          <div>
            <button
              onClick={() => setStep('usthad')}
              className="mb-4 flex items-center gap-1 text-sm font-medium text-slate-600 transition hover:text-blue-600"
            >
              <ArrowLeft className="h-4 w-4" />
              Back to Usthads
            </button>
            <div className="mb-6">
              <h2 className="text-xl font-bold text-slate-900">
                {selectedUsthad.usthad.name}
              </h2>
              <p className="mt-1 text-sm text-slate-500">Select a subject</p>
            </div>
            <div className="space-y-3">
              {selectedUsthad.class_usthad_subjects.map((s) => (
                <button
                  key={s.id}
                  onClick={() => {
                    setSelectedSubjectId(s.id);
                    setStep('form');
                  }}
                  className="flex w-full items-center justify-between rounded-xl border-2 border-slate-200 bg-white px-5 py-4 text-left transition-all duration-200 hover:border-blue-500 hover:shadow-md active:scale-[0.98]"
                >
                  <span className="font-medium text-slate-800">
                    {s.subject.name}
                  </span>
                  <ArrowRight className="h-5 w-5 text-slate-400" />
                </button>
              ))}
            </div>
          </div>
        )}

        {/* STEP: FEEDBACK FORM */}
        {step === 'form' && selectedClass && selectedUsthad && selectedSubject && (
          <div>
            <button
              onClick={() => {
                if (selectedUsthad.class_usthad_subjects.length > 1) {
                  setStep('subject');
                } else {
                  setStep('usthad');
                }
              }}
              className="mb-4 flex items-center gap-1 text-sm font-medium text-slate-600 transition hover:text-blue-600"
            >
              <ArrowLeft className="h-4 w-4" />
              Back
            </button>

            {/* Selection summary */}
            <div className="mb-6 rounded-xl bg-blue-50 p-4">
              <div className="space-y-1.5">
                <div className="flex items-center gap-2">
                  <span className="text-xs font-semibold uppercase text-blue-700">
                    {selectedClass.name}
                  </span>
                </div>
                <div className="text-sm text-slate-700">
                  <span className="text-slate-500">Usthad: </span>
                  <span className="font-medium">
                    {selectedUsthad.usthad.name}
                  </span>
                </div>
                <div className="text-sm text-slate-700">
                  <span className="text-slate-500">Subject: </span>
                  <span className="font-medium">
                    {selectedSubject.subject.name}
                  </span>
                </div>
                <div className="mt-2 flex items-center gap-2 text-sm">
                  <span className="font-semibold text-blue-700">
                    Feedback: {responseCount} / {effectiveLimit}
                  </span>
                  <div className="h-2 flex-1 overflow-hidden rounded-full bg-blue-100">
                    <div
                      className="h-full rounded-full bg-blue-500 transition-all duration-500"
                      style={{
                        width: `${Math.min(
                          (responseCount / effectiveLimit) * 100,
                          100
                        )}%`,
                      }}
                    />
                  </div>
                </div>
              </div>
            </div>

            {isComplete ? (
              <div className="rounded-2xl border-2 border-amber-200 bg-amber-50 p-8 text-center">
                <CheckCircle className="mx-auto h-12 w-12 text-amber-500" />
                <p className="mt-4 text-lg font-semibold text-amber-900">
                  Feedback collection for this Usthad/subject is complete.
                </p>
                <p className="mt-2 text-sm text-amber-700">
                  The response limit of {effectiveLimit} has been reached.
                </p>
                <button
                  onClick={resetAll}
                  className="mt-6 rounded-xl bg-amber-600 px-6 py-3 font-medium text-white transition hover:bg-amber-700"
                >
                  Back to Home
                </button>
              </div>
            ) : (
              <div className="space-y-6">
                {/* Rating */}
                <div className="rounded-2xl border-2 border-slate-200 bg-white p-6">
                  <h3 className="mb-4 text-lg font-bold text-slate-900">
                    Rate the Usthad
                  </h3>
                  <StarRating value={rating} onChange={setRating} size={48} />
                  <p className="mt-3 text-sm text-slate-500">
                    {rating === 0
                      ? 'Select a rating from 1 to 5 stars'
                      : `You selected ${rating} star${rating > 1 ? 's' : ''}`}
                  </p>
                </div>

                {/* Student name (if enabled) */}
                {settings?.require_student_name && (
                  <div className="rounded-2xl border-2 border-slate-200 bg-white p-6">
                    <label className="mb-2 block text-sm font-semibold text-slate-700">
                      Student Name (optional)
                    </label>
                    <input
                      type="text"
                      value={studentName}
                      onChange={(e) => setStudentName(e.target.value)}
                      placeholder="Enter your name"
                      className="w-full rounded-xl border-2 border-slate-200 px-4 py-3 text-base outline-none transition focus:border-blue-500"
                    />
                  </div>
                )}

                {/* Comment */}
                <div className="rounded-2xl border-2 border-slate-200 bg-white p-6">
                  <label className="mb-2 flex items-center gap-2 text-sm font-semibold text-slate-700">
                    <MessageSquare className="h-4 w-4 text-slate-400" />
                    Write your feedback or suggestion
                  </label>
                  <textarea
                    value={comment}
                    onChange={(e) => setComment(e.target.value)}
                    placeholder="Share your feedback about the teaching, explanation, class experience, or suggestions for improvement..."
                    rows={5}
                    className="w-full resize-none rounded-xl border-2 border-slate-200 px-4 py-3 text-base outline-none transition focus:border-blue-500"
                  />
                </div>

                {/* Submit */}
                <button
                  onClick={handleSubmit}
                  disabled={rating === 0 || submitting}
                  className="flex w-full items-center justify-center gap-2 rounded-2xl bg-blue-600 py-4 text-lg font-bold text-white transition-all duration-200 hover:bg-blue-700 active:scale-[0.98] disabled:cursor-not-allowed disabled:bg-slate-300"
                >
                  {submitting ? (
                    <Loader2 className="h-5 w-5 animate-spin" />
                  ) : (
                    'Submit Feedback'
                  )}
                </button>
                {rating === 0 && (
                  <p className="text-center text-sm text-slate-400">
                    Please select a star rating to submit
                  </p>
                )}
              </div>
            )}
          </div>
        )}

        {/* STEP: DOCUMENTS */}
        {step === 'documents' && (
          <div>
            <button
              onClick={() => setStep('class')}
              className="mb-4 flex items-center gap-1 text-sm font-medium text-slate-600 transition hover:text-blue-600"
            >
              <ArrowLeft className="h-4 w-4" />
              Back to Home
            </button>
            <div className="mb-6">
              <h2 className="text-2xl font-bold text-slate-900">Documents</h2>
              <p className="mt-1 text-sm text-slate-500">
                Download and view shared documents
              </p>
            </div>
            {docsLoading ? (
              <div className="flex justify-center py-12">
                <Loader2 className="h-8 w-8 animate-spin text-blue-600" />
              </div>
            ) : documents.length === 0 ? (
              <div className="rounded-2xl border-2 border-dashed border-slate-200 bg-white py-16 text-center">
                <FileText className="mx-auto h-12 w-12 text-slate-300" />
                <p className="mt-4 text-sm text-slate-400">
                  No documents available yet.
                </p>
              </div>
            ) : (
              <div className="space-y-3">
                {documents.map((doc) => (
                  <div
                    key={doc.id}
                    className="flex items-center gap-4 rounded-xl border-2 border-slate-200 bg-white p-4 transition hover:border-blue-300 hover:shadow-sm"
                  >
                    <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-blue-50">
                      <FileText className="h-5 w-5 text-blue-600" />
                    </div>
                    <div className="min-w-0 flex-1">
                      <p className="truncate font-semibold text-slate-800">
                        {doc.title}
                      </p>
                      {doc.description && (
                        <p className="truncate text-sm text-slate-500">
                          {doc.description}
                        </p>
                      )}
                      <p className="mt-0.5 text-xs text-slate-400">
                        {new Date(doc.created_at).toLocaleDateString('en-GB', {
                          day: 'numeric',
                          month: 'short',
                          year: 'numeric',
                        })}
                      </p>
                    </div>
                    <a
                      href={doc.file_url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="flex shrink-0 items-center gap-1.5 rounded-lg bg-blue-50 px-4 py-2.5 text-sm font-medium text-blue-700 transition hover:bg-blue-100"
                    >
                      <Download className="h-4 w-4" />
                      Open
                    </a>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {/* STEP: SUCCESS */}
        {step === 'success' && (
          <div className="flex min-h-[60vh] flex-col items-center justify-center text-center">
            <div className="rounded-full bg-green-100 p-6">
              <CheckCircle className="h-16 w-16 text-green-600" />
            </div>
            <h2 className="mt-6 text-2xl font-bold text-slate-900">
              Feedback Submitted Successfully
            </h2>
            <p className="mt-2 text-base text-slate-600">
              Thank you for your valuable feedback.
            </p>
            <div className="mt-8 flex flex-col gap-3 sm:flex-row">
              <button
                onClick={resetAll}
                className="rounded-xl border-2 border-blue-200 bg-blue-50 px-6 py-3 font-semibold text-blue-700 transition hover:bg-blue-100"
              >
                Give Another Feedback
              </button>
              <button
                onClick={resetAll}
                className="rounded-xl bg-slate-100 px-6 py-3 font-semibold text-slate-700 transition hover:bg-slate-200"
              >
                Back to Home
              </button>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}

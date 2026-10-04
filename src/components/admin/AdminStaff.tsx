import { useCallback, useEffect, useState } from 'react';
import {
  BookPlus,
  Loader2,
  Pencil,
  Plus,
  Search,
  Trash2,
  UserPlus,
  X,
} from 'lucide-react';
import {
  addSubject,
  addUsthad,
  assignSubjectToUsthad,
  assignUsthadToClass,
  deleteSubject,
  deleteUsthad,
  fetchAllClassUsthads,
  fetchAllSubjects,
  fetchAllUsthads,
  fetchClasses,
  removeSubjectFromUsthad,
  removeUsthadFromClass,
  updateSubject,
  updateUsthad,
} from '@/services/feedbackService';
import type {
  ClassRow,
  ClassUsthadRow,
  ClassUsthadSubjectRow,
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

export default function AdminStaff() {
  const [loading, setLoading] = useState(true);
  const [usthads, setUsthads] = useState<UsthadRow[]>([]);
  const [subjects, setSubjects] = useState<SubjectRow[]>([]);
  const [classes, setClasses] = useState<ClassRow[]>([]);
  const [allClassUsthads, setAllClassUsthads] = useState<ClassUsthadFull[]>([]);
  const [search, setSearch] = useState('');
  const [subjectSearch, setSubjectSearch] = useState('');
  const [showUsthadModal, setShowUsthadModal] = useState(false);
  const [editingUsthad, setEditingUsthad] = useState<UsthadRow | null>(null);
  const [usthadName, setUsthadName] = useState('');
  const [showSubjectModal, setShowSubjectModal] = useState(false);
  const [editingSubject, setEditingSubject] = useState<SubjectRow | null>(null);
  const [subjectName, setSubjectName] = useState('');
  const [showAssignModal, setShowAssignModal] = useState(false);
  const [assignUsthad, setAssignUsthad] = useState<UsthadRow | null>(null);
  const [assignClassId, setAssignClassId] = useState('');
  const [assignSubjectId, setAssignSubjectId] = useState('');
  const [error, setError] = useState<string | null>(null);

  const loadData = useCallback(async () => {
    try {
      setLoading(true);
      const [u, s, c, cu] = await Promise.all([
        fetchAllUsthads(),
        fetchAllSubjects(),
        fetchClasses(),
        fetchAllClassUsthads() as Promise<ClassUsthadFull[]>,
      ]);
      setUsthads(u);
      setSubjects(s);
      setClasses(c);
      setAllClassUsthads(cu);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadData();
  }, [loadData]);

  const handleSaveUsthad = useCallback(async () => {
    if (!usthadName.trim()) return;
    try {
      setError(null);
      if (editingUsthad) {
        await updateUsthad(editingUsthad.id, usthadName.trim());
      } else {
        await addUsthad(usthadName.trim());
      }
      setShowUsthadModal(false);
      setEditingUsthad(null);
      setUsthadName('');
      await loadData();
    } catch (err) {
      setError('Failed to save Usthad. Name may already exist.');
      console.error(err);
    }
  }, [usthadName, editingUsthad, loadData]);

  const handleDeleteUsthad = useCallback(
    async (id: string) => {
      if (!confirm('Delete this Usthad? This will remove all their class assignments and feedback.')) return;
      try {
        await deleteUsthad(id);
        await loadData();
      } catch (err) {
        setError('Failed to delete Usthad.');
        console.error(err);
      }
    },
    [loadData]
  );

  const handleSaveSubject = useCallback(async () => {
    if (!subjectName.trim()) return;
    try {
      setError(null);
      if (editingSubject) {
        await updateSubject(editingSubject.id, subjectName.trim());
      } else {
        await addSubject(subjectName.trim());
      }
      setShowSubjectModal(false);
      setEditingSubject(null);
      setSubjectName('');
      await loadData();
    } catch (err) {
      setError('Failed to save subject. Name may already exist.');
      console.error(err);
    }
  }, [subjectName, editingSubject, loadData]);

  const handleDeleteSubject = useCallback(
    async (id: string) => {
      if (!confirm('Delete this subject? This will remove all related feedback.')) return;
      try {
        await deleteSubject(id);
        await loadData();
      } catch (err) {
        setError('Failed to delete subject.');
        console.error(err);
      }
    },
    [loadData]
  );

  const handleAssignUsthadToClass = useCallback(async () => {
    if (!assignUsthad || !assignClassId) return;
    try {
      setError(null);
      await assignUsthadToClass(assignClassId, assignUsthad.id);
      setShowAssignModal(false);
      setAssignUsthad(null);
      setAssignClassId('');
      await loadData();
    } catch (err) {
      setError('Usthad may already be assigned to this class.');
      console.error(err);
    }
  }, [assignUsthad, assignClassId, loadData]);

  const handleAssignSubject = useCallback(async () => {
    if (!assignUsthad || !assignClassId || !assignSubjectId) return;
    try {
      setError(null);
      const cu = allClassUsthads.find(
        (c) => c.class_id === assignClassId && c.usthad_id === assignUsthad.id
      );
      if (!cu) {
        await assignUsthadToClass(assignClassId, assignUsthad.id);
        await loadData();
      }
      const updated = await fetchAllClassUsthads() as ClassUsthadFull[];
      const cuUpdated = updated.find(
        (c) => c.class_id === assignClassId && c.usthad_id === assignUsthad.id
      );
      if (cuUpdated) {
        await assignSubjectToUsthad(cuUpdated.id, assignSubjectId);
      }
      setShowAssignModal(false);
      setAssignUsthad(null);
      setAssignClassId('');
      setAssignSubjectId('');
      await loadData();
    } catch (err) {
      setError('Subject may already be assigned.');
      console.error(err);
    }
  }, [assignUsthad, assignClassId, assignSubjectId, allClassUsthads, loadData]);

  const handleRemoveUsthadFromClass = useCallback(
    async (classUsthadId: string) => {
      if (!confirm('Remove this Usthad from this class?')) return;
      try {
        await removeUsthadFromClass(classUsthadId);
        await loadData();
      } catch (err) {
        console.error(err);
      }
    },
    [loadData]
  );

  const handleRemoveSubject = useCallback(
    async (cusId: string) => {
      if (!confirm('Remove this subject from this Usthad?')) return;
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

  const filteredUsthads = usthads.filter((u) =>
    u.name.toLowerCase().includes(search.toLowerCase())
  );
  const filteredSubjects = subjects.filter((s) =>
    s.name.toLowerCase().includes(subjectSearch.toLowerCase())
  );

  return (
    <div>
      <div className="mb-6 flex items-center justify-between">
        <h2 className="text-2xl font-bold text-slate-900">
          Staff & Subjects
        </h2>
        <div className="flex gap-2">
          <button
            onClick={() => {
              setEditingUsthad(null);
              setUsthadName('');
              setShowUsthadModal(true);
            }}
            className="flex items-center gap-1.5 rounded-xl bg-blue-600 px-4 py-2.5 text-sm font-medium text-white transition hover:bg-blue-700"
          >
            <UserPlus className="h-4 w-4" />
            Add Usthad
          </button>
          <button
            onClick={() => {
              setEditingSubject(null);
              setSubjectName('');
              setShowSubjectModal(true);
            }}
            className="flex items-center gap-1.5 rounded-xl bg-emerald-600 px-4 py-2.5 text-sm font-medium text-white transition hover:bg-emerald-700"
          >
            <BookPlus className="h-4 w-4" />
            Add Subject
          </button>
        </div>
      </div>

      {error && (
        <div className="mb-4 rounded-xl bg-red-50 px-4 py-3 text-sm text-red-700">
          {error}
        </div>
      )}

      {/* Usthads List */}
      <div className="mb-8">
        <div className="mb-3 flex items-center gap-2">
          <h3 className="text-lg font-semibold text-slate-800">Usthads</h3>
          <span className="rounded-full bg-slate-100 px-2.5 py-0.5 text-xs font-medium text-slate-600">
            {usthads.length}
          </span>
        </div>
        <div className="relative mb-3">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search Usthads..."
            className="w-full rounded-xl border border-slate-200 py-2.5 pl-10 pr-4 text-sm outline-none transition focus:border-blue-500"
          />
        </div>
        <div className="space-y-2">
          {filteredUsthads.map((u) => {
            const assignments = allClassUsthads.filter(
              (cu) => cu.usthad_id === u.id
            );
            return (
              <div
                key={u.id}
                className="rounded-xl border border-slate-200 bg-white p-4"
              >
                <div className="flex items-center justify-between">
                  <span className="font-medium text-slate-800">{u.name}</span>
                  <div className="flex items-center gap-2">
                    <button
                      onClick={() => {
                        setAssignUsthad(u);
                        setAssignClassId('');
                        setAssignSubjectId('');
                        setShowAssignModal(true);
                      }}
                      className="flex items-center gap-1 rounded-lg bg-blue-50 px-3 py-1.5 text-xs font-medium text-blue-700 transition hover:bg-blue-100"
                    >
                      <Plus className="h-3.5 w-3.5" />
                      Assign
                    </button>
                    <button
                      onClick={() => {
                        setEditingUsthad(u);
                        setUsthadName(u.name);
                        setShowUsthadModal(true);
                      }}
                      className="rounded-lg bg-slate-100 p-2 text-slate-600 transition hover:bg-slate-200"
                    >
                      <Pencil className="h-3.5 w-3.5" />
                    </button>
                    <button
                      onClick={() => handleDeleteUsthad(u.id)}
                      className="rounded-lg bg-red-50 p-2 text-red-600 transition hover:bg-red-100"
                    >
                      <Trash2 className="h-3.5 w-3.5" />
                    </button>
                  </div>
                </div>
                {assignments.length > 0 && (
                  <div className="mt-3 space-y-2 border-t border-slate-100 pt-3">
                    {assignments.map((cu) => (
                      <div
                        key={cu.id}
                        className="rounded-lg bg-slate-50 p-2.5"
                      >
                        <div className="flex items-center justify-between">
                          <span className="text-xs font-semibold text-slate-600">
                            {cu.class.name}
                          </span>
                          <button
                            onClick={() => handleRemoveUsthadFromClass(cu.id)}
                            className="text-xs text-red-500 hover:underline"
                          >
                            Remove from class
                          </button>
                        </div>
                        {cu.class_usthad_subjects.length > 0 && (
                          <div className="mt-1.5 flex flex-wrap gap-1.5">
                            {cu.class_usthad_subjects.map((cus) => (
                              <span
                                key={cus.id}
                                className="flex items-center gap-1 rounded-md bg-white px-2 py-1 text-xs text-slate-600"
                              >
                                {cus.subject.name}
                                <button
                                  onClick={() => handleRemoveSubject(cus.id)}
                                  className="text-red-400 hover:text-red-600"
                                >
                                  <X className="h-3 w-3" />
                                </button>
                              </span>
                            ))}
                          </div>
                        )}
                      </div>
                    ))}
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </div>

      {/* Subjects List */}
      <div>
        <div className="mb-3 flex items-center gap-2">
          <h3 className="text-lg font-semibold text-slate-800">Subjects</h3>
          <span className="rounded-full bg-slate-100 px-2.5 py-0.5 text-xs font-medium text-slate-600">
            {subjects.length}
          </span>
        </div>
        <div className="relative mb-3">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
          <input
            type="text"
            value={subjectSearch}
            onChange={(e) => setSubjectSearch(e.target.value)}
            placeholder="Search subjects..."
            className="w-full rounded-xl border border-slate-200 py-2.5 pl-10 pr-4 text-sm outline-none transition focus:border-blue-500"
          />
        </div>
        <div className="flex flex-wrap gap-2">
          {filteredSubjects.map((s) => (
            <div
              key={s.id}
              className="flex items-center gap-2 rounded-xl border border-slate-200 bg-white px-3 py-2"
            >
              <span className="text-sm text-slate-700">{s.name}</span>
              <button
                onClick={() => {
                  setEditingSubject(s);
                  setSubjectName(s.name);
                  setShowSubjectModal(true);
                }}
                className="text-slate-400 transition hover:text-slate-600"
              >
                <Pencil className="h-3.5 w-3.5" />
              </button>
              <button
                onClick={() => handleDeleteSubject(s.id)}
                className="text-red-400 transition hover:text-red-600"
              >
                <Trash2 className="h-3.5 w-3.5" />
              </button>
            </div>
          ))}
        </div>
      </div>

      {/* Usthad Modal */}
      {showUsthadModal && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4"
          onClick={() => setShowUsthadModal(false)}
        >
          <div
            className="w-full max-w-md rounded-2xl bg-white p-6 shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <h3 className="mb-4 text-lg font-bold text-slate-900">
              {editingUsthad ? 'Edit Usthad' : 'Add Usthad'}
            </h3>
            <input
              type="text"
              value={usthadName}
              onChange={(e) => setUsthadName(e.target.value)}
              placeholder="Usthad name"
              autoFocus
              className="w-full rounded-xl border border-slate-200 px-4 py-3 text-base outline-none transition focus:border-blue-500"
            />
            <div className="mt-4 flex gap-3">
              <button
                onClick={handleSaveUsthad}
                className="flex-1 rounded-xl bg-blue-600 py-3 font-medium text-white transition hover:bg-blue-700"
              >
                {editingUsthad ? 'Update' : 'Add'}
              </button>
              <button
                onClick={() => setShowUsthadModal(false)}
                className="rounded-xl bg-slate-100 px-6 py-3 font-medium text-slate-600 transition hover:bg-slate-200"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Subject Modal */}
      {showSubjectModal && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4"
          onClick={() => setShowSubjectModal(false)}
        >
          <div
            className="w-full max-w-md rounded-2xl bg-white p-6 shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <h3 className="mb-4 text-lg font-bold text-slate-900">
              {editingSubject ? 'Edit Subject' : 'Add Subject'}
            </h3>
            <input
              type="text"
              value={subjectName}
              onChange={(e) => setSubjectName(e.target.value)}
              placeholder="Subject name (e.g. Thasawuf and Aqeeda)"
              autoFocus
              className="w-full rounded-xl border border-slate-200 px-4 py-3 text-base outline-none transition focus:border-blue-500"
            />
            <p className="mt-2 text-xs text-slate-400">
              Use commas to add multiple subjects at once (e.g. "Fiqh, Hindi").
              "and" stays as one subject.
            </p>
            <div className="mt-4 flex gap-3">
              <button
                onClick={handleSaveSubject}
                className="flex-1 rounded-xl bg-emerald-600 py-3 font-medium text-white transition hover:bg-emerald-700"
              >
                {editingSubject ? 'Update' : 'Add'}
              </button>
              <button
                onClick={() => setShowSubjectModal(false)}
                className="rounded-xl bg-slate-100 px-6 py-3 font-medium text-slate-600 transition hover:bg-slate-200"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Assign Modal */}
      {showAssignModal && assignUsthad && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4"
          onClick={() => setShowAssignModal(false)}
        >
          <div
            className="w-full max-w-md rounded-2xl bg-white p-6 shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <h3 className="mb-1 text-lg font-bold text-slate-900">
              Assign to {assignUsthad.name}
            </h3>
            <p className="mb-4 text-sm text-slate-500">
              Select a class and optionally a subject
            </p>
            <div className="space-y-4">
              <div>
                <label className="mb-1.5 block text-sm font-medium text-slate-700">
                  Class
                </label>
                <select
                  value={assignClassId}
                  onChange={(e) => setAssignClassId(e.target.value)}
                  className="w-full rounded-xl border border-slate-200 px-4 py-3 text-base outline-none transition focus:border-blue-500"
                >
                  <option value="">Select class...</option>
                  {classes.map((c) => (
                    <option key={c.id} value={c.id}>
                      {c.name}
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <label className="mb-1.5 block text-sm font-medium text-slate-700">
                  Subject (optional)
                </label>
                <select
                  value={assignSubjectId}
                  onChange={(e) => setAssignSubjectId(e.target.value)}
                  className="w-full rounded-xl border border-slate-200 px-4 py-3 text-base outline-none transition focus:border-blue-500"
                >
                  <option value="">No subject</option>
                  {subjects.map((s) => (
                    <option key={s.id} value={s.id}>
                      {s.name}
                    </option>
                  ))}
                </select>
              </div>
            </div>
            <div className="mt-4 flex gap-3">
              <button
                onClick={
                  assignSubjectId ? handleAssignSubject : handleAssignUsthadToClass
                }
                disabled={!assignClassId}
                className="flex-1 rounded-xl bg-blue-600 py-3 font-medium text-white transition hover:bg-blue-700 disabled:opacity-50"
              >
                Assign
              </button>
              <button
                onClick={() => setShowAssignModal(false)}
                className="rounded-xl bg-slate-100 px-6 py-3 font-medium text-slate-600 transition hover:bg-slate-200"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

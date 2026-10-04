import { useCallback, useEffect, useState } from 'react';
import { Loader2, Save } from 'lucide-react';
import {
  fetchFeedbackSettings,
  updateFeedbackSettings,
} from '@/services/feedbackService';
import type { FeedbackSettings } from '@/types/database';

export default function AdminSettings() {
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [settings, setSettings] = useState<FeedbackSettings | null>(null);
  const [defaultLimit, setDefaultLimit] = useState(5);
  const [requireName, setRequireName] = useState(false);
  const [institutionName, setInstitutionName] = useState('');
  const [saved, setSaved] = useState(false);

  const loadData = useCallback(async () => {
    try {
      setLoading(true);
      const s = await fetchFeedbackSettings();
      setSettings(s);
      setDefaultLimit(s.default_feedback_limit);
      setRequireName(s.require_student_name);
      setInstitutionName(s.institution_name);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadData();
  }, [loadData]);

  const handleSave = useCallback(async () => {
    try {
      setSaving(true);
      await updateFeedbackSettings({
        default_feedback_limit: defaultLimit,
        require_student_name: requireName,
        institution_name: institutionName,
      });
      setSaved(true);
      setTimeout(() => setSaved(false), 3000);
    } catch (err) {
      console.error(err);
    } finally {
      setSaving(false);
    }
  }, [defaultLimit, requireName, institutionName]);

  if (loading) {
    return (
      <div className="flex h-full items-center justify-center py-20">
        <Loader2 className="h-8 w-8 animate-spin text-blue-600" />
      </div>
    );
  }

  return (
    <div>
      <h2 className="mb-6 text-2xl font-bold text-slate-900">Settings</h2>

      <div className="max-w-lg space-y-6">
        {/* Default feedback limit */}
        <div className="rounded-2xl border border-slate-200 bg-white p-6">
          <h3 className="mb-2 text-lg font-semibold text-slate-800">
            Default Feedback Limit
          </h3>
          <p className="mb-4 text-sm text-slate-500">
            The default number of student responses allowed per
            Usthad/subject. Individual limits can be set per assignment.
          </p>
          <div className="flex items-center gap-3">
            <input
              type="number"
              min={1}
              max={100}
              value={defaultLimit}
              onChange={(e) => setDefaultLimit(parseInt(e.target.value, 10) || 1)}
              className="w-24 rounded-xl border border-slate-200 px-4 py-3 text-lg font-semibold text-slate-800 outline-none transition focus:border-blue-500"
            />
            <span className="text-sm text-slate-500">responses per subject</span>
          </div>
        </div>

        {/* Student name */}
        <div className="rounded-2xl border border-slate-200 bg-white p-6">
          <h3 className="mb-2 text-lg font-semibold text-slate-800">
            Student Identification
          </h3>
          <p className="mb-4 text-sm text-slate-500">
            When enabled, students can optionally enter their name. When
            disabled (default), feedback is anonymous.
          </p>
          <label className="flex items-center gap-3 cursor-pointer">
            <button
              type="button"
              onClick={() => setRequireName(!requireName)}
              className={`relative h-7 w-12 rounded-full transition ${
                requireName ? 'bg-blue-600' : 'bg-slate-300'
              }`}
            >
              <span
                className={`absolute top-1 h-5 w-5 rounded-full bg-white transition-all ${
                  requireName ? 'left-6' : 'left-1'
                }`}
              />
            </button>
            <span className="text-sm font-medium text-slate-700">
              {requireName ? 'Student name enabled' : 'Anonymous feedback'}
            </span>
          </label>
        </div>

        {/* Institution name */}
        <div className="rounded-2xl border border-slate-200 bg-white p-6">
          <h3 className="mb-2 text-lg font-semibold text-slate-800">
            Institution Name
          </h3>
          <p className="mb-4 text-sm text-slate-500">
            Displayed on PDF reports and the student panel header.
          </p>
          <input
            type="text"
            value={institutionName}
            onChange={(e) => setInstitutionName(e.target.value)}
            className="w-full rounded-xl border border-slate-200 px-4 py-3 text-base outline-none transition focus:border-blue-500"
          />
        </div>

        {/* Save */}
        <button
          onClick={handleSave}
          disabled={saving}
          className="flex items-center gap-2 rounded-xl bg-blue-600 px-6 py-3.5 font-semibold text-white transition hover:bg-blue-700 disabled:opacity-50"
        >
          {saving ? (
            <Loader2 className="h-5 w-5 animate-spin" />
          ) : (
            <Save className="h-5 w-5" />
          )}
          Save Settings
        </button>

        {saved && (
          <div className="rounded-xl bg-green-50 px-4 py-3 text-sm font-medium text-green-700">
            Settings saved successfully.
          </div>
        )}
      </div>
    </div>
  );
}

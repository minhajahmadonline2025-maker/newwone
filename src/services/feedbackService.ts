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

export async function fetchClasses(): Promise<ClassRow[]> {
  const { data, error } = await supabase
    .from('classes')
    .select('*')
    .order('sort_order');
  if (error) throw error;
  return data ?? [];
}

export async function fetchUsthadsByClass(
  classId: string
): Promise<
  (ClassUsthadRow & {
    usthad: UsthadRow;
    class_usthad_subjects: (ClassUsthadSubjectRow & { subject: SubjectRow })[];
  })[]
> {
  const { data, error } = await supabase
    .from('class_usthads')
    .select(
      '*, usthad:usthads(*), class_usthad_subjects:class_usthad_subjects(*, subject:subjects(*))'
    )
    .eq('class_id', classId)
    .order('created_at');
  if (error) throw error;
  return data ?? [];
}

export async function fetchFeedbackSettings(): Promise<FeedbackSettings> {
  const { data, error } = await supabase
    .from('feedback_settings')
    .select('*')
    .eq('id', 1)
    .maybeSingle();
  if (error) throw error;
  return data as FeedbackSettings;
}

export async function fetchResponseCount(
  classUsthadSubjectId: string
): Promise<number> {
  const { count, error } = await supabase
    .from('feedback_responses')
    .select('*', { count: 'exact', head: true })
    .eq('class_usthad_subject_id', classUsthadSubjectId);
  if (error) throw error;
  return count ?? 0;
}

export async function fetchResponsesBySubject(
  classUsthadSubjectId: string
): Promise<FeedbackResponseRow[]> {
  const { data, error } = await supabase
    .from('feedback_responses')
    .select('*')
    .eq('class_usthad_subject_id', classUsthadSubjectId)
    .order('created_at', { ascending: false });
  if (error) throw error;
  return data ?? [];
}

export async function fetchResponsesByCusIds(
  cusIds: string[]
): Promise<FeedbackResponseRow[]> {
  if (cusIds.length === 0) return [];
  const { data, error } = await supabase
    .from('feedback_responses')
    .select('*')
    .in('class_usthad_subject_id', cusIds);
  if (error) throw error;
  return data ?? [];
}

export async function submitFeedback(
  classUsthadSubjectId: string,
  rating: number,
  comment: string | null,
  studentName: string | null,
  studentNumber: number | null
): Promise<FeedbackResponseRow> {
  const { data, error } = await supabase
    .from('feedback_responses')
    .insert({
      class_usthad_subject_id: classUsthadSubjectId,
      rating,
      comment: comment || null,
      student_name: studentName || null,
      student_number: studentNumber,
    })
    .select('*')
    .single();
  if (error) throw error;
  return data;
}

export async function fetchAllUsthads(): Promise<UsthadRow[]> {
  const { data, error } = await supabase
    .from('usthads')
    .select('*')
    .order('name');
  if (error) throw error;
  return data ?? [];
}

export async function fetchAllSubjects(): Promise<SubjectRow[]> {
  const { data, error } = await supabase
    .from('subjects')
    .select('*')
    .order('name');
  if (error) throw error;
  return data ?? [];
}

export async function fetchAllClassUsthads(): Promise<
  (ClassUsthadRow & {
    class: ClassRow;
    usthad: UsthadRow;
    class_usthad_subjects: (ClassUsthadSubjectRow & { subject: SubjectRow })[];
  })[]
> {
  const { data, error } = await supabase
    .from('class_usthads')
    .select(
      '*, class:classes(*), usthad:usthads(*), class_usthad_subjects:class_usthad_subjects(*, subject:subjects(*))'
    )
    .order('created_at');
  if (error) throw error;
  return data ?? [];
}

export async function updateFeedbackLimit(
  classUsthadSubjectId: string,
  limit: number | null
): Promise<void> {
  const { error } = await supabase
    .from('class_usthad_subjects')
    .update({ feedback_limit: limit })
    .eq('id', classUsthadSubjectId);
  if (error) throw error;
}

export async function updateFeedbackSettings(
  settings: Partial<FeedbackSettings>
): Promise<void> {
  const { error } = await supabase
    .from('feedback_settings')
    .update(settings)
    .eq('id', 1);
  if (error) throw error;
}

export async function resetFeedback(
  classUsthadSubjectId: string
): Promise<void> {
  const { error } = await supabase
    .from('feedback_responses')
    .delete()
    .eq('class_usthad_subject_id', classUsthadSubjectId);
  if (error) throw error;
}

export async function addUsthad(name: string): Promise<UsthadRow> {
  const { data, error } = await supabase
    .from('usthads')
    .insert({ name })
    .select('*')
    .single();
  if (error) throw error;
  return data;
}

export async function updateUsthad(id: string, name: string): Promise<void> {
  const { error } = await supabase
    .from('usthads')
    .update({ name })
    .eq('id', id);
  if (error) throw error;
}

export async function deleteUsthad(id: string): Promise<void> {
  const { error } = await supabase.from('usthads').delete().eq('id', id);
  if (error) throw error;
}

export async function addSubject(name: string): Promise<SubjectRow> {
  const { data, error } = await supabase
    .from('subjects')
    .insert({ name })
    .select('*')
    .single();
  if (error) throw error;
  return data;
}

export async function updateSubject(id: string, name: string): Promise<void> {
  const { error } = await supabase
    .from('subjects')
    .update({ name })
    .eq('id', id);
  if (error) throw error;
}

export async function deleteSubject(id: string): Promise<void> {
  const { error } = await supabase.from('subjects').delete().eq('id', id);
  if (error) throw error;
}

export async function assignUsthadToClass(
  classId: string,
  usthadId: string
): Promise<ClassUsthadRow> {
  const { data, error } = await supabase
    .from('class_usthads')
    .insert({ class_id: classId, usthad_id: usthadId })
    .select('*')
    .single();
  if (error) throw error;
  return data;
}

export async function removeUsthadFromClass(
  classUsthadId: string
): Promise<void> {
  const { error } = await supabase
    .from('class_usthads')
    .delete()
    .eq('id', classUsthadId);
  if (error) throw error;
}

export async function assignSubjectToUsthad(
  classUsthadId: string,
  subjectId: string
): Promise<void> {
  const { error } = await supabase
    .from('class_usthad_subjects')
    .insert({ class_usthad_id: classUsthadId, subject_id: subjectId })
    .select('*');
  if (error) throw error;
}

export async function removeSubjectFromUsthad(
  classUsthadSubjectId: string
): Promise<void> {
  const { error } = await supabase
    .from('class_usthad_subjects')
    .delete()
    .eq('id', classUsthadSubjectId);
  if (error) throw error;
}

export function getEffectiveLimit(
  cus: { feedback_limit: number | null },
  defaultLimit: number
): number {
  return cus.feedback_limit ?? defaultLimit;
}

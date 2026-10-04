export type ClassRow = {
  id: string;
  name: string;
  sort_order: number;
  created_at: string;
};

export type UsthadRow = {
  id: string;
  name: string;
  created_at: string;
};

export type SubjectRow = {
  id: string;
  name: string;
  created_at: string;
};

export type ClassUsthadRow = {
  id: string;
  class_id: string;
  usthad_id: string;
  created_at: string;
};

export type ClassUsthadSubjectRow = {
  id: string;
  class_usthad_id: string;
  subject_id: string;
  feedback_limit: number | null;
  created_at: string;
};

export type FeedbackSettings = {
  id: number;
  default_feedback_limit: number;
  require_student_name: boolean;
  institution_name: string;
};

export type FeedbackResponseRow = {
  id: string;
  class_usthad_subject_id: string;
  rating: number;
  comment: string | null;
  student_name: string | null;
  student_number: number | null;
  created_at: string;
};

export type ClassUsthadWithDetails = ClassUsthadRow & {
  usthad: UsthadRow;
  class_usthad_subjects: (ClassUsthadSubjectRow & {
    subject: SubjectRow;
  })[];
};

export type FeedbackWithDetails = FeedbackResponseRow & {
  class_usthad_subject: ClassUsthadSubjectRow & {
    subject: SubjectRow;
    class_usthad: ClassUsthadRow & {
      class: ClassRow;
      usthad: UsthadRow;
    };
  };
};

export type DocumentRow = {
  id: string;
  title: string;
  description: string | null;
  file_path: string;
  file_url: string;
  file_type: string | null;
  file_size: number | null;
  created_at: string;
};

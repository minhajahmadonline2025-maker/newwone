import { useCallback, useEffect, useRef, useState } from 'react';
import {
  Download,
  FileText,
  Loader2,
  Plus,
  Share2,
  Trash2,
  Upload,
  X,
} from 'lucide-react';
import { supabase } from '@/lib/supabase';
import type { DocumentRow } from '@/types/database';

function formatFileSize(bytes: number | null): string {
  if (!bytes) return '—';
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}

function formatDate(iso: string): string {
  return new Date(iso).toLocaleDateString('en-GB', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  });
}

export default function AdminDocuments() {
  const [loading, setLoading] = useState(true);
  const [documents, setDocuments] = useState<DocumentRow[]>([]);
  const [showUpload, setShowUpload] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [deleteConfirm, setDeleteConfirm] = useState<string | null>(null);

  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [file, setFile] = useState<File | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const loadDocuments = useCallback(async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('documents')
        .select('*')
        .order('created_at', { ascending: false });
      if (error) throw error;
      setDocuments(data ?? []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadDocuments();
  }, [loadDocuments]);

  const handleUpload = useCallback(async () => {
    if (!file || !title.trim()) return;
    try {
      setUploading(true);
      const fileExt = file.name.split('.').pop();
      const fileName = `${Date.now()}-${Math.random()
        .toString(36)
        .slice(2)}.${fileExt}`;
      const filePath = `documents/${fileName}`;

      const { error: uploadError } = await supabase.storage
        .from('documents')
        .upload(filePath, file);

      if (uploadError) throw uploadError;

      const { data: urlData } = supabase.storage
        .from('documents')
        .getPublicUrl(filePath);

      const { error: insertError } = await supabase
        .from('documents')
        .insert({
          title: title.trim(),
          description: description.trim() || null,
          file_path: filePath,
          file_url: urlData.publicUrl,
          file_type: file.type || null,
          file_size: file.size,
        });

      if (insertError) throw insertError;

      setShowUpload(false);
      setTitle('');
      setDescription('');
      setFile(null);
      if (fileInputRef.current) fileInputRef.current.value = '';
      await loadDocuments();
    } catch (err) {
      console.error(err);
      alert('Failed to upload document. Please try again.');
    } finally {
      setUploading(false);
    }
  }, [file, title, description, loadDocuments]);

  const handleDelete = useCallback(
    async (doc: DocumentRow) => {
      try {
        const { error: storageError } = await supabase.storage
          .from('documents')
          .remove([doc.file_path]);
        if (storageError) console.error(storageError);

        const { error: dbError } = await supabase
          .from('documents')
          .delete()
          .eq('id', doc.id);
        if (dbError) throw dbError;

        setDeleteConfirm(null);
        await loadDocuments();
      } catch (err) {
        console.error(err);
        alert('Failed to delete document.');
      }
    },
    [loadDocuments]
  );

  const handleShare = useCallback((doc: DocumentRow) => {
    const url = doc.file_url;
    if (navigator.share) {
      navigator
        .share({ title: doc.title, text: doc.description ?? '', url })
        .catch(() => {});
    } else {
      navigator.clipboard.writeText(url);
      alert('Link copied to clipboard!');
    }
  }, []);

  const handleDownload = useCallback((doc: DocumentRow) => {
    window.open(doc.file_url, '_blank');
  }, []);

  if (loading) {
    return (
      <div className="flex h-full items-center justify-center py-20">
        <Loader2 className="h-8 w-8 animate-spin text-blue-600" />
      </div>
    );
  }

  return (
    <div>
      <div className="mb-6 flex items-center justify-between">
        <h2 className="text-2xl font-bold text-slate-900">Documents</h2>
        <button
          onClick={() => setShowUpload(true)}
          className="flex items-center gap-2 rounded-xl bg-blue-600 px-4 py-2.5 text-sm font-semibold text-white transition hover:bg-blue-700"
        >
          <Plus className="h-4 w-4" />
          Upload Document
        </button>
      </div>

      {documents.length === 0 ? (
        <div className="rounded-2xl border-2 border-dashed border-slate-200 bg-white py-16 text-center">
          <FileText className="mx-auto h-12 w-12 text-slate-300" />
          <p className="mt-4 text-sm text-slate-400">
            No documents shared yet. Click "Upload Document" to add one.
          </p>
        </div>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2">
          {documents.map((doc) => (
            <div
              key={doc.id}
              className="flex flex-col rounded-2xl border border-slate-200 bg-white p-5 transition hover:shadow-md"
            >
              <div className="flex items-start gap-3">
                <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-blue-50">
                  <FileText className="h-5 w-5 text-blue-600" />
                </div>
                <div className="min-w-0 flex-1">
                  <h3 className="truncate font-semibold text-slate-900">
                    {doc.title}
                  </h3>
                  <p className="text-xs text-slate-400">
                    {formatDate(doc.created_at)} · {formatFileSize(doc.file_size)}
                  </p>
                </div>
              </div>

              {doc.description && (
                <p className="mt-3 line-clamp-2 text-sm text-slate-600">
                  {doc.description}
                </p>
              )}

              <div className="mt-4 flex items-center gap-2">
                <button
                  onClick={() => handleDownload(doc)}
                  className="flex items-center gap-1.5 rounded-lg bg-blue-50 px-3 py-2 text-xs font-medium text-blue-700 transition hover:bg-blue-100"
                >
                  <Download className="h-3.5 w-3.5" />
                  Open
                </button>
                <button
                  onClick={() => handleShare(doc)}
                  className="flex items-center gap-1.5 rounded-lg bg-emerald-50 px-3 py-2 text-xs font-medium text-emerald-700 transition hover:bg-emerald-100"
                >
                  <Share2 className="h-3.5 w-3.5" />
                  Share
                </button>
                {deleteConfirm === doc.id ? (
                  <div className="ml-auto flex items-center gap-2">
                    <button
                      onClick={() => handleDelete(doc)}
                      className="rounded-lg bg-red-600 px-3 py-2 text-xs font-medium text-white hover:bg-red-700"
                    >
                      Confirm
                    </button>
                    <button
                      onClick={() => setDeleteConfirm(null)}
                      className="rounded-lg bg-slate-200 px-3 py-2 text-xs font-medium text-slate-600"
                    >
                      Cancel
                    </button>
                  </div>
                ) : (
                  <button
                    onClick={() => setDeleteConfirm(doc.id)}
                    className="ml-auto flex items-center gap-1.5 rounded-lg bg-red-50 px-3 py-2 text-xs font-medium text-red-700 transition hover:bg-red-100"
                  >
                    <Trash2 className="h-3.5 w-3.5" />
                  </button>
                )}
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Upload Modal */}
      {showUpload && (
        <div
          className="fixed inset-0 z-50 flex items-start justify-center overflow-y-auto bg-black/40 p-4"
          onClick={() => setShowUpload(false)}
        >
          <div
            className="my-8 w-full max-w-lg rounded-2xl bg-white p-6 shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="mb-6 flex items-center justify-between">
              <h3 className="text-lg font-bold text-slate-900">
                Upload Document
              </h3>
              <button
                onClick={() => setShowUpload(false)}
                className="rounded-lg p-2 text-slate-400 transition hover:bg-slate-100"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            <div className="space-y-5">
              <div>
                <label className="mb-2 block text-sm font-semibold text-slate-700">
                  Title
                </label>
                <input
                  type="text"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  placeholder="Document title"
                  className="w-full rounded-xl border-2 border-slate-200 px-4 py-3 text-base outline-none transition focus:border-blue-500"
                />
              </div>

              <div>
                <label className="mb-2 block text-sm font-semibold text-slate-700">
                  Description (optional)
                </label>
                <textarea
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  placeholder="Add a note about this document..."
                  rows={3}
                  className="w-full resize-none rounded-xl border-2 border-slate-200 px-4 py-3 text-base outline-none transition focus:border-blue-500"
                />
              </div>

              <div>
                <label className="mb-2 block text-sm font-semibold text-slate-700">
                  File
                </label>
                <div
                  onClick={() => fileInputRef.current?.click()}
                  className="flex cursor-pointer flex-col items-center justify-center rounded-xl border-2 border-dashed border-slate-300 bg-slate-50 px-4 py-8 transition hover:border-blue-500 hover:bg-blue-50"
                >
                  {file ? (
                    <div className="flex items-center gap-2 text-sm text-slate-700">
                      <FileText className="h-5 w-5 text-blue-600" />
                      <span className="font-medium">{file.name}</span>
                      <span className="text-slate-400">
                        ({formatFileSize(file.size)})
                      </span>
                    </div>
                  ) : (
                    <>
                      <Upload className="h-8 w-8 text-slate-300" />
                      <p className="mt-2 text-sm text-slate-500">
                        Click to select a file
                      </p>
                      <p className="mt-1 text-xs text-slate-400">
                        PDF, images, or any document
                      </p>
                    </>
                  )}
                </div>
                <input
                  ref={fileInputRef}
                  type="file"
                  onChange={(e) => setFile(e.target.files?.[0] ?? null)}
                  className="hidden"
                  accept=".pdf,.doc,.docx,.txt,.png,.jpg,.jpeg,.webp,.xlsx,.pptx"
                />
              </div>

              <button
                onClick={handleUpload}
                disabled={!file || !title.trim() || uploading}
                className="flex w-full items-center justify-center gap-2 rounded-xl bg-blue-600 py-3.5 font-semibold text-white transition hover:bg-blue-700 disabled:cursor-not-allowed disabled:bg-slate-300"
              >
                {uploading ? (
                  <>
                    <Loader2 className="h-5 w-5 animate-spin" />
                    Uploading…
                  </>
                ) : (
                  <>
                    <Upload className="h-5 w-5" />
                    Upload & Share
                  </>
                )}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

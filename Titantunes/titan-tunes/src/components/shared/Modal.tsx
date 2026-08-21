type ModalProps = {
  title: string;
  isOpen: boolean;
  onClose: () => void;
  children: React.ReactNode;
};

export default function Modal({ title, isOpen, onClose, children }: ModalProps) {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/40 px-4 py-6">
      <div className="w-full max-w-2xl rounded-3xl bg-white p-8 shadow-2xl shadow-slate-900/20">
        <div className="mb-6 flex items-center justify-between">
          <h2 className="text-xl font-semibold text-slate-900">{title}</h2>
          <button className="rounded-full bg-slate-100 px-3 py-2 text-slate-600" onClick={onClose}>
            Fermer
          </button>
        </div>
        {children}
      </div>
    </div>
  );
}

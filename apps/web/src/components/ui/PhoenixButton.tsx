"use client";

interface PhoenixButtonProps {
  label: string;
  onClick?: () => void;
  type?: "button" | "submit";
  isLoading?: boolean;
  disabled?: boolean;
  variant?: "primary" | "outline" | "ghost";
  width?: string;
  icon?: React.ReactNode;
}

export function PhoenixButton({
  label,
  onClick,
  type = "button",
  isLoading = false,
  disabled = false,
  variant = "primary",
  width = "auto",
  icon,
}: PhoenixButtonProps) {
  const base = `flex items-center justify-center gap-2 px-5 py-3 rounded-xl font-semibold text-sm transition-all disabled:opacity-50`;

  const styles = {
    primary: `bg-[#FF6B00] hover:bg-[#E55F00] text-white shadow-[0_3px_12px_rgba(255,107,0,0.3)]`,
    outline: `border border-[var(--phoenix-border)] text-[var(--phoenix-text)] hover:border-[var(--phoenix-primary)] hover:text-[var(--phoenix-primary)]`,
    ghost: `text-[var(--phoenix-text-secondary)] hover:text-[var(--phoenix-text)]`,
  };

  return (
    <button
      type={type}
      onClick={onClick}
      disabled={disabled || isLoading}
      style={{ width }}
      className={`${base} ${styles[variant]}`}
    >
      {isLoading ? (
        <svg className="animate-spin w-4 h-4" viewBox="0 0 24 24" fill="none">
          <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
          <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z" />
        </svg>
      ) : icon}
      {label}
    </button>
  );
}

"use client";

import { useState } from "react";

interface PhoenixTextFieldProps {
  label: string;
  placeholder?: string;
  value: string;
  onChange: (value: string) => void;
  type?: string;
  error?: string;
  hint?: string;
  showToggle?: boolean;
  disabled?: boolean;
}

export function PhoenixTextField({
  label,
  placeholder,
  value,
  onChange,
  type = "text",
  error,
  showToggle = false,
  disabled = false,
}: PhoenixTextFieldProps) {
  const [show, setShow] = useState(false);
  const inputType = showToggle ? (show ? "text" : "password") : type;

  return (
    <div className="flex flex-col gap-1.5">
      <label className="text-xs font-semibold text-[var(--phoenix-text-secondary)] uppercase tracking-wide">
        {label}
      </label>
      <div className="relative">
        <input
          type={inputType}
          value={value}
          onChange={(e) => onChange(e.target.value)}
          placeholder={placeholder}
          disabled={disabled}
          className={`w-full bg-[var(--phoenix-bg)] border rounded-xl px-4 py-3 text-sm text-[var(--phoenix-text)] placeholder:text-[var(--phoenix-text-secondary)] outline-none transition-all
            ${error
              ? "border-[var(--phoenix-error)] focus:border-[var(--phoenix-error)]"
              : "border-[var(--phoenix-border)] focus:border-[var(--phoenix-primary)]"
            }`}
        />
        {showToggle && (
          <button
            type="button"
            onClick={() => setShow(!show)}
            className="absolute right-3 top-1/2 -translate-y-1/2 text-[var(--phoenix-text-secondary)] hover:text-[var(--phoenix-text)]"
          >
            {show ? (
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M17.94 17.94A10.07 10.07 0 0112 20c-7 0-11-8-11-8a18.45 18.45 0 015.06-5.94" />
                <path d="M9.9 4.24A9.12 9.12 0 0112 4c7 0 11 8 11 8a18.5 18.5 0 01-2.16 3.19" />
                <line x1="1" y1="1" x2="23" y2="23" />
              </svg>
            ) : (
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                <circle cx="12" cy="12" r="3" />
              </svg>
            )}
          </button>
        )}
      </div>
      {error && <p className="text-xs text-[var(--phoenix-error)]">{error}</p>}
    </div>
  );
}

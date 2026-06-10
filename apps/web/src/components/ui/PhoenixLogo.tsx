export function PhoenixLogo({ size = 56 }: { size?: number }) {
  const radius = size * 0.22;
  const fontSize = size * 0.55;

  return (
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 12 }}>
      <div
        style={{
          width: size,
          height: size,
          background: "rgba(255, 107, 0, 0.12)",
          border: "1.5px solid rgba(255, 107, 0, 0.4)",
          borderRadius: radius,
          boxShadow: "0 0 40px rgba(255, 107, 0, 0.3), 0 0 80px rgba(255, 107, 0, 0.1)",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          fontSize: fontSize,
          lineHeight: 1,
        }}
      >
        🔥
      </div>
      <span
        style={{
          color: "#F5F5F5",
          fontWeight: 900,
          fontSize: size * 0.3,
          letterSpacing: "0.25em",
        }}
      >
        PHOENIX
      </span>
    </div>
  );
}

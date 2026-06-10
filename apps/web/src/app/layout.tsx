import type { Metadata } from "next";
import "./globals.css";
import "../styles/phoenix.css";

export const metadata: Metadata = {
  title: "Phoenix",
  description: "Gerencie seus Roblox DataStores com segurança",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="pt-BR">
      <body style={{ background: "var(--phoenix-bg)", margin: 0 }}>
        {children}
      </body>
    </html>
  );
}
